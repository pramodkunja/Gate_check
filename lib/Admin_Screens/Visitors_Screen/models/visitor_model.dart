import 'dart:ui';

class Visitor {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String category;
  final String passType;
  final DateTime visitingDate;
  final String visitingTime;
  final String purpose;
  final String whomToMeet;
  final String comingFrom;
  final VisitorStatus status;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final String? belongingsTools;
  final String? securityNotes;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? gender;
  final int? allowingHours;

  Visitor({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.category,
    required this.passType,
    required this.visitingDate,
    required this.visitingTime,
    required this.purpose,
    required this.whomToMeet,
    required this.comingFrom,
    required this.status,
    this.isCheckedIn = false,
    this.isCheckedOut = false,
    this.belongingsTools,
    this.securityNotes,
    this.vehicleType,
    this.vehicleNumber,
    this.gender,
    this.allowingHours,
  });

  bool get isPast {
    final now = DateTime.now();
    final visitDateTime = DateTime(
      visitingDate.year,
      visitingDate.month,
      visitingDate.day,
      int.parse(visitingTime.split(':')[0]),
      int.parse(visitingTime.split(':')[1]),
    );
    return now.isAfter(visitDateTime) && !isCheckedIn && !isCheckedOut;
  }

  Visitor copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? category,
    String? passType,
    DateTime? visitingDate,
    String? visitingTime,
    String? purpose,
    String? whomToMeet,
    String? comingFrom,
    VisitorStatus? status,
    bool? isCheckedIn,
    bool? isCheckedOut,
    String? belongingsTools,
    String? securityNotes,
    String? vehicleType,
    String? vehicleNumber,
    String? gender,
    int? allowingHours,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      passType: passType ?? this.passType,
      visitingDate: visitingDate ?? this.visitingDate,
      visitingTime: visitingTime ?? this.visitingTime,
      purpose: purpose ?? this.purpose,
      whomToMeet: whomToMeet ?? this.whomToMeet,
      comingFrom: comingFrom ?? this.comingFrom,
      status: status ?? this.status,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      belongingsTools: belongingsTools ?? this.belongingsTools,
      securityNotes: securityNotes ?? this.securityNotes,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      gender: gender ?? this.gender,
      allowingHours: allowingHours ?? this.allowingHours,
    );
  }
}

enum VisitorStatus {
  approved,
  pending,
  rejected,
}

extension VisitorStatusExtension on VisitorStatus {
  String get displayName {
    switch (this) {
      case VisitorStatus.approved:
        return 'Approved';
      case VisitorStatus.pending:
        return 'Pending';
      case VisitorStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case VisitorStatus.approved:
        return const Color(0xFF4CAF50);
      case VisitorStatus.pending:
        return const Color(0xFFFFA726);
      case VisitorStatus.rejected:
        return const Color(0xFFEF5350);
    }
  }
}