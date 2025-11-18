import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:graba2z/Configs/config.dart';
import '../Models/ordermodel.dart';
import '../Utils/packages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OrderController extends GetxController {
  final activeOrders = [].obs;
  final completedOrders = [].obs;
  final cancelledOrders = [].obs;
  final isloading = false.obs;
  Future getAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Make sure you saved it earlier
    isloading.value = true;
    final url = Uri.parse(Configss.getOrders);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    isloading.value = false;
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
      activeOrders.value = data;
      // return data;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
