// user_role_model.dart

class UserRoleModel {
  final int userRoleId;
  final int userId;
  final int roleId;
  final String username; // This will store user_name from API
  final String rolename; // This will store role_name from API
  final String? createdBy;
  final String? modifiedBy;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime assignedAt;
  final bool isActive;

  UserRoleModel({
    required this.userRoleId,
    required this.userId,
    required this.roleId,
    required this.username,
    required this.rolename,
    this.createdBy,
    this.modifiedBy,
    required this.createdAt,
    required this.modifiedAt,
    required this.assignedAt,
    required this.isActive,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      userRoleId: json['user_role_id'] ?? 0,
      userId: json['user'] ?? 0, // ✅ This is the user ID (integer)
      roleId: json['role'] ?? 0, // ✅ This is the role ID (integer)
      username:
          json['user_name']?.toString() ??
          '', // ✅ Changed from 'user' to 'user_name'
      rolename:
          json['role_name']?.toString() ??
          '', // ✅ Changed from 'role' to 'role_name'
      createdBy: json['created_by']?.toString(),
      modifiedBy: json['modified_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : DateTime.now(),
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_role_id': userRoleId,
      'user': userId,
      'role': roleId,
      'user_name': username,
      'role_name': rolename,
      'created_by': createdBy,
      'modified_by': modifiedBy,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'assigned_at': assignedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
