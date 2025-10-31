// lib/services/user_service.dart

class UserService {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // In-memory user storage (replace with actual API calls later)
  final List<Map<String, dynamic>> _registeredUsers = [
    {
      'id': '1',
      'email': 'akshithayellanki@gmail.com',
      'password': 'password123', // In production, store hashed passwords
      'name': 'Akshitha',
      'role': 'Admin',
      'companyName': 'Sria Infotech Pvt Ltd',
      'mobileNumber': '1234567890',
      'block': '4',
      'floor': '2',
    },
    {
      'id': '2',
      'email': 'vineetherramalla31@gmail.com',
      'password': 'password123',
      'name': 'Vineeth',
      'role': 'Manager',
      'companyName': 'Sria Infotech Pvt Ltd',
      'mobileNumber': '0987654321',
    },
    {
      'id': '3',
      'email': 'john.doe@example.com',
      'password': 'password123',
      'name': 'John Doe',
      'role': 'Developer',
      'companyName': 'Patil',
      'mobileNumber': '123-456-7890',
    },
    {
      'id': '4',
      'email': 'jane.smith@example.com',
      'password': 'password123',
      'name': 'Jane Smith',
      'role': 'Designer',
      'companyName': 'Patil',
      'mobileNumber': '987-654-3210',
    },
  ];

  Map<String, dynamic>? _currentUser;

  // Get all registered users
  List<Map<String, dynamic>> getAllUsers() {
    return List.from(_registeredUsers);
  }

  // Add a new user (called when adding user in Organization Management)
  void addUser(Map<String, dynamic> user) {
    _registeredUsers.add(user);
  }

  // Update user information
  void updateUser(String userId, Map<String, dynamic> updatedData) {
    final index = _registeredUsers.indexWhere((user) => user['id'] == userId);
    if (index != -1) {
      _registeredUsers[index] = {..._registeredUsers[index], ...updatedData};
    }
  }

  // Remove user
  void removeUser(String userId) {
    _registeredUsers.removeWhere((user) => user['id'] == userId);
  }

  // Authenticate user
  Future<Map<String, dynamic>?> authenticateUser(
      String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = _registeredUsers.firstWhere(
        (user) =>
            user['email']?.toLowerCase() == email.toLowerCase() &&
            user['password'] == password,
      );
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  // Check if email exists
  bool emailExists(String email) {
    return _registeredUsers
        .any((user) => user['email']?.toLowerCase() == email.toLowerCase());
  }

  // Get current logged-in user
  Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  // Get user name
  String getUserName() {
    return _currentUser?['name'] ?? 'User';
  }

  // Get user email
String getUserEmail() {
  return _currentUser?['email'] ?? '';
}

  // Get user role
  String getUserRole() {
    return _currentUser?['role'] ?? '';
  }

  // Set current user (for login)
  void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Check if user is admin
  bool isAdmin() {
    return _currentUser?['role']?.toLowerCase() == 'admin';
  }

  // Get user by email
  Map<String, dynamic>? getUserByEmail(String email) {
    try {
      return _registeredUsers.firstWhere(
        (user) => user['email']?.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Map<String, dynamic>? getUserById(String id) {
    try {
      return _registeredUsers.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Update user password
  bool updatePassword(String email, String newPassword) {
    final user = getUserByEmail(email);
    if (user != null) {
      updateUser(user['id'], {'password': newPassword});
      return true;
    }
    return false;
  }

  // Get users by company
  List<Map<String, dynamic>> getUsersByCompany(String companyName) {
    return _registeredUsers
        .where((user) => user['companyName'] == companyName)
        .toList();
  }

  // Get users by role
  List<Map<String, dynamic>> getUsersByRole(String role) {
    return _registeredUsers
        .where((user) => user['role']?.toLowerCase() == role.toLowerCase())
        .toList();
  }
}