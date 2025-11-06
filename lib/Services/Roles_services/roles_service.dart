import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';

class RoleService {
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;

  final ApiService _apiService = ApiService();

  RoleService._internal();

  // -------------------- Get All Roles --------------------
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    try {
      final response = await _apiService.dio.get('/roles/create/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        return data
            .map(
              (role) => {
                'role_id': role['role_id'],
                'name': role['name'],
                'status': role['is_active'] ? 'Active' : 'Inactive',
                'createdBy': role['created_by'] ?? 'Unknown',
                'modifiedBy': role['modified_by'],
                'createdDate': _formatDate(role['created_at']),
                'modifiedDate': _formatDate(role['modified_at']),
                'is_active': role['is_active'],
                'created_at': role['created_at'],
                'modified_at': role['modified_at'],
              },
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch roles: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Error fetching roles: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error fetching roles: $e');
      throw Exception('Failed to fetch roles. Please try again.');
    }
  }

  // -------------------- Create Role --------------------
  Future<Map<String, dynamic>> createRole({
    required String name,
    required bool isActive,
    required String createdBy,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/roles/create/',
        data: {'name': name, 'is_active': isActive, 'created_by': createdBy},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Role created successfully');
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to create role: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating role: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error creating role: $e');
      throw Exception('Failed to create role. Please try again.');
    }
  }

  // -------------------- Update Role --------------------
  Future<Map<String, dynamic>> updateRole({
    required int roleId,
    required String name,
    required bool isActive,
    required String modifiedBy,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/roles/role/$roleId/',
        data: {'name': name, 'is_active': isActive, 'modified_by': modifiedBy},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Role updated successfully');
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to update role: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Error updating role: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error updating role: $e');
      throw Exception('Failed to update role. Please try again.');
    }
  }

  // -------------------- Delete Role --------------------
  Future<void> deleteRole(int roleId) async {
    try {
      final response = await _apiService.dio.delete('/roles/role/$roleId/');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Role deleted successfully');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to delete role: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Error deleting role: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error deleting role: $e');
      throw Exception('Failed to delete role. Please try again.');
    }
  }

  // -------------------- Get Role by ID --------------------
  Future<Map<String, dynamic>> getRoleById(int roleId) async {
    try {
      final response = await _apiService.dio.get('/roles/role/$roleId/');

      if (response.statusCode == 200) {
        final role = response.data;
        return {
          'role_id': role['role_id'],
          'name': role['name'],
          'status': role['is_active'] ? 'Active' : 'Inactive',
          'createdBy': role['created_by'] ?? 'Unknown',
          'modifiedBy': role['modified_by'],
          'createdDate': _formatDate(role['created_at']),
          'modifiedDate': _formatDate(role['modified_at']),
          'is_active': role['is_active'],
          'created_at': role['created_at'],
          'modified_at': role['modified_at'],
        };
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch role: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Error fetching role: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error fetching role: $e');
      throw Exception('Failed to fetch role. Please try again.');
    }
  }

  // -------------------- Get Active Roles Only --------------------
  Future<List<Map<String, dynamic>>> getActiveRoles() async {
    try {
      final allRoles = await getAllRoles();
      return allRoles.where((role) => role['is_active'] == true).toList();
    } catch (e) {
      debugPrint('❌ Error fetching active roles: $e');
      rethrow;
    }
  }

  // -------------------- Get Inactive Roles Only --------------------
  Future<List<Map<String, dynamic>>> getInactiveRoles() async {
    try {
      final allRoles = await getAllRoles();
      return allRoles.where((role) => role['is_active'] == false).toList();
    } catch (e) {
      debugPrint('❌ Error fetching inactive roles: $e');
      rethrow;
    }
  }

  // -------------------- Search Roles --------------------
  Future<List<Map<String, dynamic>>> searchRoles(String query) async {
    try {
      final allRoles = await getAllRoles();
      if (query.isEmpty) return allRoles;

      return allRoles.where((role) {
        final name = role['name'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error searching roles: $e');
      rethrow;
    }
  }

  // -------------------- Toggle Role Status --------------------
  Future<Map<String, dynamic>> toggleRoleStatus({
    required int roleId,
    required String name,
    required bool currentStatus,
    required String modifiedBy,
  }) async {
    try {
      return await updateRole(
        roleId: roleId,
        name: name,
        isActive: !currentStatus,
        modifiedBy: modifiedBy,
      );
    } catch (e) {
      debugPrint('❌ Error toggling role status: $e');
      rethrow;
    }
  }

  // -------------------- Helper: Format Date --------------------
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('⚠️ Date parsing error: $e');
      return dateString;
    }
  }

  // -------------------- Helper: Format DateTime for Display --------------------
  String formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('⚠️ DateTime parsing error: $e');
      return dateString;
    }
  }
}
