import 'dart:convert';
import 'package:get/get.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:http/http.dart' as http;

class bannerProductController extends GetxController {
  var bannerProductList = <dynamic>[].obs;
  var isLoading = false.obs;

  // Fetch all products and filter locally by brand or category
  Future<void> fetchProductsByName({String? name}) async {
    try {
      isLoading(true);

      final response = await http.get(Uri.parse(Configss.product));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          List products = decoded;
          if (name == null || name.trim().isEmpty) {
            bannerProductList.value = products;
            return;
          }

          final search = name.toLowerCase();

          products = products.where((p) {
            return
              // BRAND
              (p['brand']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
                  (p['brand']?['slug']?.toString().toLowerCase().contains(search) ?? false) ||

                  // PARENT CATEGORY
                  (p['parentCategory']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
                  (p['parentCategory']?['slug']?.toString().toLowerCase().contains(search) ?? false) ||

                  // CATEGORY
                  (p['category']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
                  (p['category']?['slug']?.toString().toLowerCase().contains(search) ?? false) ||

                  // SUB CATEGORY
                  (p['subCategory']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
                  (p['subCategory']?['slug']?.toString().toLowerCase().contains(search) ?? false) ||

                  // SUB CATEGORY 2
                  (p['subCategory2']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
                  (p['subCategory2']?['slug']?.toString().toLowerCase().contains(search) ?? false);
          }).toList();

          bannerProductList.value = products;
        } else {
          bannerProductList.clear();
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
