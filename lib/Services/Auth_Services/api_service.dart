import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Base_URL/base_url.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  static const String baseUrl =  Appconfig.baseURL;

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
        validateStatus: (status) {
          // Accept all status codes < 500 (you’ll still inspect status codes)
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
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
        onError: (error, handler) {
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
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Authentication endpoints

  /// Validate if user exists in the system
  Future<Response> validateUser(String identifier) async {
    try {
      final response = await _dio.post( 
        '/login/validate/',
        data: {'identifier': identifier},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with identifier/email and password
  Future<Response> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final credentials = {'identifier': identifier, 'password': password};
      debugPrint('Attempting login with: $credentials');

      final response = await _dio.post('/login/login/', data: credentials);
      return response;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Request OTP for password reset
  Future<Response> forgotPassword(String identifier) async {
    try {
      final response = await _dio.post(
        '/login/otp-request/',
        data: {'identifier': identifier},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP code
  Future<Response> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/login/verify-otp/',
        data: {'identifier': identifier, 'otp': otp},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Set new password after OTP verification
  Future<Response> setNewPassword({
    required String identifier,
    required String newPassword,
    // optionally confirmPassword if backend needs
    String? confirmPassword,
  }) async {
    try {
      final data = {
        'identifier': identifier,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
      // if (confirmPassword != null) {
      //   data['confirm_password'] = confirmPassword;
      // }
      final response = await _dio.post('/login/set-new-password/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<Response> logout() async {
    try {
      final response = await _dio.post('/login/logout/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to parse error messages from API
  String getErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          final err = data['error'];
          if (err is String) return err;
          if (err is Map) {
            final first = err.values.first;
            if (first is List && first.isNotEmpty) return first[0].toString();
            return first.toString();
          }
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        final errors = <String>[];
        data.forEach((k, v) {
          if (v is List && v.isNotEmpty) {
            errors.add('$k: ${v[0]}');
          } else if (v is String) {
            errors.add(v);
          }
        });
        if (errors.isNotEmpty) return errors.join(', ');
      }
      if (data is String) {
        return data;
      }
    }
    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Incorrect credentials. Please try again.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return 'Connection timeout. Please check your internet.';
        } else if (error.type == DioExceptionType.connectionError) {
          return 'Cannot connect to server. Please try again.';
        }
        return 'An unexpected error occurred.';
    }
  }
}
