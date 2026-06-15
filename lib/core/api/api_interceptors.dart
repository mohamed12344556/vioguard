import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// API Interceptor for handling requests, responses, and errors
/// Provides centralized logging and error handling
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request details
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 REQUEST[${options.method}] => PATH: ${options.path}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Query Parameters: ${options.queryParameters}');
    debugPrint('Body: ${options.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response details
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(
      '📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    debugPrint('Data: ${response.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    debugPrint('Message: ${err.message}');
    debugPrint('Response: ${err.response?.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onError(err, handler);
  }
}

/// Authentication Interceptor
/// Automatically adds the auth token, and injects the logged-in user's
/// email as a `userEmail` query parameter for backend endpoints that
/// expect it (History, Reports, Content) when not already supplied.
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final String? Function()? getEmail;

  AuthInterceptor({required this.getToken, this.getEmail});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();

    if (AppConfig.isProduction) {
      // The hosting environment is guarded by HTTP Basic Auth at the web-server
      // level and returns 401 on every request without it. It only accepts the
      // credentials in the standard `Authorization` header (a `Proxy-Authorization`
      // fallback was tested and rejected), so Basic auth must own that header.
      final basic = base64Encode(
        utf8.encode(
          '${AppConfig.hostingBasicAuthUser}:${AppConfig.hostingBasicAuthPassword}',
        ),
      );
      options.headers['Authorization'] = 'Basic $basic';

      // The API's Bearer token cannot share the `Authorization` header with the
      // hosting Basic auth, so it travels separately. Endpoints that need it must
      // read the token from here (the public AI/scrape endpoints do not).
      if (token != null && token.isNotEmpty) {
        options.headers['X-Auth-Token'] = 'Bearer $token';
      }
    } else {
      // Local dev backend has no hosting Basic-auth gate, so the JWT can use the
      // standard `Authorization: Bearer` header the API's JwtBearer expects.
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // ngrok free tier returns an interstitial HTML page unless this header
    // is present; it ensures the real JSON API response is served.
    options.headers['ngrok-skip-browser-warning'] = 'true';

    final email = getEmail?.call();
    if (email != null &&
        email.isNotEmpty &&
        !options.queryParameters.containsKey('userEmail')) {
      options.queryParameters['userEmail'] = email;
    }

    super.onRequest(options, handler);
  }
}
