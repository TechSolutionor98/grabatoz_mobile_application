import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:graba2z/Api/Models/menumodel.dart';

class menuController extends GetxController {
  // Reactive list of categories
  final categories = <Menumodel>[].obs;
  final isLoading = false.obs;

  // Optional: selected category for UI highlight
  final selectedSlug = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // fetch from API
  }

  /// Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await Dio().get("https://api.grabatoz.ae/api/categories/tree");

      if (response.statusCode == 200) {
        // Ensure response.data is List<dynamic>
        final data = response.data as List<dynamic>;

        // Parse each item to Welcome model and filter for active categories
        categories.value = data
            .map((json) => Menumodel.fromJson(json as Map<String, dynamic>))
            .where((category) => category.isActive)
            .toList();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle category click
  void onCategoryClick(String slug) {
    selectedSlug.value = slug; // Optional for UI highlight
    Get.back(); // Close Drawer
    Get.toNamed('/products', arguments: slug); // Navigate to products
  }
}
