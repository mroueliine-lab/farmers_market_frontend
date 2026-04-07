import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      switch (statusCode) {
        case 401:
          return 'Invalid credentials. Please check your email and password.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Resource not found.';
        case 422:
          // Validation errors from Laravel
          if (data != null && data['message'] != null) {
            return data['message'];
          }
          return 'Invalid data submitted. Please check your inputs.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  static void show(BuildContext context, dynamic error) {
    final message = getMessage(error);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}