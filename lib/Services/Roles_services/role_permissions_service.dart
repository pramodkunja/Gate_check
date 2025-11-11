// role_permissions_api_service.dart
// Place this file in: lib/Services/Role_Permissions/

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatecheck/Services/Base_URL/base_url.dart';

class RolePermissionsApiService {
  static final RolePermissionsApiService _instance = RolePermissionsApiService._internal();
  factory RolePermissionsApiService() => _instance;

  late Dio _dio;
  static const String baseUrl = Appconfig.baseURL;

  RolePermissionsApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('authToken');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint('╔════════════════════════════════════════════════════════');
          debugPrint('║ REQUEST[${options.method}] => ${options.path}');
          debugPrint('║ Headers: ${options.headers}');
          debugPrint('║ Data: ${options.data}');
          debugPrint('╚════════════════════════════════════════════════════════');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('╔════════════════════════════════════════════════════════');
          debugPrint('║ RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
          debugPrint('║ Data: ${response.data}');
          debugPrint('╚════════════════════════════════════════════════════════');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('╔════════════════════════════════════════════════════════');
          debugPrint('║ ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}');
          debugPrint('║ Message: ${error.message}');
          debugPrint('║ Response Data: ${error.response?.data}');
          debugPrint('╚════════════════════════════════════════════════════════');
          return handler.next(error);
        },
      ),
    );
  }

  // Fetch all role permissions
  Future<List<RolePermissionModel>> getRolePermissions() async {
    try {
      final response = await _dio.get('/roles/assign-permissions/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RolePermissionModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load role permissions: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ Error fetching role permissions: ${e.response?.data}');
      throw Exception(getErrorMessage(e));
    }
  }

  // Assign permissions to a role
  Future<bool> assignPermissions({
    required String role,
    required List<String> permissions, required int roleId,
  }) async {
    try {
      final response = await _dio.post(
        '/roles/assign-permissions/',
        data: {
          'role': role,
          'permission': permissions,
        },
      );
      
      debugPrint('✅ Assign Permissions Response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('❌ Error assigning permissions: ${e.response?.data}');
      return false;
    }
  }

  // Update permissions for a role
  Future<bool> updatePermissions({
    required int rolePermissionId,
    required String role,
    required List<String> permission_id,
  }) async {
    try {
      final response = await _dio.put(
        '/roles/assign-permissions/$rolePermissionId/',
        data: {
          'role': role,
          'permission': permission_id,
        },
      );
      
      debugPrint('✅ Update Permissions Response: ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('❌ Error updating permissions: ${e.response?.data}');
      return false;
    }
  }

  // Delete role permissions
  Future<bool> deleteRolePermissions(int rolePermissionId) async {
    try {
      final response = await _dio.delete(
        '/roles/assign-permissions/$rolePermissionId/',
      );
      
      debugPrint('✅ Delete Permissions Response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      debugPrint('❌ Error deleting role permissions: ${e.response?.data}');
      return false;
    }
  }

  // Error message helper
  String getErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
      }
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

// Role Permission Model
class RolePermissionModel {
  final String role;
  final List<String> permissions;
  final int rolePermissionId;

  RolePermissionModel({
    required this.role,
    required this.permissions,
    required this.rolePermissionId,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      role: json['role'] ?? '',
      permissions: List<String>.from(json['permission'] ?? []),
      rolePermissionId: json['role_permission_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'permission': permissions,
      'role_permission_id': rolePermissionId,
    };
  }

  // Create a copy with updated values
  RolePermissionModel copyWith({
    String? role,
    List<String>? permissions,
    int? rolePermissionId,
  }) {
    return RolePermissionModel(
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      rolePermissionId: rolePermissionId ?? this.rolePermissionId,
    );
  }
}