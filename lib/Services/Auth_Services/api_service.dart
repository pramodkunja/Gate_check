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
      '/login/otp-request/',
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

  // -------------------- Reset Password (Change Password) --------------------
  Future<Response> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _dio.post(
      '/login/reset-password/',
      data: {
        'old_password': oldPassword,
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
    final response = error.response;

    if (response?.data != null) {
      final data = response!.data;

      // If backend returned a plain string
      if (data is String && data.isNotEmpty) return data;

      // If backend returned a map, try common keys first
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('non_field_errors')) {
          final v = data['non_field_errors'];
          if (v is List) return v.map((e) => e.toString()).join('; ');
          return v.toString();
        }

        // Validation style errors: { field: ["err"] }
        if (data.containsKey('errors')) {
          final v = data['errors'];
          if (v is String) return v;
          if (v is Map) {
            final messages = <String>[];
            v.forEach((key, val) {
              if (val is List)
                messages.add('$key: ${val.join(", ")}');
              else
                messages.add('$key: ${val.toString()}');
            });
            return messages.join('; ');
          }
          if (v is List) return v.map((e) => e.toString()).join('; ');
        }

        // Fallback: collect first-level values into a readable string
        final messages = <String>[];
        data.forEach((k, v) {
          if (v == null) return;
          if (v is List) {
            messages.add('$k: ${v.map((e) => e.toString()).join(", ")}');
          } else {
            messages.add('$k: ${v.toString()}');
          }
        });
        if (messages.isNotEmpty) return messages.join('; ');
      }

      // If backend returned an array
      if (data is List && data.isNotEmpty) {
        return data.map((e) => e.toString()).join('; ');
      }
    }

    // Network / Dio level errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request send timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badResponse:
        // If we reach here but didn't parse data above, include status code
        return 'Server error (${response?.statusCode ?? 'unknown'}). Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
