import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';

class PermissionService {
  final ApiService _apiService = ApiService();

  // Get all permissions
  Future<List<Map<String, dynamic>>> getAllPermissions() async {
    try {
      final response = await _apiService.dio.get('/roles/permissions/');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(response.data['data']);
        }
      }

      debugPrint('⚠️ Unexpected response format: ${response.data}');
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Error fetching permissions: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // Create new permission
  Future<bool> createPermission({
    required String name,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/roles/permissions/',
        data: {'name': name, 'is_active': isActive},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Permission created successfully');
        return true;
      }

      return false;
    } on DioException catch (e) {
      debugPrint('❌ Error creating permission: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // Update permission
  Future<bool> updatePermission({
    required int permissionId,
    required String name,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/roles/permissions/$permissionId/',
        data: {'name': name, 'is_active': isActive},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Permission updated successfully');
        return true;
      }

      return false;
    } on DioException catch (e) {
      debugPrint('❌ Error updating permission: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // Delete permission
  Future<bool> deletePermission(int permissionId) async {
    try {
      final response = await _apiService.dio.delete(
        '/roles/permissions/$permissionId/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Permission deleted successfully');
        return true;
      }

      return false;
    } on DioException catch (e) {
      debugPrint('❌ Error deleting permission: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // Get single permission details
  Future<Map<String, dynamic>?> getPermissionById(int permissionId) async {
    try {
      final response = await _apiService.dio.get(
        '/roles/permissions/$permissionId/',
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching permission details: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }
}
