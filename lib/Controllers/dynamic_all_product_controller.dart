// import 'dart:convert';
// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:graba2z/Configs/config.dart';
// import 'package:http/http.dart' as http;

// class AllProductController extends GetxController {
//   final isdataloaded = 0.obs;
//   final limit = 13.obs;
//   final dumyvalue = 14.obs;
//   final paginationProducts = [].obs;
//   bool isFetchingMore = false;
//   final fetchedIds = <String>{}.obs;
//   final Map<String, List<dynamic>> productCache = {};
//   final currentCacheKey = ''.obs;

//   final isMoreDataAvailableForShop = true.obs;
//   Future<void> getProductsPaggination(
//     String cateId,
//     String parentType, {
//     double? minPrice,
//     double? maxPrice,
//     String? brand,
//     String? stock,
//   }) async {
//     final cacheKey =
//         '$parentType-$cateId-${minPrice ?? ""}-${maxPrice ?? ""}-${brand ?? ""}-${stock ?? ""}';

//     /// 👇 Check if we’re loading new type of data
//     if (currentCacheKey.value != cacheKey) {
//       log('🔁 New cacheKey detected: clearing old state');
//       paginationProducts.clear();
//       fetchedIds.clear();
//       limit.value = 13;
//       isMoreDataAvailableForShop.value = true;
//       currentCacheKey.value = cacheKey;
//     }

//     // If data already exists in cache
//     if (productCache.containsKey(cacheKey) && paginationProducts.isEmpty) {
//       log('📦 Loading from cache for $cacheKey');
//       paginationProducts.assignAll(productCache[cacheKey]!);

//       isdataloaded.value = 0;
//       if (paginationProducts.length < 13) {
//         isMoreDataAvailableForShop.value = false;
//       }
//       update();
//       return;
//     }

//     isdataloaded.value = paginationProducts.isEmpty ? 1 : 2;
//     isFetchingMore = true;

//     final queryParams = {
//       parentType: cateId,
//       'limit': limit.value.toString(),
//       if (minPrice != null) 'minPrice': minPrice.toString(),
//       if (maxPrice != null) 'maxPrice': maxPrice.toString(),
//       if (brand != null && brand != "All") 'brand': brand,
//       if (stock != null && stock != "All") 'stockStatus': stock,
//     };
//     final uri = Uri.parse(Configss.getAllProducts)
//         .replace(queryParameters: queryParams);

//     try {
//       final response = await http.get(uri);
//       isdataloaded.value = 0;
//       log('api calls ${response.statusCode}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data is List && data.isNotEmpty) {
//           final newProducts = data.where((product) {
//             final id = product['_id'];
//             if (fetchedIds.contains(id)) return false;
//             fetchedIds.add(id);
//             return true;
//           }).toList();

//           if (newProducts.isNotEmpty) {
//             paginationProducts.addAll(newProducts);
//             limit.value += 13;
//             productCache[cacheKey] = [...paginationProducts];
//           }

//           if (newProducts.length < 13) {
//             isMoreDataAvailableForShop.value = false;
//           }
//         } else {
//           isMoreDataAvailableForShop.value = false;
//         }
//       }
//     } catch (e) {
//       log('🚨 Pagination error: $e');
//     }

//     isFetchingMore = false;
//     update();
//   }
// }
