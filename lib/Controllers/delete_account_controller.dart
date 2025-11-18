import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Configs/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountController extends GetxController {
  var isRequestingDeletion = false.obs;
  var isVerifyingCode = false.obs;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> requestAccountDeletion() async {
    try {
      isRequestingDeletion.value = true;
      
      final token = await _getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Please login to delete your account',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final response = await http.post(
        Uri.parse(Configss.requestAccountDeletion),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Get.snackbar(
        //   'Email Sent',
        //   'Please wait 5-6 minutes for the email to arrive. Check your inbox and spam folder.',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: Duration(seconds: 6),
        // );
        return true;
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to request account deletion',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isRequestingDeletion.value = false;
    }
  }

  Future<bool> verifyAccountDeletion(String code) async {
    try {
      isVerifyingCode.value = true;
      
      final token = await _getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Please login to delete your account',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final response = await http.post(
        Uri.parse(Configss.verifyAccountDeletion),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'code': code}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Get.snackbar(
        //   'Account Deleted',
        //   data['message'] ?? 'Your account has been permanently deleted',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
        
        // Clear local storage and logout
        await _clearAllData();
        
        return true;
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Invalid or expired verification code',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isVerifyingCode.value = false;
    }
  }
}
