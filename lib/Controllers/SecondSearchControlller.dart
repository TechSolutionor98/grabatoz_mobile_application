import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:graba2z/Configs/config.dart';

class ProductController extends GetxController {
  var allProducts = <Map<String, dynamic>>[].obs;
  var displayedProducts = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var hasSearched = false.obs;

  /// Check if product is in stock
  bool isInStock(Map<String, dynamic> product) {
    final status = product['stockStatus'];
    if (status == null) return true;
    return status.toString().toLowerCase().trim() == 'in stock';
  }

  @override
  void onInit() {
    super.onInit();

    // Debounce search input
    debounce<String?>(searchQuery, (val) {
      final q = (val ?? '').trim();
      if (q.isEmpty) {
        hasSearched.value = false;
        allProducts.clear();
        displayedProducts.clear();
      } else {
        hasSearched.value = true;
        fetchProducts(query: q);
      }
    }, time: const Duration(milliseconds: 500));
  }

  /// Smart word match (for partial / multi-word searches)
  bool smartWordMatch(String text, String search) {
    final lowerText = text.toLowerCase();
    final lowerSearch = search.toLowerCase().trim();

    // 1️⃣ Full phrase match first
    if (lowerText.contains(lowerSearch)) return true;

    // 2️⃣ Then fallback to word-by-word match
    final words = lowerSearch.split(RegExp(r'\s+'));
    return words.any((word) => word.length >= 3 && lowerText.contains(word));
  }


  /// Fetch products from API and filter by banner-style priority
  Future<void> fetchProducts({required String query}) async {
    try {
      isLoading(true);

      final response = await http.get(Uri.parse(Configss.product));

      if (response.statusCode != 200) {
        allProducts.clear();
        displayedProducts.clear();
        Get.snackbar("Error", "Status ${response.statusCode}");
        return;
      }

      final decoded = json.decode(response.body);

      if (decoded is! List) {
        allProducts.clear();
        displayedProducts.clear();
        return;
      }

      allProducts.value = decoded.whereType<Map<String, dynamic>>().toList();

      final search = query.toLowerCase();


      // 1️⃣ Brand
      final brandResults = allProducts.where((p) =>
      isInStock(p) &&
          ((p['brand']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
              (p['brand']?['slug']?.toString().toLowerCase().contains(search) ?? false))
      ).toList();

      // 2️⃣ Parent Category
      final parentCategoryResults = allProducts.where((p) =>
      isInStock(p) &&
          ((p['parentCategory']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
              (p['parentCategory']?['slug']?.toString().toLowerCase().contains(search) ?? false))
      ).toList();

      // 3️⃣ Category
      final categoryResults = allProducts.where((p) =>
      isInStock(p) &&
          ((p['category']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
              (p['category']?['slug']?.toString().toLowerCase().contains(search) ?? false))
      ).toList();

      // 4️⃣ SubCategory
      final subCategoryResults = allProducts.where((p) =>
      isInStock(p) &&
          ((p['subCategory']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
              (p['subCategory']?['slug']?.toString().toLowerCase().contains(search) ?? false))
      ).toList();

      // 5️⃣ SubCategory2
      final subCategory2Results = allProducts.where((p) =>
      isInStock(p) &&
          ((p['subCategory2']?['name']?.toString().toLowerCase().contains(search) ?? false) ||
              (p['subCategory2']?['slug']?.toString().toLowerCase().contains(search) ?? false))
      ).toList();

      // 6️⃣ Title / Smart Word Match (fallback)
      final titleResults = allProducts.where((p) =>
          smartWordMatch(p['name']?.toString() ?? '', search)
      ).toList();

      // Combine all results in order of priority & remove duplicates
      displayedProducts.value = [
        ...brandResults,
        ...parentCategoryResults,
        ...categoryResults,
        ...subCategoryResults,
        ...subCategory2Results,
        ...titleResults
      ].toSet().toList(); // toSet removes duplicates

    } catch (e) {
      allProducts.clear();
      displayedProducts.clear();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
