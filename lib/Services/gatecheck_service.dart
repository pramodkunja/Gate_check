// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:gatecheck/Services/Auth_Services/api_service.dart';

// class VisitorService {
//   static final VisitorService _instance = VisitorService._internal();
//   factory VisitorService() => _instance;

//   final ApiService _apiService;

//   VisitorService._internal() : _apiService = ApiService();

//   /// Create a new visitor
//   Future<Response> createVisitor(Map<String, dynamic> visitorData) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/',
//         data: visitorData,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Create visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Get all visitors for a company
//   Future<Response> getAllVisitors({
//     required String companyId,
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final response = await _apiService.dio.get(
//         '/visitors/company/$companyId/visitors/',
//         queryParameters: params,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Get all visitors error: $e');
//       rethrow;
//     }
//   }

//   /// Get recurring visitors
//   Future<Response> getRecurringVisitors({Map<String, dynamic>? params}) async {
//     try {
//       final queryParams = params ?? {};
//       queryParams['pass_type'] = 'recurring';

//       final response = await _apiService.dio.get(
//         '/visitors/filter/',
//         queryParameters: queryParams,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Get recurring visitors error: $e');
//       rethrow;
//     }
//   }

//   /// Update visitor
//   Future<Response> updateVisitor(
//     String visitorId,
//     Map<String, dynamic> visitorData,
//   ) async {
//     try {
//       final response = await _apiService.dio.put(
//         '/visitors/$visitorId/',
//         data: visitorData,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Update visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Delete visitor
//   Future<Response> deleteVisitor(String visitorId) async {
//     try {
//       final response = await _apiService.dio.delete(
//         '/visitors/$visitorId/',
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Delete visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Get visitor by ID
//   Future<Response> getVisitorById(String visitorId) async {
//     try {
//       final response = await _apiService.dio.get(
//         '/visitors/$visitorId/',
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Get visitor by ID error: $e');
//       rethrow;
//     }
//   }

//   /// Get visitor categories
//   Future<Response> getCategories() async {
//     try {
//       final response = await _apiService.dio.get('/visitors/categories/');
//       return response;
//     } catch (e) {
//       debugPrint('Get categories error: $e');
//       rethrow;
//     }
//   }

//   /// Approve visitor
//   Future<Response> approveVisitor(String visitorId) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$visitorId/approval/',
//         data: {'action': 'approve'},
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Approve visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Reject visitor
//   Future<Response> rejectVisitor(String visitorId) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$visitorId/reject/',
//         data: {'action': 'reject'},
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Reject visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Filter visitors by status
//   Future<Response> filterByStatus(Map<String, dynamic> params) async {
//     try {
//       final response = await _apiService.dio.get(
//         '/visitors/filter/',
//         queryParameters: params,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Filter by status error: $e');
//       rethrow;
//     }
//   }

//   /// Filter visitors by pass type
//   Future<Response> filterByPassType(
//     String passType, {
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final queryParams = params ?? {};
//       queryParams['pass_type'] = passType;

//       final response = await _apiService.dio.get(
//         '/visitors/filter/',
//         queryParameters: queryParams,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Filter by pass type error: $e');
//       rethrow;
//     }
//   }

//   /// Check-in visitor
//   Future<Response> checkInVisitor(String visitorId) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$visitorId/entry-exit/',
//         data: {'action': 'entry'},
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Check-in visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Check-out visitor
//   Future<Response> checkOutVisitor(String visitorId) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$visitorId/entry-exit/',
//         data: {'action': 'exit'},
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Check-out visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Get visitor QR (or details) by ID
//   Future<Response> getVisitorQR(String visitorId) async {
//     try {
//       final response = await _apiService.dio.get(
//         '/visitors/visitors/$visitorId/',
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Get visitor QR error: $e');
//       rethrow;
//     }
//   }

//   /// Reschedule visitor
//   Future<Response> rescheduleVisitor(
//     String visitorId,
//     Map<String, dynamic> payload,
//   ) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$visitorId/reschedule/',
//         data: payload,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Reschedule visitor error: $e');
//       rethrow;
//     }
//   }

//   /// Verify entry OTP
//   Future<Response> verifyEntryOtp(
//     String passId,
//     Map<String, dynamic> payload,
//   ) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$passId/entry-exit/',
//         data: payload,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Verify entry OTP error: $e');
//       rethrow;
//     }
//   }

//   /// Verify exit OTP
//   Future<Response> verifyExitOtp(
//     String passId,
//     Map<String, dynamic> payload,
//   ) async {
//     try {
//       final response = await _apiService.dio.post(
//         '/visitors/visitors/$passId/entry-exit/',
//         data: payload,
//       );
//       return response;
//     } catch (e) {
//       debugPrint('Verify exit OTP error: $e');
//       rethrow;
//     }
//   }

//   /// Helper to parse error messages from response
//   String getErrorMessage(DioException error) {
//     return _apiService.getErrorMessage(error);
//   }
// }
