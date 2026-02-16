import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopController extends GetxController {
  var productList = <dynamic>[].obs;
  var isLoading = false.obs;

  Future<void> fetchProducts({
    required String id,
    required String parentType,
  }) async {
    try {
      isLoading(true);

      String url = "";

      if (parentType == "subcategory") {
        url = "https://api.grabatoz.ae/api/products?subcategory=$id";
      } else if (parentType == "parentCategory") {
        url = "https://api.grabatoz.ae/api/products?parentCategory=$id";
      } else if (parentType == "brand") {
        url = "https://api.grabatoz.ae/api/products?brand=$id";
      } else {
        url = "https://api.grabatoz.ae/api/products";
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // API returns a LIST at the root
        if (decoded is List) {
          productList.value = decoded;
        } else {
          productList.clear();
        }
      } else {
        Get.snackbar("Error", "Status ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
