// Services/Organization_services/organization_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Base_URL/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationService {
  static final OrganizationService _instance = OrganizationService._internal();
  factory OrganizationService() => _instance;

  late Dio _dio;
  static const String baseUrl = Appconfig.baseURL;

  OrganizationService._internal() {
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

          debugPrint('╔════════════════════════════════════════════════════════');
          debugPrint('║ REQUEST[${options.method}] => ${options.path}');
          debugPrint('║ Headers: ${options.headers}');
          debugPrint('║ Data: ${options.data}');
          debugPrint('╚════════════════════════════════════════════════════════');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('╔════════════════════════════════════════════════════════');
          debugPrint('║ RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
          debugPrint('║ Data: ${response.data}');
          debugPrint('╚════════════════════════════════════════════════════════');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('╔════════════════════════════════════════════════════════');
          debugPrint('║ ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}');
          debugPrint('║ Message: ${error.message}');
          debugPrint('║ Response Data: ${error.response?.data}');
          debugPrint('╚════════════════════════════════════════════════════════');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // -------------------- Get All Organizations --------------------
  Future<Response> getAllOrganizations() async {
    try {
      return await _dio.get('/user/company/');
    } on DioException catch (e) {
      debugPrint('❌ Get all organizations error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Get Organization By ID --------------------
  Future<Response> getOrganizationById(String id) async {
    try {
      return await _dio.get('/user/company/$id/');
    } on DioException catch (e) {
      debugPrint('❌ Get organization by ID error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Create Organization --------------------
  Future<Response> createOrganization(Map<String, dynamic> organizationData) async {
    try {
      return await _dio.post('/user/company/', data: organizationData);
    } on DioException catch (e) {
      debugPrint('❌ Create organization error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Update Organization --------------------
  Future<Response> updateOrganization(String id, Map<String, dynamic> organizationData) async {
    try {
      return await _dio.put('/user/company/$id/', data: organizationData);
    } on DioException catch (e) {
      debugPrint('❌ Update organization error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Delete Organization --------------------
  Future<Response> deleteOrganization(String id) async {
    try {
      return await _dio.delete('/user/company/$id/');
    } on DioException catch (e) {
      debugPrint('❌ Delete organization error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Check Organization Exists --------------------
  Future<Response> checkOrganizationExists(String id, Map<String, dynamic> checkData) async {
    try {
      return await _dio.post('/user/company/$id', data: checkData);
    } on DioException catch (e) {
      debugPrint('❌ Check organization exists error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Get Roles --------------------
  Future<Response> getRoles() async {
    try {
      return await _dio.get('/roles/create');
    } on DioException catch (e) {
      debugPrint('❌ Get roles error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Add User to Organization --------------------
  Future<Response> addUser(Map<String, dynamic> userData) async {
    try {
      debugPrint('📤 Sending user data to API: $userData');
      final response = await _dio.post('/user/create-user/', data: userData);
      debugPrint('✅ API Response: ${response.statusCode} - ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Add user error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Get Users by Organization --------------------
  Future<Response> getUsers(String? organizationId) async {
    try {
      if (organizationId != null) {
        return await _dio.get('/user/create-user/', queryParameters: {'company_id': organizationId});
      }
      return await _dio.get('/user/create-user/');
    } on DioException catch (e) {
      debugPrint('❌ Get users error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Update User --------------------
  Future<Response> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      return await _dio.put('/user/create-user/$userId/', data: userData);
    } on DioException catch (e) {
      debugPrint('❌ Update user error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Delete User --------------------
  Future<Response> deleteUser(String userId) async {
    try {
      return await _dio.delete('/user/create-user/$userId/');
    } on DioException catch (e) {
      debugPrint('❌ Delete user error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Search Organizations --------------------
  Future<Response> searchOrganizations(String query) async {
    try {
      return await _dio.get('/organizations/search', queryParameters: {'q': query});
    } on DioException catch (e) {
      debugPrint('❌ Search organizations error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Get Organization Stats --------------------
  Future<Response> getOrganizationStats(String organizationId) async {
    try {
      return await _dio.get('/organizations/$organizationId/stats');
    } on DioException catch (e) {
      debugPrint('❌ Get organization stats error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Get My Organizations --------------------
  Future<Response> getMyOrganizations() async {
    try {
      return await _dio.get('/organizations/my');
    } on DioException catch (e) {
      debugPrint('❌ Get my organizations error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Error Message Helper --------------------
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
    return 'Unexpected error. Please try again.';
  }
}