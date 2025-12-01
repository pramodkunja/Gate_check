// Services/category_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gatecheck/Services/Auth_Services/api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  // Get all categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await _apiService.dio.get('/visitors/categories/');

      if (response.statusCode == 200) {
        debugPrint('✅ Categories fetched successfully');
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        debugPrint('⚠️ Failed to fetch categories: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error fetching categories: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // Create new category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/visitors/categories/',
        data: {'name': name, 'description': description, 'is_active': isActive},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Category created successfully');
        return response.data;
      } else {
        throw Exception('Failed to create category');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating category: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

  // Update category
  Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/visitors/categories/$id/',
        data: {'id': id, 'description': description, 'is_active': isActive},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Category updated successfully');
        return response.data;
      } else {
        throw Exception('Failed to update category');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error updating category: ${e.message}');
      throw Exception(_apiService.getErrorMessage(e));
    }
  }

//   // Delete category
//   Future<void> deleteCategory(int id) async {
//     try {
//       final response = await _apiService.dio.delete(
//         '/visitors/categories/$id/',
        
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         debugPrint('✅ Category deleted successfully');
//       } else {
//         throw Exception('Failed to delete category');
//       }
//     } on DioException catch (e) {
//       debugPrint('❌ Error deleting category: ${e.message}');
//       throw Exception(_apiService.getErrorMessage(e));
//     }
//   }
 }
