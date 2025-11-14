import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatecheck/Services/Base_URL/base_url.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  static const String baseUrl = Appconfig.baseURL;

  ApiService._internal() {
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

    // Interceptors for token handling and logging
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
        onError: (error, handler) async {
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

          // 🔄 Auto-refresh token if expired
          if (error.response?.statusCode == 401) {
            final isRefreshed = await _refreshAccessToken();
            if (isRefreshed) {
              final req = error.requestOptions;
              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('authToken');

              req.headers['Authorization'] = 'Bearer $newToken';

              try {
                final clonedResponse = await _dio.fetch(req);
                return handler.resolve(clonedResponse);
              } catch (e) {
                return handler.reject(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // -------------------- Validate User --------------------
  Future<Response> validateUser(String identifier) async {
    return await _dio.post(
      '/login/validate/',
      data: {'identifier': identifier},
    );
  }

  // -------------------- Login --------------------
  Future<Response> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login/login/',
        data: {'identifier': identifier, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        final data = response.data['data'];
        final accessToken = data?['access']?.toString();
        final refreshToken = data?['refresh']?.toString();
        final user = data?['user'];

        // ✅ Extract company_id and store it
        final companyId = user?['company_id']?.toString();
        if (companyId != null && companyId.isNotEmpty) {
          await prefs.setString('companyId', companyId);
          debugPrint('🏢 Company ID saved: $companyId');
        } else {
          debugPrint('⚠️ No company_id found in login response');
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          await prefs.setString('authToken', accessToken);
          debugPrint('✅ Access token saved: $accessToken');
        }

        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString('refreshToken', refreshToken);
          debugPrint('✅ Refresh token saved: $refreshToken');
        }
      }

      return response;
    } on DioException catch (e) {
      debugPrint('❌ Login error: ${e.response?.data}');
      rethrow;
    }
  }

  // -------------------- Forgot Password --------------------
  Future<Response> forgotPassword(String identifier) async {
    return await _dio.post(
      '/login/forgot-password/',
      data: {'identifier': identifier},
    );
  }

  // -------------------- Verify OTP --------------------
  Future<Response> verifyOtp(String identifier, String otp) async {
    return await _dio.post(
      '/login/verify-otp/',
      data: {'identifier': identifier, 'otp': otp},
    );
  }

  // -------------------- Set New Password --------------------
  Future<Response> setNewPassword({
    required String identifier,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _dio.post(
      '/login/set-new-password/',
      data: {
        'identifier': identifier,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  // -------------------- Get User Profile --------------------
  Future<Response> getUserProfile() async {
    return await _dio.get('/user/profile/');
  }

  // -------------------- Logout --------------------
  Future<void> logout() async {
    try {
      await _dio.post('/login/logout/');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('refreshToken');
  }

  // -------------------- Token Refresh --------------------
  Future<bool> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('⚠️ No refresh token found.');
      return false;
    }

    try {
      final response = await _dio.post(
        '/login/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access']?.toString();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await prefs.setString('authToken', newAccessToken);
          debugPrint('🔄 Access token refreshed successfully.');
          return true;
        }
      }
    } catch (e) {
      debugPrint('❌ Token refresh failed: $e');
    }

    return false;
  }

  // -------------------- Error Message Helper --------------------
  String getErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return 'Unexpected error. Please try again.';
  }
}
