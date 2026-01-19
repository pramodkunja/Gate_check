// models/organization.dart
class Organization {
  final String id;
  String name;
  String location;
  String pinCode;
  String address;
  List<User> users;

  Organization({
    required this.id,
    required this.name,
    required this.location,
    required this.pinCode,
    required this.address,
    List<User>? users,
  }) : users = users ?? [];

  int get memberCount => users.length;
}

// models/user.dart
class User {
  final String id;
  String username;
  String email;
  String mobileNumber;
  String companyName;
  String role;
  String? aliasName;
  String? block;
  String? floor;
  bool isActive;
  DateTime? dateAdded;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.mobileNumber,
    required this.companyName,
    required this.role,
    this.aliasName,
    this.block,
    this.floor,
    this.isActive = true,
    this.dateAdded,
  });
}