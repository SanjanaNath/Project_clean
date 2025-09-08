import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../main.dart';
import 'local_database.dart';

class ApiService {
  Dio _dio;
  ApiService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // bool _isLoggingOut = false;
  // final apiService = ApiService(
  //   onUnauthorized: () {
  //     LocalDatabase().setLoginStatus("LoggedOut");
  //     navigatorKey.currentState?.pushNamedAndRemoveUntil(
  //       '/login',
  //           (route) => false,
  //     );
  //   },
  // );


  /// Default headers including Authorization token
  Map<String, String> defaultHeaders() {
    return {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${LocalDatabase().accessToken}',
    };
  }

  /// Generic POST method
  Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> data, {
        Map<String, String>? headers,
      })
  async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers ?? defaultHeaders()),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Generic GET method
  Future<dynamic> get(
      String endpoint, {
        Map<String, String>? headers,
      })
  async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers ?? defaultHeaders()),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  /// Image Upload method
  Future<Map<String, dynamic>> uploadImages(
      String url, {
        Map<String, dynamic>? extraData,
        Map<String, List<File>>? multipleImages,
      }) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add form fields as strings
    if (extraData != null) {
      request.fields.addAll(
        extraData.map((key, value) => MapEntry(key, value.toString())),
      );
    }

    // Add all images
    if (multipleImages != null) {
      for (var entry in multipleImages.entries) {
        for (var file in entry.value) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, file.path),
          );
        }
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Decode and return the JSON response
        return json.decode(response.body);
      } else {
        // Throw an exception with the API's error message
        var errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload images with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the exception for the caller to handle
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Handles successful responses
  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Unexpected response: ${response.statusCode}',
      );
    }
  }

  /// Handles Dio-specific errors
  dynamic _handleDioError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          throw Exception(
              '${e.response?.data['message'] ?? 'Invalid input'}');
        case 401:
            LocalDatabase().setLoginStatus("LoggedOut");
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/login',
                        (route) => false,
                  );
          throw Exception('Unauthorized: Please check your credentials');
        case 403:
          throw Exception('Forbidden: You do not have permission');
        case 404:
          throw Exception('Resource not found');
        case 500:
          throw Exception('Internal server error. Try again later.');
        default:
          throw Exception(
              'HTTP Error: ${e.response!.statusCode} - ${e.response?.data['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}

