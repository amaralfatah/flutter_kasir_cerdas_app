import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';
import '../../models/api_response.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
}

class ApiClient {
  final http.Client _httpClient;
  final SecureStorage _secureStorage;

  ApiClient({http.Client? httpClient, SecureStorage? secureStorage})
      : _httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage ?? SecureStorage();

  // Generic GET method with error handling
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint)
          .replace(queryParameters: queryParams);
      
      final response = await _httpClient.get(
        uri,
        headers: _getHeaders(token),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } on TimeoutException {
      throw ApiException(message: 'Request timeout');
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // Generic POST method with error handling
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body, bool isFormData = false}) async {
    try {
      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint);
      
      http.Response response;
      
      if (isFormData) {
        // Form data request (multipart)
        var request = http.MultipartRequest('POST', uri);
        
        // Add headers
        request.headers.addAll(_getHeaders(token, isFormData: true));
        
        // Add form fields
        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              request.fields[key] = value.toString();
            }
          });
        }
        
        final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // JSON request
        response = await _httpClient.post(
          uri,
          headers: _getHeaders(token),
          body: body != null ? json.encode(body) : null,
        ).timeout(const Duration(seconds: 30));
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } on TimeoutException {
      throw ApiException(message: 'Request timeout');
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // Generic PUT method with error handling
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body, bool isFormData = false}) async {
    try {
      if (isFormData) {
        // For form data, we use POST with _method=PUT
        if (body == null) {
          body = {};
        }
        body['_method'] = 'PUT';
        return await post(endpoint, body: body, isFormData: true);
      }
      
      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint);
      
      final response = await _httpClient.put(
        uri,
        headers: _getHeaders(token),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } on TimeoutException {
      throw ApiException(message: 'Request timeout');
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // Generic DELETE method with error handling
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint);
      
      final response = await _httpClient.delete(
        uri,
        headers: _getHeaders(token),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } on TimeoutException {
      throw ApiException(message: 'Request timeout');
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // Helper to handle HTTP responses and convert to ApiResponse
  ApiResponse _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(responseBody);
    } else {
      // Error handling
      final statusCode = response.statusCode;
      final message = responseBody['message'] ?? 'Unknown error occurred';
      final data = responseBody['data'];
      
      throw ApiException(
        message: message,
        statusCode: statusCode,
        data: data != null ? data as Map<String, dynamic> : null,
      );
    }
  }

  // Helper to get request headers
  Map<String, String> _getHeaders(String? token, {bool isFormData = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    
    if (!isFormData) {
      headers['Content-Type'] = 'application/json';
    }
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}