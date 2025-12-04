import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';

class VisitorApiService {
  final ApiService _apiService = ApiService();

  // Get all visitors for a company
  Future<Response> getVisitors(int companyId) async {
    try {
      final isSuperUser = await _apiService.isSuperUser();
      debugPrint('🔍 Fetching visitors. Is SuperUser: $isSuperUser');

      String endpoint;
      if (isSuperUser) {
        endpoint = '/visitors/visitors/';
      } else {
        endpoint = '/visitors/company/$companyId/visitors/';
      }

      debugPrint('🔍 Fetching visitors from: $endpoint');
      final response = await _apiService.dio.get(endpoint);
      
      debugPrint('✅ Visitors fetched successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching visitors: ${e.message}');
      rethrow;
    }
  }

  // Create a new visitor
  Future<Response> createVisitor(Map<String, dynamic> visitorData) async {
    try {
      debugPrint('➕ Creating new visitor');
      debugPrint('Data: $visitorData');

      // ✅ Ensure required fields are included
      final cleanedData = {
        ...visitorData,
        'pass_type': (visitorData['pass_type'] ?? 'ONE_TIME')
            .toString()
            .toUpperCase(),
      };

      final response = await _apiService.dio.post(
        '/visitors/visitors/',
        data: cleanedData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('✅ Visitor created successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error creating visitor: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    }
  }

  // Get single visitor details
  Future<Response> getVisitorDetails(String visitorId) async {
    try {
      debugPrint('🔍 Fetching visitor details: $visitorId');
      final response = await _apiService.dio.get(
        '/visitors/visitors/$visitorId/',
      );
      debugPrint('✅ Visitor details fetched successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching visitor details: ${e.message}');
      rethrow;
    }
  }

  /// Get categories from backend
  Future<Response> getCategories() async {
    try {
      debugPrint('🔍 Fetching visitor categories');
      final response = await _apiService.dio.get('/visitors/categories/');
      debugPrint('✅ Categories fetched: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching categories: ${e.message}');
      rethrow;
    }
  }

  // Approve visitor
  Future<Response> approveVisitor(String visitorId) async {
    try {
      debugPrint('✅ Approving visitor: $visitorId');
      final response = await _apiService.dio.post(
        '/visitors/visitors/$visitorId/approval/',
        data: {"action": "approve"}, // ✅ FIXED: Send correct body
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      debugPrint('✅ Visitor approved successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error approving visitor: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    }
  }

  // Reject visitor
  Future<Response> rejectVisitor(String visitorId) async {
    try {
      debugPrint('❌ Rejecting visitor: $visitorId');
      final response = await _apiService.dio.post(
        '/visitors/visitors/$visitorId/approval/', // ✅ Same endpoint
        data: {"action": "reject"}, // ✅ FIXED
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      debugPrint('✅ Visitor rejected successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error rejecting visitor: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    }
  }

  // Reschedule visitor
  Future<Response> rescheduleVisitor({
    required String visitorId,
    required String newDate,
    required String newTime,
  }) async {
    try {
      debugPrint('📅 Rescheduling visitor: $visitorId');
      final response = await _apiService.dio.post(
        '/visitors/visitors/$visitorId/reschedule/',
        data: {'new_date': newDate, 'new_time': newTime},
      );
      debugPrint('✅ Visitor rescheduled successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error rescheduling visitor: ${e.message}');
      rethrow;
    }
  }

  // Check-in visitor (Entry)
  Future<Response> checkInVisitor({
    required String passId,
    required String otp,
    String? notes,
  }) async {
    try {
      debugPrint('🚪 Checking in visitor: $passId');
      final response = await _apiService.dio.post(
        '/visitors/visitors/$passId/entry-exit/',
        data: {
          'otp': otp,
          'action': 'entry',
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      debugPrint('✅ Visitor checked in successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error checking in visitor: ${e.message}');
      rethrow;
    }
  }

  // Check-out visitor (Exit)
  Future<Response> checkOutVisitor({
    required String passId,
    required String otp,
    String? notes,
  }) async {
    try {
      debugPrint('🚪 Checking out visitor: $passId');
      final response = await _apiService.dio.post(
        '/visitors/visitors/$passId/entry-exit/',
        data: {
          'otp': otp,
          'action': 'exit',
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      debugPrint('✅ Visitor checked out successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error checking out visitor: ${e.message}');
      rethrow;
    }
  }

  // Update visitor status (approve/reject)
  Future<Response> updateVisitorStatus({
    required String visitorId,
    required String status,
  }) async {
    try {
      debugPrint('🔄 Updating visitor status: $visitorId to $status');
      final response = await _apiService.dio.patch(
        '/visitors/visitors/$visitorId/',
        data: {'status': status},
      );
      debugPrint('✅ Visitor status updated successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error updating visitor status: ${e.message}');
      rethrow;
    }
  }

  // Delete visitor
  Future<Response> deleteVisitor(String visitorId) async {
    try {
      debugPrint('🗑️ Deleting visitor: $visitorId');
      final response = await _apiService.dio.delete(
        '/visitors/visitors/$visitorId/',
      );
      debugPrint('✅ Visitor deleted successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error deleting visitor: ${e.message}');
      rethrow;
    }
  }

  // Helper to get error message
  String getErrorMessage(DioException error) {
    return _apiService.getErrorMessage(error);
  }

  // -------------------- Bulk Upload Visitors --------------------
  Future<Response> uploadBulkVisitors(
    List<Map<String, dynamic>> visitors,
  ) async {
    try {
      debugPrint("📤 Uploading bulk visitors...");

      final response = await _apiService.dio.post(
        '/reports/bulk-upload-visitors/',
        data: {'visitors': visitors},
      );

      debugPrint("✅ Bulk upload success");
      return response;
    } on DioException catch (e) {
      debugPrint("❌ Bulk upload error: ${e.message}");
      rethrow;
    }
  }
}
