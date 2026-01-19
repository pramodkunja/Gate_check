// user_role_service.dart
// Service for managing user roles with backend API integration

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Admin_Screens/User_roles-screen/user_role_model.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRoleService {
  static final UserRoleService _instance = UserRoleService._internal();
  factory UserRoleService() => _instance;

  final ApiService _apiService = ApiService(); // initialized once

  UserRoleService._internal();

  // -------------------- Get All User Roles --------------------
  Future<List<UserRoleModel>> getAllUserRoles() async {
    try {
      debugPrint('🔍 Fetching user roles from backend...');

      final isSuperUser = await _apiService.isSuperUser();
      Response response;

      if (isSuperUser) {
        debugPrint('🌍 Fetching ALL user roles (SuperUser mode)');
        response = await _apiService.dio.get('/roles/user_role/');
      } else {
        final prefs = await SharedPreferences.getInstance();
        final companyId = prefs.getString('companyId');

        if (companyId == null || companyId.isEmpty) {
          debugPrint('⚠️ No companyId found for non-superuser');
          throw Exception('Company ID not found');
        }

        debugPrint('🏢 Fetching user roles for company_id: $companyId');
        response = await _apiService.dio.get(
          '/roles/user_role/',
          queryParameters: {'company_id': companyId},
        );
      }

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

      if (isSuperUser) {
        debugPrint('✅ SuperUser: Returning all ${userRoles.length} roles');
        return userRoles;
      } else {
        final prefs = await SharedPreferences.getInstance();
        final companyIdStr = prefs.getString('companyId');
        
        debugPrint('🔍 Filtering roles for company ID: $companyIdStr');
        
        if (companyIdStr != null) {
          final initialCount = userRoles.length;
          // ignore: unused_local_variable
          final companyId = int.tryParse(companyIdStr);
          
          final filteredRoles = userRoles.where((role) {
            // Filter logic: keep if role.companyId matches or if it's null (safe fallback)
            // But usually we strictly want matches. Let's assume strict match.
            // Converting both to string for safer comparison
            return role.companyId.toString() == companyIdStr.toString();
          }).toList();
          
          debugPrint('🧹 Local Filter: ${initialCount - filteredRoles.length} roles removed');
          debugPrint('✅ Returning ${filteredRoles.length} roles for company $companyIdStr');
          return filteredRoles;
        }
        
        return userRoles;
      }
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
    required int userId,
    required int roleId,
    required user,
    required role,
  }) async {
    try {
      debugPrint('➕ Creating user role: user=$userId  role=$roleId');

      final response = await _apiService.dio.post(
        '/roles/user_role/',
        data: {'user': userId, 'role': roleId},
      );

      debugPrint('📥 Create Role Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserRoleModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create user role');
      }
    } on DioException catch (e) {
      debugPrint('❌ Create user role error: ${e.response?.data}');
      throw Exception(_getErrorMessage(e));
    }
  }

  // -------------------- Update User Role --------------------
  Future<UserRoleModel> updateUserRole({
    required int userRoleId,
    required String userId,
    required int roleId,
    required String user,
    required String role,
  }) async {
    try {
      debugPrint(
        "✏ Updating: userRoleId=$userRoleId userId=$userId roleId=$roleId",
      );

      final response = await _apiService.dio.put(
        '/roles/user_role/$userRoleId/',
        data: {'role': roleId},
      );

      debugPrint('📥 Update Role Response: ${response.data}');

      if (response.statusCode == 200) {
        return UserRoleModel.fromJson(response.data);
      }

      throw Exception("Failed to update role");
    } on DioException catch (e) {
      debugPrint("❌ Update role error: ${e.response?.data}");
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

  // -------------------- Get All Users --------------------
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      debugPrint('👥 Fetching all users from backend...');

      final isSuperUser = await _apiService.isSuperUser();
      debugPrint('🦸 Is SuperUser: $isSuperUser');

      Response response;

      if (isSuperUser) {
        // Superuser: fetch all users (no company_id param)
        debugPrint('🌍 Fetching ALL users (SuperUser mode)');
        response = await _apiService.dio.get('/user/create-user/');
      } else {
        // Regular user: fetch users for their company
        final prefs = await SharedPreferences.getInstance();
        final companyId = prefs.getString('companyId');

        if (companyId == null || companyId.isEmpty) {
          debugPrint('⚠️ No companyId found in local storage for non-superuser');
          throw Exception('Company ID not found');
        }

        debugPrint('🏢 Fetching users for company_id: $companyId');
        response = await _apiService.dio.get(
          '/user/create-user/',
          queryParameters: {'company_id': companyId},
        );
      }

      debugPrint('💡 Users Response Status: ${response.statusCode}');
      debugPrint('💡 Users Response Data: ${response.data}');

      // Normalize response data
      List<dynamic> dataList;
      if (response.data is List) {
        dataList = response.data;
      } else if (response.data is Map<String, dynamic> &&
          response.data.containsKey('data')) {
        dataList = response.data['data'];
      } else if (response.data is Map<String, dynamic> &&
          response.data.containsKey('users')) {
        dataList = response.data['users'];
      } else {
        debugPrint('⚠️ Unexpected users response format: ${response.data}');
        throw Exception('Unexpected response format: ${response.data}');
      }

      // ✅ Map user data into consistent format
      final users = dataList.map((user) {
        return {
          'id': user['id'] is int
              ? user['id']
              : int.tryParse(user['id']?.toString() ?? '') ??
                    int.tryParse(user['user_id']?.toString() ?? ''),
          'username':
              user['username']?.toString() ??
              user['name']?.toString() ??
              user['email']?.toString() ??
              'Unknown User',
          'email': user['email']?.toString() ?? '',
        };
      }).toList();

      debugPrint('✅ Total Users Fetched: ${users.length}');
      // Optional: limit log output for performance
      if (users.length <= 10) {
        for (var u in users) {
          debugPrint('👤 ${u['username']} (${u['id']})');
        }
      }

      return users;
    } on DioException catch (e) {
      debugPrint('❌ DioException while fetching users: ${e.message}');
      debugPrint('Full error data: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching users: $e');
      return [];
    }
  }

  // -------------------- Get Available Roles --------------------
  Future<List<Map<String, dynamic>>> getAvailableRoles() async {
    try {
      debugPrint('📋 Fetching available roles...');
      final response = await _apiService.dio.get('/roles/create/');

      debugPrint('💡 Roles Response Status: ${response.statusCode}');
      debugPrint('💡 Roles Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;

          // Extract both role_id and name
          final List<Map<String, dynamic>> roles = data
              .where(
                (item) =>
                    item['role_id'] != null &&
                    item['name']?.toString().isNotEmpty == true,
              )
              .map(
                (item) => {
                  'id': item['role_id'],
                  'name': item['name'].toString().trim(),
                },
              )
              .toList();

          debugPrint('✅ Extracted Roles: $roles');
          return roles;
        } else {
          throw Exception('Unexpected response format for roles');
        }
      } else {
        debugPrint('⚠️ Using default roles - status ${response.statusCode}');
        return [
          {'id': 1, 'name': 'employee'},
          {'id': 2, 'name': 'Admin'},
          {'id': 3, 'name': 'Security Guard'},
        ];
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException while fetching roles: ${e.message}');
      debugPrint('Full error data: ${e.response?.data}');
      return [
        {'id': 1, 'name': 'employee'},
        {'id': 2, 'name': 'Admin'},
        {'id': 3, 'name': 'Security Guard'},
      ];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching roles: $e');
      return [
        {'id': 1, 'name': 'employee'},
        {'id': 2, 'name': 'Admin'},
        {'id': 3, 'name': 'Security Guard'},
      ];
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

// user_role_service.dart
// Service for managing user roles with backend API integration.
// Sends integers for user and role (backend expects {"user": 1, "role": 3})

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:gatecheck/Services/Auth_Services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserRoleModel {
//   final int userRoleId;
//   final String? createdBy;
//   final String? modifiedBy;
//   final bool isActive;
//   final DateTime assignedAt;
//   final DateTime createdAt;
//   final DateTime modifiedAt;
//   final int userId;
//   final int roleId;
//   final String user; // username
//   final String role; // role name

//   UserRoleModel({
//     required this.userRoleId,
//     this.createdBy,
//     this.modifiedBy,
//     required this.userId,
//     required this.roleId,
//     required this.isActive,
//     required this.assignedAt,
//     required this.createdAt,
//     required this.modifiedAt,
//     required this.user,
//     required this.role,
//   });

//   factory UserRoleModel.fromJson(Map<String, dynamic> json) {
//     return UserRoleModel(
//       userRoleId: (json['user_role_id'] ?? json['id'] ?? 0) is int
//           ? (json['user_role_id'] ?? json['id'])
//           : int.tryParse('${json['user_role_id'] ?? json['id']}') ?? 0,
//       createdBy: json['created_by']?.toString(),
//       modifiedBy: json['modified_by']?.toString(),
//       isActive: json['is_active'] ?? true,

//       /// userId may be nested or direct int
//       userId: json['user'] is Map ? json['user']['id'] : json['user'] ?? 0,

//       /// roleId may be nested or direct int
//       roleId: json['role'] is Map ? json['role']['id'] : json['role'] ?? 0,
//       assignedAt: json['assigned_at'] != null
//           ? DateTime.parse(json['assigned_at'].toString())
//           : DateTime.now(),
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'].toString())
//           : DateTime.now(),
//       modifiedAt: json['modified_at'] != null
//           ? DateTime.parse(json['modified_at'].toString())
//           : DateTime.now(),
//       user: json['user']?.toString() ?? json['username']?.toString() ?? '',
//       role: json['role']?.toString() ?? json['role_name']?.toString() ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'user_role_id': userRoleId,
//       'created_by': createdBy,
//       'modified_by': modifiedBy,
//       'is_active': isActive,
//       'assigned_at': assignedAt.toIso8601String(),
//       'created_at': createdAt.toIso8601String(),
//       'modified_at': modifiedAt.toIso8601String(),
//       'user': user,
//       'role': role,
//     };
//   }
// }

// class UserRoleService {
//   static final UserRoleService _instance = UserRoleService._internal();
//   factory UserRoleService() => _instance;

//   final ApiService _apiService = ApiService();

//   UserRoleService._internal();

//   // -------------------- Get All User Roles --------------------
//   Future<List<UserRoleModel>> getAllUserRoles() async {
//     try {
//       debugPrint('🔍 Fetching all user roles from backend...');
//       final response = await _apiService.dio.get('/roles/user_role/');

//       debugPrint('💡 Response status: ${response.statusCode}');
//       debugPrint('💡 Response data: ${response.data}');

//       List<dynamic> dataList;

//       if (response.data is List) {
//         dataList = response.data;
//       } else if (response.data is Map<String, dynamic> &&
//           response.data.containsKey('data')) {
//         dataList = response.data['data'];
//       } else {
//         // if single object returned, wrap it
//         dataList = [response.data];
//       }

//       final userRoles = dataList
//           .map((e) => UserRoleModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList();

//       debugPrint('✅ Fetched ${userRoles.length} user roles');
//       return userRoles;
//     } on DioException catch (e) {
//       debugPrint('❌ DioException getAllUserRoles: ${e.message}');
//       debugPrint('Full error data: ${e.response?.data}');
//       throw Exception('Error fetching user roles: ${e.message}');
//     } catch (e) {
//       debugPrint('❌ Unexpected error getAllUserRoles: $e');
//       rethrow;
//     }
//   }

//   // -------------------- Get All Users --------------------
//   // Returns normalized list: [{ 'id': int, 'username': String, 'email': String }]
//   Future<List<Map<String, dynamic>>> getAllUsers() async {
//     try {
//       debugPrint('👥 Fetching all users from backend...');

//       final prefs = await SharedPreferences.getInstance();
//       final companyId = prefs.getString('companyId');

//       if (companyId == null || companyId.isEmpty) {
//         debugPrint('⚠️ No companyId found in local storage');
//         throw Exception('Company ID not found');
//       }

//       debugPrint('🏢 Using company_id: $companyId');

//       // ✅ Hit endpoint with company_id param
//       final response = await _apiService.dio.get(
//         '/user/create-user/',
//         queryParameters: {'company_id': companyId},
//       );

//       debugPrint('💡 Users Response Status: ${response.statusCode}');
//       debugPrint('💡 Users Response Data: ${response.data}');

//       // Normalize response data
//       List<dynamic> dataList;
//       if (response.data is List) {
//         dataList = response.data;
//       } else if (response.data is Map<String, dynamic> &&
//           response.data.containsKey('data')) {
//         dataList = response.data['data'];
//       } else if (response.data is Map<String, dynamic> &&
//           response.data.containsKey('users')) {
//         dataList = response.data['users'];
//       } else {
//         debugPrint('⚠️ Unexpected users response format: ${response.data}');
//         throw Exception('Unexpected response format: ${response.data}');
//       }

//       // ✅ Map user data into consistent format
//       final users = dataList.map((user) {
//         return {
//           'id': user['id']?.toString() ?? user['user_id']?.toString() ?? '',
//           'username':
//               user['username']?.toString() ??
//               user['name']?.toString() ??
//               user['email']?.toString() ??
//               'Unknown User',
//           'email': user['email']?.toString() ?? '',
//         };
//       }).toList();

//       debugPrint('✅ Total Users Fetched: ${users.length}');
//       for (var u in users) {
//         debugPrint('👤 ${u['username']} (${u['id']})');
//       }

//       return users;
//     } on DioException catch (e) {
//       debugPrint('❌ DioException while fetching users: ${e.message}');
//       debugPrint('Full error data: ${e.response?.data}');
//       return [];
//     } catch (e) {
//       debugPrint('❌ Unexpected error fetching users: $e');
//       return [];
//     }
//   }

//   // -------------------- Create User Role --------------------
//   // Backend expects: { "user": <int>, "role": <int> }
//   Future<UserRoleModel> createUserRole({
//     required int userId,
//     required int roleId,
//   }) async {
//     try {
//       debugPrint('➕ Creating user role: userId=$userId roleId=$roleId');
//       final response = await _apiService.dio.post(
//         '/roles/user_role/',
//         data: {'user': userId, 'role': roleId},
//       );

//       debugPrint('Create response status: ${response.statusCode}');
//       debugPrint('Create response data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseData = response.data;
//         if (responseData is Map<String, dynamic> &&
//             responseData.containsKey('data')) {
//           responseData = responseData['data'];
//         }
//         return UserRoleModel.fromJson(Map<String, dynamic>.from(responseData));
//       } else {
//         throw Exception('Failed to create user role: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       debugPrint(
//         '❌ DioException createUserRole: ${e.response?.data ?? e.message}',
//       );
//       throw Exception(e.response?.data ?? e.message);
//     } catch (e) {
//       debugPrint('❌ Unexpected createUserRole error: $e');
//       rethrow;
//     }
//   }

//   // -------------------- Update User Role --------------------
//   // Backend expects: { "role": <int> }
//   Future<UserRoleModel> updateUserRole({
//     required int userRoleId,
//     required int roleId,
//     required int userId,
//   }) async {
//     try {
//       debugPrint('✏️ Updating user role ID $userRoleId to roleId: $roleId');
//       final response = await _apiService.dio.put(
//         '/roles/user_role/$userRoleId/',
//         data: {'role': roleId, 'user': userId},
//       );

//       debugPrint('Update response status: ${response.statusCode}');
//       debugPrint('Update response data: ${response.data}');

//       if (response.statusCode == 200) {
//         var responseData = response.data;
//         if (responseData is Map<String, dynamic> &&
//             responseData.containsKey('data')) {
//           responseData = responseData['data'];
//         }
//         return UserRoleModel.fromJson(Map<String, dynamic>.from(responseData));
//       } else {
//         throw Exception('Failed to update user role: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       debugPrint(
//         '❌ DioException updateUserRole: ${e.response?.data ?? e.message}',
//       );
//       throw Exception(e.response?.data ?? e.message);
//     } catch (e) {
//       debugPrint('❌ Unexpected updateUserRole error: $e');
//       rethrow;
//     }
//   }

//   // -------------------- Delete User Role --------------------
//   Future<bool> deleteUserRole(int userRoleId) async {
//     try {
//       debugPrint('🗑️ Deleting user role ID: $userRoleId');
//       final response = await _apiService.dio.delete(
//         '/roles/user_role/$userRoleId/',
//       );

//       debugPrint('Delete response status: ${response.statusCode}');
//       debugPrint('Delete response data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         return true;
//       } else {
//         throw Exception('Failed to delete user role: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       debugPrint(
//         '❌ DioException deleteUserRole: ${e.response?.data ?? e.message}',
//       );
//       throw Exception(e.response?.data ?? e.message);
//     }
//   }

//   // -------------------- Get Available Roles (normalized) --------------------
//   // Returns List<Map<String,dynamic>> with keys: id (int), name (String)
//   Future<List<Map<String, dynamic>>> getAvailableRoles() async {
//     try {
//       debugPrint('📋 Fetching available roles...');
//       final response = await _apiService.dio.get('/roles/create/');

//       debugPrint('Roles response status: ${response.statusCode}');
//       debugPrint('Roles response data: ${response.data}');

//       if (response.statusCode == 200) {
//         final data = response.data;
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data is Map<String, dynamic> && data.containsKey('data')) {
//           list = data['data'];
//         } else {
//           list = [];
//         }

//         final roles = <Map<String, dynamic>>[];
//         for (var item in list) {
//           if (item is Map<String, dynamic>) {
//             final idVal = item['role_id'] ?? item['id'];
//             final id = idVal is int
//                 ? idVal
//                 : int.tryParse(idVal?.toString() ?? '');
//             final name = (item['name'] ?? item['role_name'] ?? '').toString();
//             if (id != null && name.isNotEmpty) {
//               roles.add({'id': id, 'name': name});
//             }
//           }
//         }

//         debugPrint('✅ Extracted ${roles.length} roles');
//         return roles;
//       } else {
//         debugPrint(
//           '⚠️ Unexpected status code for roles: ${response.statusCode}',
//         );
//         return [];
//       }
//     } on DioException catch (e) {
//       debugPrint(
//         '❌ DioException getAvailableRoles: ${e.response?.data ?? e.message}',
//       );
//       return [];
//     } catch (e) {
//       debugPrint('❌ Unexpected getAvailableRoles error: $e');
//       return [];
//     }
//   }
// }
