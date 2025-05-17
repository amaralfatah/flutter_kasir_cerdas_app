import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/api_response.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

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
  Future<ApiResponse> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint)
          .replace(queryParameters: queryParams);

      final response = await _httpClient
          .get(
            uri,
            headers: _getHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

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

  Future<ApiResponse> post(String endpoint,
      {Map<String, dynamic>? body, bool isFormData = false}) async {
    try {
      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint);

      http.Response response;

      if (isFormData) {
        // Form data request (multipart)
        var request = http.MultipartRequest('POST', uri);

        // Add headers
        request.headers.addAll(_getHeaders(token, isFormData: true));

        // Add form fields with proper type handling
        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              // Convert null values to 'null' string for form data
              String fieldValue;
              if (value is bool) {
                fieldValue = value ? '1' : '0';
              } else {
                fieldValue = value.toString();
              }
              request.fields[key] = fieldValue;
            } else {
              // For null values in form data, explicitly use 'null' string
              request.fields[key] = 'null';
            }
          });
        }

        debugPrint('Form data fields: ${request.fields}');

        final streamedResponse =
            await request.send().timeout(const Duration(seconds: 30));
        response = await http.Response.fromStream(streamedResponse);

        // Debug the raw response
        debugPrint('Raw response: ${response.body}');
      } else {
        // JSON request
        response = await _httpClient
            .post(
              uri,
              headers: _getHeaders(token),
              body: body != null ? json.encode(body) : null,
            )
            .timeout(const Duration(seconds: 30));
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
  Future<ApiResponse> put(String endpoint,
      {Map<String, dynamic>? body, bool isFormData = false}) async {
    try {
      if (isFormData) {
        // For form data, we use POST with _method=PUT
        body ??= {};
        body['_method'] = 'PUT';
        return await post(endpoint, body: body, isFormData: true);
      }

      final token = await _secureStorage.getToken();
      final uri = Uri.parse(ApiEndpoints.baseUrl + endpoint);

      final response = await _httpClient
          .put(
            uri,
            headers: _getHeaders(token),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

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

      final response = await _httpClient
          .delete(
            uri,
            headers: _getHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

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

  ApiResponse _handleResponse(http.Response response) {
    try {
      final responseBody = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(responseBody);
      } else {
        // Error handling
        final statusCode = response.statusCode;
        String message = responseBody['message'] ?? 'Unknown error occurred';
        final data = responseBody['data'];

        // For validation errors (422), try to provide more helpful error messages
        if (statusCode == 422 && responseBody.containsKey('errors')) {
          final errors = responseBody['errors'];
          // Format validation errors into a more readable message
          if (errors is Map<String, dynamic>) {
            final errorMsgs = <String>[];
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMsgs.add('$field: ${messages.join(', ')}');
              } else if (messages is String) {
                errorMsgs.add('$field: $messages');
              }
            });
            message = 'Validation failed: ${errorMsgs.join('; ')}';
          }
        }

        throw ApiException(
          message: message,
          statusCode: statusCode,
          data: responseBody, // Keep the full response for debugging
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Handle JSON parse errors or other unexpected issues
      throw ApiException(
        message: 'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
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
