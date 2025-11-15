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

 // Updated API methods for role_permissions_service.dart
// Replace the corresponding methods in your RolePermissionsApiService class

// Add these methods to your RolePermissionsApiService class
// in role_permissions_service.dart

// ✅ Add this method to fetch all roles with their IDs
Future<List<Map<String, dynamic>>> getAllRoles() async {
  try {
    debugPrint('🔍 Fetching all roles...');
    
    final response = await _dio.get('/roles/create/');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch roles: ${response.statusCode}');
    }

    debugPrint('💡 Roles Response: ${response.data}');

    List<dynamic> dataList = [];
    
    if (response.data is List) {
      dataList = response.data;
    } else if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      dataList = map['data'] ?? map['roles'] ?? map['results'] ?? [];
    }

    final roles = <Map<String, dynamic>>[];

    for (var item in dataList) {
      if (item is! Map<String, dynamic>) continue;

      // Extract ID and name
      dynamic roleId = item['role_id'] ?? item['id'];
      String? roleName = item['role']?.toString() ?? 
                        item['name']?.toString() ?? 
                        item['role_name']?.toString();

      if (roleId != null && roleName != null && roleName.isNotEmpty) {
        roles.add({
          'id': roleId is int ? roleId : int.tryParse(roleId.toString()) ?? 0,
          'name': roleName,
        });
      }
    }

    debugPrint('✅ Fetched ${roles.length} roles');
    return roles;
  } on DioException catch (e) {
    debugPrint('❌ Error fetching roles: ${e.response?.data}');
    throw Exception(getErrorMessage(e));
  }
}

// ✅ Update this method to use List<int> for permissions
Future<bool> updatePermissions({
  required int rolePermissionId,
  required int roleId,
  required List<int> permissions, // ✅ Now expects List<int>
  required String role,
}) async {
  try {
    debugPrint('📤 Updating permissions for role $roleId');
    debugPrint('📤 Role Permission ID: $rolePermissionId');
    debugPrint('📤 Permission IDs: $permissions');
    
    final response = await _dio.put(
      '/roles/assign-permissions/$rolePermissionId/',
      data: {
        'role': roleId,
        'permission': permissions, // Send as 'permission' with IDs
      },
    );

    debugPrint('✅ Update Permissions Response: ${response.statusCode}');
    debugPrint('✅ Response Data: ${response.data}');
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint('❌ Error updating permissions: ${e.response?.data}');
    return false;
  }
}

// ✅ Update assignPermissions as well
Future<bool> assignPermissions({
  required int roleId,
  required List<int> permissions, // ✅ Now expects List<int>
}) async {
  try {
    debugPrint('📤 Assigning permissions for role $roleId');
    debugPrint('📤 Permission IDs: $permissions');
    
    final response = await _dio.post(
      '/roles/assign-permissions/',
      data: {
        "role": roleId,
        "permission": permissions, // List<int>
      },
    );

    debugPrint('✅ Assign Permissions Response: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 201;
  } on DioException catch (e) {
    debugPrint('❌ Error assigning permissions: ${e.response?.data}');
    return false;
  }
}

// Updated getAllPermissions - simplified version
Future<List<Map<String, dynamic>>> getAllPermissions() async {
  try {
    debugPrint('🔍 Fetching all available permissions...');
    
    final response = await _dio.get('/roles/permissions/');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch permissions: ${response.statusCode}');
    }

    debugPrint('💡 Permissions Response: ${response.data}');

    List<dynamic> dataList = [];
    
    if (response.data is List) {
      dataList = response.data;
    } else if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      dataList = map['data'] ?? map['permissions'] ?? map['results'] ?? [];
    }

    final permissions = <Map<String, dynamic>>[];

    for (var item in dataList) {
      if (item is! Map<String, dynamic>) continue;

      // Extract ID and name
      dynamic permId = item['permission_id'] ?? item['id'];
      String? permName = item['name']?.toString() ?? 
                        item['permission_name']?.toString() ?? 
                        item['permission']?.toString();

      if (permId != null && permName != null && permName.isNotEmpty) {
        permissions.add({
          'id': permId is int ? permId : int.tryParse(permId.toString()) ?? 0,
          'name': permName,
        });
      }
    }

    debugPrint('✅ Fetched ${permissions.length} permissions');
    return permissions;
  } on DioException catch (e) {
    debugPrint('❌ Error fetching permissions: ${e.response?.data}');
    throw Exception(getErrorMessage(e));
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

// Updated RolePermissionModel class
// Replace the existing class in role_permissions_service.dart

class RolePermissionModel {
  final int rolePermissionId;
  final int roleId;
  final String role; // role name
  final List<int> permissionIds; // backend sends IDs (may be empty if not provided)
  final List<String> permissions; // permission names for display

  RolePermissionModel({
    required this.rolePermissionId,
    required this.roleId,
    required this.role,
    required this.permissionIds,
    required this.permissions,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing RolePermissionModel from JSON: $json');
    
    List<int> permIds = [];
    List<String> permNames = [];

    // The backend sends permission NAMES as strings, not IDs
    if (json['permission'] is List) {
      final permList = json['permission'] as List;
      
      // Check if it's a list of strings (permission names) or integers (IDs)
      if (permList.isNotEmpty) {
        if (permList.first is String) {
          // Backend is sending permission names directly
          permNames = List<String>.from(permList);
          debugPrint('✅ Found ${permNames.length} permission names');
        } else if (permList.first is int) {
          // Backend is sending permission IDs
          permIds = List<int>.from(permList);
          debugPrint('✅ Found ${permIds.length} permission IDs');
        } else if (permList.first is Map) {
          // Backend is sending permission objects
          for (var p in permList) {
            if (p is Map<String, dynamic>) {
              if (p['id'] != null) {
                permIds.add(p['id'] is int ? p['id'] : int.parse(p['id'].toString()));
              }
              if (p['name'] != null) {
                permNames.add(p['name'].toString());
              }
            }
          }
          debugPrint('✅ Extracted from objects: ${permIds.length} IDs, ${permNames.length} names');
        }
      }
    }

    // Handle alternative field names
    if (permNames.isEmpty && json['permission_names'] is List) {
      permNames = List<String>.from(json['permission_names']);
    }
    if (permIds.isEmpty && json['permission_ids'] is List) {
      permIds = List<int>.from(json['permission_ids']);
    }

    // Parse role information
    int roleIdValue = 0;
    String roleName = '';
    
    // Backend might send 'role' as either ID (int) or name (string)
    if (json['role'] is int) {
      roleIdValue = json['role'];
      // Role name might be in a separate field
      if (json['role_name'] != null) {
        roleName = json['role_name'].toString();
      }
    } else if (json['role'] is String) {
      roleName = json['role'];
      // Try to find role_id in another field
      if (json['role_id'] is int) {
        roleIdValue = json['role_id'];
      }
    }
    
    // Additional fallback checks
    if (roleIdValue == 0 && json['role_id'] is int) {
      roleIdValue = json['role_id'];
    }
    if (roleName.isEmpty && json['role_name'] != null) {
      roleName = json['role_name'].toString();
    }
    
    debugPrint('🔍 Parsed Role: ID=$roleIdValue, Name="$roleName"');

    debugPrint('✅ Parsed: Role="$roleName", Permissions=${permNames.length}');

    return RolePermissionModel(
      rolePermissionId: json['role_permission_id'] ?? json['id'] ?? 0,
      roleId: roleIdValue,
      role: roleName,
      permissionIds: permIds,
      permissions: permNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_permission_id': rolePermissionId,
      'role': roleId,
      'role_name': role,
      'permissions': permissionIds.isNotEmpty ? permissionIds : permissions,
      'permission_names': permissions,
    };
  }
}