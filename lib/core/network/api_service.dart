import 'package:dio/dio.dart';
import 'dio_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() : _dioClient = DioClient();
  
  final DioClient _dioClient;
  
  // ==================== AUTH ENDPOINTS ====================
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dioClient.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> logout() async {
    try {
      await _dioClient.post('/auth/logout');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== PROPERTY ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getProperties({int page = 1}) async {
    try {
      final response = await _dioClient.get('/properties', queryParameters: {'page': page});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getProperty(int id) async {
    try {
      final response = await _dioClient.get('/properties/$id');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> searchProperties(Map<String, dynamic> filters) async {
    try {
      final response = await _dioClient.get('/properties/search', queryParameters: filters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> propertyData, List<String> imagePaths) async {
    try {
      final formData = FormData();
      
      // Add property fields
      propertyData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      
      // Add images
      for (int i = 0; i < imagePaths.length; i++) {
        formData.files.add(MapEntry(
          'images[$i]',
          await MultipartFile.fromFile(imagePaths[i]),
        ));
      }
      
      final response = await _dioClient.upload('/properties', formData);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> propertyData, {List<String>? imagePaths}) async {
    try {
      final formData = FormData();
      
      // Add property fields
      propertyData.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
      
      // Add images if provided
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (int i = 0; i < imagePaths.length; i++) {
          formData.files.add(MapEntry(
            'images[$i]',
            await MultipartFile.fromFile(imagePaths[i]),
          ));
        }
      }
      
      final response = await _dioClient.uploadPut('/properties/$id', formData);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> deleteProperty(int id) async {
    try {
      await _dioClient.delete('/properties/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== FAVOURITE ENDPOINTS ====================
  
  Future<Map<String, dynamic>> toggleFavourite(int propertyId) async {
    try {
      final response = await _dioClient.post('/favourites/$propertyId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getFavourites() async {
    try {
      final response = await _dioClient.get('/favourites');
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== CHAT ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getMyConversation() async {
    try {
      final response = await _dioClient.get('/conversations');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getMessages(int conversationId) async {
    try {
      final response = await _dioClient.get('/conversations/$conversationId/messages');
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> sendMessage(int conversationId, String body) async {
    try {
      final response = await _dioClient.post('/conversations/$conversationId/messages', data: {
        'body': body,
      });
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ==================== ADMIN ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dioClient.get('/admin/dashboard');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getAllConversations() async {
    try {
      final response = await _dioClient.get('/admin/conversations');
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getUsers({int page = 1}) async {
    try {
      final response = await _dioClient.get('/admin/users', queryParameters: {'page': page});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> toggleBlockUser(int userId) async {
    try {
      final response = await _dioClient.post('/admin/users/$userId/block');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    String message = 'An error occurred';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        message = error.response?.data['message'] ?? 'Server error';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error';
        break;
      default:
        message = 'Unknown error';
    }
    
    return ApiException(message, error.response?.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}
