// import 'package:graba2z/Api/Models/productsModel.dart';
import 'package:graba2z/Api/Models/newProductModel.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/packages.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  final List<Newproductmodel> _favorite = [];
  static const String _storageKey = 'favorites_v1';

  List<Newproductmodel> get favorites => _favorite;

  FavoriteProvider() {
    _loadFavorites(); // Load favorites when the provider is initialized
  }

  @override
  void onInit() {
    super.onInit();
    _hydrateFavorites();
  }

  Future<void> _hydrateFavorites() async {
    // Try new storage first
    await loadFavoritesFromStorage();
    if (_favorite.isNotEmpty) return;
    // Migrate from legacy key if present
    await _loadFavorites(); // loads from 'favorite_products'
    if (_favorite.isNotEmpty) {
      await saveFavoritesToStorage(); // persist to new key
    }
  }

  Future<bool> toggleFavorite(Newproductmodel product, BuildContext context, {bool silent = false}) async {
    final authProvider = Get.find<AuthController>();

    if (!authProvider.userID.value.isNotEmpty) {
      context.route(Login());
      return isExist(product);
    }
    bool nowFavorited;
    if (_favorite.any((fav) => fav.id == product.id)) {
      _favorite.removeWhere((fav) => fav.id == product.id);
      nowFavorited = false;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from wishlist"), duration: Duration(seconds: 2)),
        );
      }
    } else {
      _favorite.add(product);
      nowFavorited = true;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to wishlist"), duration: Duration(seconds: 2)),
        );
      }
    }
    await saveFavoritesToStorage(); // Save updated favorites to storage
    update();
    return nowFavorited;
  }

  bool isExist(Newproductmodel product) {
    return _favorite.any((fav) => fav.id == product.id);
  }

  static FavoriteController of(BuildContext context, {bool listen = true}) {
    return Get.find<FavoriteController>();
  }

  Future<void> saveFavoritesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _favorite.map((m) {
        try {
          final Map<String, dynamic> json = (m.toJson() as Map<String, dynamic>);
          return json;
        } catch (_) {
          return {
            '_id': m.id,
            'name': m.name,
            'price': m.price,
            'offerPrice': m.offerPrice,
            'galleryImages': m.galleryImages,
            'stockStatus': m.stockStatus,
            'sku': m.sku,
            'description': m.description,
            'shortDescription': m.shortDescription,
            'brand': m.brand != null ? {'name': m.brand?.name} : null,
            'parentCategory': m.parentCategory != null
                ? {'_id': m.parentCategory?.id, 'name': m.parentCategory?.name}
                : null,
            'specifications': m.specifications,
            'reviews': m.reviews,
            'discount': m.discount,
          };
        }
      }).toList();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> loadFavoritesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final List list = jsonDecode(raw) as List;
      final loaded = <Newproductmodel>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          loaded.add(Newproductmodel.fromJson(e));
        } else if (e is Map) {
          loaded.add(Newproductmodel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      _favorite
        ..clear()
        ..addAll(loaded);
      update();
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = _favorite.map((product) => product.toJson()).toList();
    await prefs.setString('favorite_products', jsonEncode(favoriteJson));
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getString('favorite_products');
    if (favoriteJson != null) {
      final List decodedList = jsonDecode(favoriteJson);
      _favorite.clear();
      _favorite.addAll(
        decodedList
            .map<Newproductmodel>((json) => Newproductmodel.fromJson(json))
            .toList(),
      );
      update();
    }
  }
}
