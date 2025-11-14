// role_permissions_api_service.dart
// Place this file in: lib/Services/Role_Permissions/

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatecheck/Services/Base_URL/base_url.dart';

class RolePermissionsApiService {
  static final RolePermissionsApiService _instance =
      RolePermissionsApiService._internal();
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

          debugPrint(
            '╔════════════════════════════════════════════════════════',
          );
          debugPrint('║ REQUEST[${options.method}] => ${options.path}');
          debugPrint('║ Headers: ${options.headers}');
          debugPrint('║ Data: ${options.data}');
          debugPrint(
            '╚════════════════════════════════════════════════════════',
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '╔════════════════════════════════════════════════════════',
          );
          debugPrint(
            '║ RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
          );
          debugPrint('║ Data: ${response.data}');
          debugPrint(
            '╚════════════════════════════════════════════════════════',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '╔════════════════════════════════════════════════════════',
          );
          debugPrint(
            '║ ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
          );
          debugPrint('║ Message: ${error.message}');
          debugPrint('║ Response Data: ${error.response?.data}');
          debugPrint(
            '╚════════════════════════════════════════════════════════',
          );
          return handler.next(error);
        },
      ),
    );
  }

  // In role_permissions_service.dart - Update getAllPermissions method

  Future<List<Map<String, dynamic>>> getAllPermissions() async {
    try {
      debugPrint('🔍 Fetching all available permissions...');

      // ✅ Try different possible endpoints
      Response? response;

      // Option 1: Try /roles/permissions/
      try {
        response = await _dio.get('/roles/permissions/');
        debugPrint('✅ Found permissions at /roles/permissions/');
      } catch (e) {
        debugPrint('⚠️ /roles/permissions/ not found, trying alternatives...');
      }

      if (response == null || response.statusCode != 200) {
        debugPrint('❌ No valid permissions endpoint found');
        throw Exception('Could not find permissions endpoint');
      }

      debugPrint('💡 Permissions Response Status: ${response.statusCode}');
      debugPrint('💡 Permissions Response Data: ${response.data}');
      debugPrint('💡 Data Type: ${response.data.runtimeType}');

      // Handle different response formats
      List<dynamic> dataList = [];

      if (response.data == null) {
        debugPrint('⚠️ Response data is null');
        throw Exception('No permissions data received from server');
      }

      if (response.data is List) {
        dataList = response.data;
        debugPrint('✅ Response is a List with ${dataList.length} items');
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        debugPrint('📦 Response is a Map with keys: ${map.keys}');

        // Try different possible keys
        if (map.containsKey('data')) {
          dataList = map['data'] is List ? map['data'] : [];
        } else if (map.containsKey('permissions')) {
          dataList = map['permissions'] is List ? map['permissions'] : [];
        } else if (map.containsKey('results')) {
          dataList = map['results'] is List ? map['results'] : [];
        } else {
          debugPrint('⚠️ Map does not contain expected keys');
          // If map has items directly, try to use them
          dataList = [map];
        }
      }

      if (dataList.isEmpty) {
        debugPrint('⚠️ No permissions found in response');
        throw Exception('No permissions available');
      }

      debugPrint('📋 Processing ${dataList.length} permission items...');

      // Normalize permissions data
      final permissions = <Map<String, dynamic>>[];

      for (var i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        debugPrint('Processing item $i: $item');

        if (item is! Map<String, dynamic>) {
          debugPrint('⚠️ Item $i is not a Map, skipping');
          continue;
        }

        // Try to extract ID
        int? permId;
        if (item['permission_id'] != null) {
          permId = item['permission_id'] is int
              ? item['permission_id']
              : int.tryParse(item['permission_id'].toString());
        } else if (item['id'] != null) {
          permId = item['id'] is int
              ? item['id']
              : int.tryParse(item['id'].toString());
        }

        // Try to extract name
        String? permName;
        if (item['name'] != null) {
          permName = item['name'].toString();
        } else if (item['permission_name'] != null) {
          permName = item['permission_name'].toString();
        } else if (item['permission'] != null) {
          permName = item['permission'].toString();
        }

        if (permId != null && permName != null && permName.isNotEmpty) {
          permissions.add({'id': permId, 'name': permName});
          debugPrint('✅ Added permission: $permId - $permName');
        } else {
          debugPrint('⚠️ Skipped item $i: id=$permId, name=$permName');
        }
      }

      if (permissions.isEmpty) {
        throw Exception('Could not parse any valid permissions from response');
      }

      debugPrint('✅ Successfully fetched ${permissions.length} permissions');
      return permissions;
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching permissions');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('Error Message: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Unexpected error fetching permissions: $e');
      rethrow;
    }
  }

  // Fetch all role permissions
  Future<List<RolePermissionModel>> getRolePermissions() async {
    try {
      final response = await _dio.get('/roles/assign-permissions/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RolePermissionModel.fromJson(json)).toList();
      }
      throw Exception(
        'Failed to load role permissions: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('❌ Error fetching role permissions: ${e.response?.data}');
      throw Exception(getErrorMessage(e));
    }
  }

  // Assign permissions to a role
  Future<bool> assignPermissions({
    required int roleId,
    required List<int> permissionIds,
  }) async {
    try {
      final response = await _dio.post(
        '/roles/assign-permissions/',
        data: {
          "role": roleId, // int
          "permission": permissionIds, // List<int>
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
    required int roleId,
    required List<int> permissionIds,
    required String role,
  }) async {
    try {
      final response = await _dio.put(
        '/roles/assign-permissions/$rolePermissionId/',
        data: {'role': roleId, 'permissions': permissionIds},
      );

      return response.statusCode == 200;
    } catch (_) {
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
// Update the RolePermissionModel class in role_permissions_service.dart

class RolePermissionModel {
  final int rolePermissionId;
  final int roleId;
  final String role; // role name
  final List<int> permissionIds; // backend sends IDs
  final List<String> permissions; // permission names for display

  RolePermissionModel({
    required this.rolePermissionId,
    required this.roleId,
    required this.role,
    required this.permissionIds,
    required this.permissions,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    // Parse permission IDs
    List<int> permIds = [];
    if (json['permission'] is List) {
      permIds = List<int>.from(json['permission']);
    } else if (json['permissions'] is List) {
      permIds = List<int>.from(json['permissions']);
    }

    // Parse permission names if available
    List<String> permNames = [];
    if (json['permission_names'] is List) {
      permNames = List<String>.from(json['permission_names']);
    } else if (json['permissions_display'] is List) {
      permNames = List<String>.from(json['permissions_display']);
    }

    return RolePermissionModel(
      rolePermissionId: json['role_permission_id'] ?? 0,
      roleId: json['role'] is int ? json['role'] : 0,
      role: json['role_name']?.toString() ?? json['role']?.toString() ?? '',
      permissionIds: permIds,
      permissions: permNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_permission_id': rolePermissionId,
      'role': roleId,
      'role_name': role,
      'permissions': permissionIds,
      'permission_names': permissions,
    };
  }
}
