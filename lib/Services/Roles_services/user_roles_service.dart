// user_role_service.dart
// Service for managing user roles with backend API integration

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';

class UserRoleModel {
  final int userRoleId;
  final String? createdBy;
  final String? modifiedBy;
  final bool isActive;
  final DateTime assignedAt;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String user;
  final String role;

  UserRoleModel({
    required this.userRoleId,
    this.createdBy,
    this.modifiedBy,
    required this.isActive,
    required this.assignedAt,
    required this.createdAt,
    required this.modifiedAt,
    required this.user,
    required this.role,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      userRoleId: json['user_role_id'] ?? 0,
      createdBy: json['created_by'],
      modifiedBy: json['modified_by'],
      isActive: json['is_active'] ?? true,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : DateTime.now(),
      user: json['user'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_role_id': userRoleId,
      'created_by': createdBy,
      'modified_by': modifiedBy,
      'is_active': isActive,
      'assigned_at': assignedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'user': user,
      'role': role,
    };
  }
}

class UserRoleService {
  static final UserRoleService _instance = UserRoleService._internal();
  factory UserRoleService() => _instance;

  final ApiService _apiService = ApiService(); // initialized once

  UserRoleService._internal();

  // -------------------- Get All User Roles --------------------
  Future<List<UserRoleModel>> getAllUserRoles() async {
    try {
      debugPrint('🔍 Fetching all user roles from backend...');
      final response = await _apiService.dio.get('/roles/user_role/');

      debugPrint('💡 Response status: ${response.statusCode}');
      debugPrint('💡 Response data: ${response.data}');

      List<dynamic> dataList;

      if (response.data is List) {
        dataList = response.data;
      } else if (response.data is Map<String, dynamic> &&
          response.data.containsKey('data')) {
        dataList = response.data['data'];
      } else {
        debugPrint('⚠️ Unexpected response format');
        throw Exception('Unexpected response format: ${response.data}');
      }

      final userRoles = dataList
          .map((json) => UserRoleModel.fromJson(json))
          .toList();
      debugPrint('✅ Fetched ${userRoles.length} user roles');
      return userRoles;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('Full error data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  // -------------------- Create User Role --------------------
  Future<UserRoleModel> createUserRole({
    required String user,
    required String role,
  }) async {
    try {
      debugPrint('➕ Creating user role: $user -> $role');
      final response = await _apiService.dio.post(
        '/roles/user_role/',
        data: {'user': user, 'role': role},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ User role created successfully');
        return UserRoleModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create user role: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating user role: ${e.message}');
      throw Exception(_getErrorMessage(e));
    }
  }

  // -------------------- Update User Role --------------------
  Future<UserRoleModel> updateUserRole({
    required int userRoleId,
    required String role,
  }) async {
    try {
      debugPrint('✏️ Updating user role ID $userRoleId to: $role');
      final response = await _apiService.dio.put(
        '/roles/user_role/$userRoleId/',
        data: {'role': role},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ User role updated successfully');
        return UserRoleModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update user role: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error updating user role: ${e.message}');
      throw Exception(_getErrorMessage(e));
    }
  }

  // -------------------- Delete User Role --------------------
  Future<bool> deleteUserRole(int userRoleId) async {
    try {
      debugPrint('🗑️ Deleting user role ID: $userRoleId');
      final response = await _apiService.dio.delete(
        '/roles/user_role/$userRoleId/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ User role deleted successfully');
        return true;
      } else {
        throw Exception('Failed to delete user role: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error deleting user role: ${e.message}');
      throw Exception(_getErrorMessage(e));
    }
  }

  // -------------------- Get Available Roles --------------------
  Future<List<String>> getAvailableRoles() async {
    try {
      debugPrint('📋 Fetching available roles...');
      final response = await _apiService.dio.get('/roles/available/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((role) => role.toString()).toList();
      } else {
        debugPrint('⚠️ Using default roles');
        return ['employee', 'Admin', 'Security Guard', 'Testing'];
      }
    } on DioException catch (e) {
      debugPrint(
        '⚠️ Error fetching available roles, using defaults: ${e.message}',
      );
      return ['employee', 'Admin', 'Security Guard', 'Testing'];
    }
  }

  // -------------------- Error Message Helper --------------------
  String _getErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('detail')) return data['detail'].toString();
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
