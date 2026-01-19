// user_role_model.dart

class UserRoleModel {
  final int userRoleId;
  final int userId;
  final int roleId;
  final int? companyId; // ✅ Added company ID
  final String username;
  final String rolename;
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
    this.companyId,
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
    // Try to parse company ID from various possible keys
    int? parseCompanyId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    return UserRoleModel(
      userRoleId: json['user_role_id'] ?? 0,
      userId: json['user'] ?? 0,
      roleId: json['role'] ?? 0,
      companyId: parseCompanyId(json['company'] ?? json['company_id']),
      username:
          json['user_name']?.toString() ??
          '',
      rolename:
          json['role_name']?.toString() ??
          '',
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
      'company': companyId,
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
