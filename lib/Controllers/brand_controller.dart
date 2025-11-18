import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:graba2z/Configs/config.dart';
import "package:http/http.dart" as http;

class BrandController extends GetxController {
  // --- Existing State for general brand list and one featured brand ---
  final isbrandLoaded = false.obs; // Loading state for the list of all brands
  final isbrandbyidLoaded = false.obs; // Loading state for productbyBrand (the firstBrandId products)
  
  final brandList = [].obs; // The main list of all brands (e.g., for BrandCard scroller)
  final brandName = <String>[].obs; // Helper list of names from brandList
  
  final productbyBrand = [].obs; // Products for firstBrandId (your "brand 2st products" section)
  final firstbrandName = ''.obs;
  final firstBrandId = ''.obs;
  
  final rangeAndNameFilter =
      <String>['Price: Low to High', 'Price: High to Low', "Name: A-Z"].obs;

  // --- State for fetching products for ANY specific brandId on demand (Home Screen Sections) ---
  final productsByBrandIdMap = <String, RxList<dynamic>>{}.obs;
  final isLoadingProductsByBrandIdMap = <String, RxBool>{}.obs;
  // --- End State ---

  // --- New State for All Products by Brand (No Pagination - For NewAllProduct screen) ---
  final allProductsByBrandMap = <String, RxList<dynamic>>{}.obs;
  final isLoadingAllProductsByBrandMap = <String, RxBool>{}.obs;
  // --- End New State ---

  @override
  void onInit() {
    super.onInit();
    fetchBrands(); // Fetches all brands & products for firstBrandId (existing logic)
  }

  Future<void> fetchBrands() async {
    String url = Configss.getallbrands;
    try {
      isbrandLoaded.value = true;
      final response = await http.get(Uri.parse(url));
      isbrandLoaded.value = false;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> filteredBrands = [];
        if (data is List) {
          for (var brandItem in data) {
            if (brandItem is Map &&
                brandItem['logo'] != null &&
                brandItem['logo'].toString().isNotEmpty) {
              filteredBrands.add(brandItem);
            }
          }
        }
        brandList.value = filteredBrands;
        brandName.clear();
        for (var i = 0; i < brandList.length; i++) {
          if (brandList[i]['name'] != null) {
            brandName.add(brandList[i]['name']);
          }
        }

        if (brandList.length > 5) {
          firstbrandName.value = brandList[5]['name'] ?? '';
          firstBrandId.value = brandList[5]['_id'] ?? '';
          getHomeProductsbyBrand();
        } else if (brandList.isNotEmpty) {
          log('[fetchBrands] Brand list has ${brandList.length} elements (after filtering). Selecting index 0 for firstBrandId.');
          firstbrandName.value = brandList[0]['name'] ?? '';
          firstBrandId.value = brandList[0]['_id'] ?? '';
          getHomeProductsbyBrand();
        } else {
          log('[fetchBrands] Brand list is empty after filtering for logos.');
          firstbrandName.value = '';
          firstBrandId.value = '';
          productbyBrand.clear();
        }
      } else {
        log('[fetchBrands] Failed to load brands. Status code: ${response.statusCode}');
        throw Exception('Failed to load brands');
      }
    } catch (error) {
      log("[fetchBrands] Error: $error");
      isbrandLoaded.value = false;
      brandList.clear();
      brandName.clear();
      productbyBrand.clear();
    }
    update(); 
  }

  Future<void> getHomeProductsbyBrand() async { 
    if (firstBrandId.value.isEmpty) {
      log('[getHomeProductsbyBrand] Aborted: firstBrandId is empty.');
      productbyBrand.clear();
      isbrandbyidLoaded.value = false; 
      update();
      return;
    }
    isbrandbyidLoaded.value = true;
    String brandIdForLog = firstBrandId.value;
    String brandNameForLog = firstbrandName.value;

    String url = "${Configss.searchAll}?brand=${brandIdForLog}&limit=5"; // This specific method still uses limit=5 for its original purpose
    log('[getHomeProductsbyBrand] Fetching products for general brand: "$brandNameForLog" (ID: $brandIdForLog)');
    log('[getHomeProductsbyBrand] Request URL: $url');

    try {
      var response = await http.get(Uri.parse(url));
      isbrandbyidLoaded.value = false;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] is List) {
          productbyBrand.assignAll(responseData['data']);
          log('[getHomeProductsbyBrand] Successfully processed ${responseData['data'].length} products for brand $brandIdForLog.');
        } else {
          productbyBrand.clear();
          log('[getHomeProductsbyBrand] Failed to fetch or parse products for $brandIdForLog. Body: ${response.body.substring(0,100)}');
        }
      } else {
        productbyBrand.clear();
        log('[getHomeProductsbyBrand] HTTP Error ${response.statusCode} for $brandIdForLog: ${response.body}');
      }
    } catch (e) {
      log('[getHomeProductsbyBrand] Exception for $brandIdForLog: $e');
      isbrandbyidLoaded.value = false;
      productbyBrand.clear();
    }
    update(); 
  }
  
  // Method to fetch products for a brand, used by home screen sections
  Future<void> fetchProductsForBrand(String brandId, {String? brandNameForLog, int fetchLimit = 5}) async {
    if (brandId.isEmpty) {
      log('[fetchProductsForBrand] Aborted: brandId is empty.');
      productsByBrandIdMap.putIfAbsent(brandId, () => <dynamic>[].obs);
      isLoadingProductsByBrandIdMap.putIfAbsent(brandId, () => false.obs);
      isLoadingProductsByBrandIdMap[brandId]!(false);
      return;
    }

    final String logContext = brandNameForLog ?? 'BrandID: $brandId';

    productsByBrandIdMap.putIfAbsent(brandId, () => <dynamic>[].obs);
    isLoadingProductsByBrandIdMap.putIfAbsent(brandId, () => false.obs);

    isLoadingProductsByBrandIdMap[brandId]!(true);
    productsByBrandIdMap[brandId]!.clear(); 

    String url = "${Configss.searchAll}?brand=${brandId}&limit=$fetchLimit"; // Use fetchLimit
    log('[fetchProductsForBrand] Fetching for "$logContext" with limit $fetchLimit: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] is List) {
          List<dynamic> fetchedProducts = List<dynamic>.from(responseData['data']);
          productsByBrandIdMap[brandId]!.assignAll(fetchedProducts);
          log('[fetchProductsForBrand] Successfully processed ${fetchedProducts.length} products for "$logContext".');
        } else {
          productsByBrandIdMap[brandId]!.clear();
          log('[fetchProductsForBrand] Failed to parse products for "$logContext". Success: ${responseData['success']}, Data type: ${responseData['data']?.runtimeType}');
        }
      } else {
        productsByBrandIdMap[brandId]!.clear();
        log('[fetchProductsForBrand] HTTP Error ${response.statusCode} for "$logContext": ${response.body}');
      }
    } catch (e) {
      productsByBrandIdMap[brandId]?.clear(); 
      log('[fetchProductsForBrand] Exception for "$logContext": $e');
    } finally {
      isLoadingProductsByBrandIdMap[brandId]!(false);
    }
  }

  // --- New Method to Fetch All Products for a Brand (No Pagination) ---
  Future<void> fetchAllProductsForBrand(
    String brandId, {
    String? brandNameForLog,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (brandId.isEmpty) {
      log('[fetchAllProductsForBrand] Aborted: brandId is empty.');
      allProductsByBrandMap.putIfAbsent(brandId, () => <dynamic>[].obs);
      isLoadingAllProductsByBrandMap.putIfAbsent(brandId, () => false.obs);
      isLoadingAllProductsByBrandMap[brandId]!(false);
      return;
    }

    final String logContext = brandNameForLog ?? 'BrandID: $brandId (All Products)';

    isLoadingAllProductsByBrandMap.putIfAbsent(brandId, () => false.obs);
    isLoadingAllProductsByBrandMap[brandId]!(true);
    allProductsByBrandMap.putIfAbsent(brandId, () => <dynamic>[].obs);
    allProductsByBrandMap[brandId]!.clear();

    log('Fetching all products for brand: $logContext');

    try {
      Uri baseUri = Uri.parse(Configss.searchAll);
      Map<String, String> queryParams = {
        'brand': brandId,
      };
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toStringAsFixed(0);
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toStringAsFixed(0);
      }

      final finalUri = baseUri.replace(queryParameters: queryParams);
      log('Fetching all products for brand URL: $finalUri');

      var response = await http.get(finalUri);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] is List) {
          allProductsByBrandMap[brandId]!.assignAll(responseData['data']);
          log('Successfully fetched ${allProductsByBrandMap[brandId]!.length} products for $logContext.');
        } else {
          allProductsByBrandMap[brandId]!.clear();
          log('Failed to parse all products for $logContext. Success: ${responseData['success']}, Data type: ${responseData['data']?.runtimeType}');
        }
      } else {
        allProductsByBrandMap[brandId]!.clear();
        log('HTTP Error ${response.statusCode} fetching all products for $logContext: ${response.body}');
      }
    } catch (e) {
      log('Exception fetching all products for $logContext: $e');
      allProductsByBrandMap[brandId]?.clear(); // Null-safe clear
    } finally {
      isLoadingAllProductsByBrandMap[brandId]!(false);
    }
  }
  // --- End New Method ---
}
