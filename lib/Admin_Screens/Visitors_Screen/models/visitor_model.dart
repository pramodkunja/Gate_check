import 'package:flutter/material.dart';

class Visitor {
  final String id;
  final String passId;
  final String name;
  final String phone;
  final String email;
  final String? gender;
  final String category;
  final int? categoryId;
  final CategoryDetails? categoryDetails;
  final String passType;
  final DateTime visitingDate;
  final String visitingTime;
  final int? recurringDays;
  final int? allowingHours;
  final String purpose;
  final String whomToMeet;
  final String comingFrom;
  final String? companyDetails;
  final String? belongingsTools;
  final String? securityNotes;
  final String? vehicleType;
  final String? vehicleNumber;
  final int? vehicleId;
  final VehicleDetails? vehicleDetails;
  final VisitorStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final bool isInside;
  final bool isCheckedOut;
  final String? qrCodeUrl;
  final bool canEnter;
  final String? company;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? logs;

  Visitor({
    required this.id,
    String? passId,
    required this.name,
    required this.phone,
    required this.email,
    this.gender,
    required this.category,
    this.categoryId,
    this.categoryDetails,
    required this.passType,
    required this.visitingDate,
    required this.visitingTime,
    this.recurringDays,
    this.allowingHours,
    required this.purpose,
    required this.whomToMeet,
    required this.comingFrom,
    this.companyDetails,
    this.belongingsTools,
    this.securityNotes,
    this.vehicleType,
    this.vehicleNumber,
    this.vehicleId,
    this.vehicleDetails,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.entryTime,
    this.exitTime,
    this.isInside = false,
    this.isCheckedOut = false,
    this.qrCodeUrl,
    this.canEnter = false,
    this.company,
    this.createdAt,
    this.updatedAt,
    this.logs,
  }) : passId = passId ?? 'VP${DateTime.now().millisecondsSinceEpoch}';

  factory Visitor.fromJson(Map<String, dynamic> json) {
  return Visitor(
    id: json['id']?.toString() ?? '',
    passId: json['pass_id']?.toString() ?? '',
    name: json['visitor_name']?.toString() ?? '',
    phone: json['mobile_number']?.toString() ?? '',
    email: json['email_id']?.toString() ?? '',
    gender: json['gender']?.toString(),
    category: json['category_details']?['name']?.toString() ??
        json['category_name']?.toString() ??
        'Unknown',
    categoryId: json['category'] is int
        ? json['category']
        : int.tryParse(json['category']?.toString() ?? ''),
    categoryDetails: json['category_details'] != null
        ? CategoryDetails.fromJson(json['category_details'])
        : null,
    passType: _parsePassType(json['pass_type']),
    visitingDate: DateTime.parse(json['visiting_date'].toString()),
    visitingTime: json['visiting_time']?.toString() ?? '',
    recurringDays: json['recurring_days'] is int
        ? json['recurring_days']
        : int.tryParse(json['recurring_days']?.toString() ?? ''),
    allowingHours: json['allowing_hours'] is int
        ? json['allowing_hours']
        : int.tryParse(json['allowing_hours']?.toString() ?? ''),
    purpose: json['purpose_of_visit']?.toString() ?? '',
    whomToMeet: json['whom_to_meet']?.toString() ?? '',
    comingFrom: json['coming_from']?.toString() ?? '',
    companyDetails: json['company_details']?.toString(),
    belongingsTools: json['belongings_tools']?.toString(),
    securityNotes: json['security_notes']?.toString(),
    vehicleId: json['vehicle'] is int
        ? json['vehicle']
        : int.tryParse(json['vehicle']?.toString() ?? ''),
    vehicleDetails: json['vehicle_details'] != null
        ? VehicleDetails.fromJson(json['vehicle_details'])
        : null,
    status: _parseStatus(json['status']),
    approvedBy: json['approved_by']?.toString(),
    approvedAt: json['approved_at'] != null
        ? DateTime.tryParse(json['approved_at'].toString())
        : null,
    entryTime: json['entry_time'] != null
        ? DateTime.tryParse(json['entry_time'].toString())
        : null,
    exitTime: json['exit_time'] != null
        ? DateTime.tryParse(json['exit_time'].toString())
        : null,
    isInside: json['is_inside'] ?? false,
    isCheckedOut: json['exit_time'] != null,
    qrCodeUrl: json['qr_code_url']?.toString(),
    canEnter: json['can_enter'] ?? false,
    company: json['company']?.toString(),
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
    logs: json['logs'],
  );
}


  Map<String, dynamic> toJson() {
    return {
      'visitor_name': name,
      'mobile_number': phone,
      'email_id': email,
      if (gender != null) 'gender': gender == 'Male' ? 'M' : gender == 'Female' ? 'F' : 'O',
      'visiting_date': '${visitingDate.year}-${visitingDate.month.toString().padLeft(2, '0')}-${visitingDate.day.toString().padLeft(2, '0')}',
      'visiting_time': visitingTime.length == 5 ? '$visitingTime:00' : visitingTime,
      if (recurringDays != null) 'recurring_days': recurringDays,
      if (allowingHours != null) 'allowing_hours': allowingHours,
      if (categoryId != null) 'category': categoryId,
      'whom_to_meet': whomToMeet,
      'coming_from': comingFrom,
      if (companyDetails != null) 'company_details': companyDetails,
      if (belongingsTools != null && belongingsTools!.isNotEmpty) 
        'belongings_tools': belongingsTools,
      'purpose_of_visit': purpose,
      if (vehicleId != null) 'vehicle': vehicleId,
      if (securityNotes != null && securityNotes!.isNotEmpty) 
        'security_notes': securityNotes,
    };
  }

  static String _parsePassType(dynamic passType) {
  if (passType == null) return 'ONE_TIME';
  final type = passType.toString().toUpperCase();

  if (type == 'ONE_TIME' || type == 'RECURRING' || type == 'PERMANENT') {
    return type;
  }

  // fallback to ONE_TIME if backend sends unexpected values
  return 'ONE_TIME';
}


  static VisitorStatus _parseStatus(dynamic status) {
    if (status == null) return VisitorStatus.pending;
    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'APPROVED':
        return VisitorStatus.approved;
      case 'REJECTED':
        return VisitorStatus.rejected;
      default:
        return VisitorStatus.pending;
    }
  }

  Visitor copyWith({
    String? id,
    String? passId,
    String? name,
    String? phone,
    String? email,
    String? gender,
    String? category,
    int? categoryId,
    CategoryDetails? categoryDetails,
    String? passType,
    DateTime? visitingDate,
    String? visitingTime,
    int? recurringDays,
    int? allowingHours,
    String? purpose,
    String? whomToMeet,
    String? comingFrom,
    String? companyDetails,
    String? belongingsTools,
    String? securityNotes,
    String? vehicleType,
    String? vehicleNumber,
    int? vehicleId,
    VehicleDetails? vehicleDetails,
    VisitorStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? entryTime,
    DateTime? exitTime,
    bool? isInside,
    bool? isCheckedOut,
    String? qrCodeUrl,
    bool? canEnter,
    String? company,
  }) {
    return Visitor(
      id: id ?? this.id,
      passId: passId ?? this.passId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      categoryDetails: categoryDetails ?? this.categoryDetails,
      passType: passType ?? this.passType,
      visitingDate: visitingDate ?? this.visitingDate,
      visitingTime: visitingTime ?? this.visitingTime,
      recurringDays: recurringDays ?? this.recurringDays,
      allowingHours: allowingHours ?? this.allowingHours,
      purpose: purpose ?? this.purpose,
      whomToMeet: whomToMeet ?? this.whomToMeet,
      comingFrom: comingFrom ?? this.comingFrom,
      companyDetails: companyDetails ?? this.companyDetails,
      belongingsTools: belongingsTools ?? this.belongingsTools,
      securityNotes: securityNotes ?? this.securityNotes,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      isInside: isInside ?? this.isInside,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      canEnter: canEnter ?? this.canEnter,
      company: company ?? this.company,
      createdAt: createdAt,
      updatedAt: updatedAt,
      logs: logs,
    );
  }
}

class CategoryDetails {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  CategoryDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory CategoryDetails.fromJson(Map<String, dynamic> json) {
    return CategoryDetails(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class VehicleDetails {
  final int id;
  final String vehicleType;
  final String vehicleNumber;

  VehicleDetails({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      id: json['id'],
      vehicleType: json['vehicle_type'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
    );
  }
}

enum VisitorStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case VisitorStatus.pending:
        return 'Pending';
      case VisitorStatus.approved:
        return 'Approved';
      case VisitorStatus.rejected:
        return 'Rejected';
    }
  }

  String get apiValue => name.toUpperCase();

  Color get color {
    switch (this) {
      case VisitorStatus.pending:
        return Colors.orange;
      case VisitorStatus.approved:
        return Colors.green;
      case VisitorStatus.rejected:
        return Colors.red;
    }
  }
}


extension VisitorHelpers on Visitor {
  bool get isPast => visitingDate.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  bool get isCheckedIn => entryTime != null && exitTime == null;
}
