import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:final_project/core/Token/token.dart';

class AuthRemoteDataSource {
  final Dio dio = Dio();

  String _handleDioError(DioException e, {String defaultMsg = 'An error occurred'}) {
    log("Status Code: ${e.response?.statusCode}");
    log("Error Data: ${e.response?.data}");
    final data = e.response?.data;
    if (data == null) return e.message ?? defaultMsg;
    if (data is Map) {
      if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['errors'] != null && data['errors'] is Map) {
        final Map errors = data['errors'];
        final List<String> list = [];
        for (var val in errors.values) {
          if (val is List) {
            list.addAll(val.map((e) => e.toString()));
          } else {
            list.add(val.toString());
          }
        }
        if (list.isNotEmpty) return list.join('\n');
      }
      if (data['title'] != null) return data['title'].toString();
    }
    return data.toString();
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final Response response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/login',
        data: {"email": email, "password": password},
      );
      await saveToken(response.data['accessToken']);
      log('LOGIN TOKEN EMPTY: ${token.isEmpty}');
      log('LOGIN TOKEN LENGTH: ${token.length}');
      log("response : $response");
      log('TOKEN: $token');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Login failed'));
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final Response response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/register',
        data: {
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
        },
      );
      log('response : $response');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Signup failed'));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/forgot-password',
        data: {'email': email},
      );
      log('forgotPassword response: $response');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Failed to send reset code'));
    }
  }

  Future<void> validateOtp({required String email, required String otp}) async {
    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/validate-otp',
        data: {'email': email, 'otp': otp},
      );
      log('validateOtp response: $response');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Invalid OTP code'));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      log('resetPassword response: $response');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Failed to reset password'));
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/change-password',
        data: {
          'currentPassword': oldPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      log(response.data.toString());
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Failed to change password'));
    }
  }

  Future<void> verifyEmail({
    required String otpCode,
    required String email,
  }) async {
    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/verify-email',
        data: {'otp': otpCode, "email": email},
      );
      log(response.data.toString());
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Email verification failed'));
    }
  }

  Future<Response> resendOtp({required String email}) async {
    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/auth/resend-otp',
        data: {'email': email},
      );
      return response;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Failed to resend code'));
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await dio.get(
        'https://accessories-eshop.runasp.net/api/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, defaultMsg: 'Failed to get user profile'));
    }
  }

  Future<void> logout() async {
    try {
      if (token.isNotEmpty) {
        await dio.post(
          'https://accessories-eshop.runasp.net/api/auth/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
    } catch (e) {
      log('Logout API error: $e');
    } finally {
      await clearToken();
    }
  }
}
