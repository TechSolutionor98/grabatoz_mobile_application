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

  /// Get brand name from product (handles both string and object)
  String _getBrandName(Map<String, dynamic> product) {
    final brand = product['brand'];
    if (brand == null) return '';

    if (brand is Map) {
      return (brand['name']?.toString() ?? '').toLowerCase();
    }
    return brand.toString().toLowerCase();
  }

  /// Get brand slug from product
  String _getBrandSlug(Map<String, dynamic> product) {
    final brand = product['brand'];
    if (brand == null) return '';

    if (brand is Map) {
      return (brand['slug']?.toString() ?? '').toLowerCase();
    }
    return '';
  }

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
  /// اگر سب words موجود ہوں تو true return کریں
  bool smartWordMatch(String text, String search) {
    final lowerText = text.toLowerCase();
    final lowerSearch = search.toLowerCase().trim();

    // 1️⃣ Full phrase match پہلے
    if (lowerText.contains(lowerSearch)) return true;

    // 2️⃣ سب words کو split کریں اور check کریں
    final words = lowerSearch.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty) // خالی words نکالیں
        .toList();

    // اگر سب words موجود ہوں تو match ہے
    return words.isNotEmpty &&
           words.every((word) => lowerText.contains(word));
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
      final searchWords = query.toLowerCase().trim().split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();

      // 1️⃣ Brand - check اگر کوئی word brand name سے match کرے
      final brandResults = allProducts.where((p) {
        if (!isInStock(p)) return false;

        final brandName = _getBrandName(p);
        final brandSlug = _getBrandSlug(p);

        // اگر کوئی بھی search word brand میں موجود ہے
        return searchWords.any((word) =>
            brandName.contains(word) ||
            brandSlug.contains(word)
        );
      }).toList();

      // 2️⃣ Parent Category
      final parentCategoryResults = allProducts.where((p) {
        if (!isInStock(p)) return false;

        final parentCatName = p['parentCategory']?['name']?.toString().toLowerCase() ?? '';
        final parentCatSlug = p['parentCategory']?['slug']?.toString().toLowerCase() ?? '';

        return searchWords.any((word) =>
            parentCatName.contains(word) ||
            parentCatSlug.contains(word)
        );
      }).toList();

      // 3️⃣ Category
      final categoryResults = allProducts.where((p) {
        if (!isInStock(p)) return false;

        final catName = p['category']?['name']?.toString().toLowerCase() ?? '';
        final catSlug = p['category']?['slug']?.toString().toLowerCase() ?? '';

        return searchWords.any((word) =>
            catName.contains(word) ||
            catSlug.contains(word)
        );
      }).toList();

      // 4️⃣ SubCategory
      final subCategoryResults = allProducts.where((p) {
        if (!isInStock(p)) return false;

        final subCatName = p['subCategory']?['name']?.toString().toLowerCase() ?? '';
        final subCatSlug = p['subCategory']?['slug']?.toString().toLowerCase() ?? '';

        return searchWords.any((word) =>
            subCatName.contains(word) ||
            subCatSlug.contains(word)
        );
      }).toList();

      // 5️⃣ SubCategory2
      final subCategory2Results = allProducts.where((p) {
        if (!isInStock(p)) return false;

        final subCat2Name = p['subCategory2']?['name']?.toString().toLowerCase() ?? '';
        final subCat2Slug = p['subCategory2']?['slug']?.toString().toLowerCase() ?? '';

        return searchWords.any((word) =>
            subCat2Name.contains(word) ||
            subCat2Slug.contains(word)
        );
      }).toList();

      // 6️⃣ Title / Smart Word Match (fallback)
      // اگر تمام words product name میں ہوں تو شامل کریں
      final titleResults = allProducts.where((p) {
        final productName = p['name']?.toString() ?? '';
        final productNameLower = productName.toLowerCase();

        // اگر سب words موجود ہوں تو match کریں
        return searchWords.isNotEmpty &&
               searchWords.every((word) => productNameLower.contains(word));
      }).toList();

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
