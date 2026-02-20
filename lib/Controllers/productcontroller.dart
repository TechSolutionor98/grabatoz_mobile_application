import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopController extends GetxController {
  var productList = <dynamic>[].obs;
  var isLoading = false.obs;

  Future<void> fetchProducts({
    required String? id,
    required String? parentType,
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
        print(decoded); // ✅ check what API is returning
        developer.log(decoded.toString(), name: "FetchProducts"); // ✅ log

        // API returns a LIST at the root
        if (decoded is List) {
          // Filter to ensure all items are maps (skip non-map items)
          final filtered = <dynamic>[];
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              filtered.add(item);
            } else if (item is Map) {
              filtered.add(Map<String, dynamic>.from(item));
            } else {
              developer.log("Skipping non-map item: $item", name: "FetchProducts");
            }
          }
          productList.value = filtered;
        } else if (decoded is Map<String, dynamic>) {
          // Handle wrapped response like { products: [...] }
          if (decoded['products'] is List) {
            final filtered = <dynamic>[];
            for (final item in decoded['products']) {
              if (item is Map<String, dynamic>) {
                filtered.add(item);
              } else if (item is Map) {
                filtered.add(Map<String, dynamic>.from(item));
              }
            }
            productList.value = filtered;
          } else {
            productList.clear();
          }
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

  Future<void> fetchGamingZoneProducts({required String slug}) async {
    try {
      isLoading(true);

      final url =
          "https://api.grabatoz.ae/api/gaming-zone-pages/slug/$slug/products?limit=1200";

      final response = await http.get(Uri.parse(url));

      // 🔹 Debug raw response
      print("Raw Response Body: ${response.body}");
      developer.log(response.body, name: "GamingZoneRaw");

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        print("Failed to decode JSON: $e");
        developer.log("Failed to decode JSON: $e", name: "GamingZone");
        productList.clear();
        return;
      }

      // 🔹 Debug decoded response
      print("Gaming Zone Response: $decoded");
      developer.log(decoded.toString(), name: "GamingZone");
      developer.log(
          "Products count: ${decoded['products']?.length ?? 0}",
          name: "GamingZone"
      );
      // 🔹 Parse products safely
      List<dynamic> products = [];

      if (decoded is Map<String, dynamic> && decoded['products'] != null && decoded['products'] is List) {
        products = decoded['products'];
      } else if (decoded is List) {
        products = decoded;
      } else {
        productList.clear(); // no products found
        return;
      }

      // 🔹 Flatten products: if each item has a nested 'product' field, extract it
      final flattened = <dynamic>[];
      for (final item in products) {
        if (item is Map<String, dynamic>) {
          // Check if product is nested inside a 'product' field
          if (item.containsKey('product') && item['product'] is Map<String, dynamic>) {
            flattened.add(item['product']);
          } else {
            // Product is already at root level
            flattened.add(item);
          }
        } else {
          // Skip non-map items
          developer.log("Skipping non-map product: $item", name: "GamingZone");
        }
      }

      productList.value = flattened;

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }


}
