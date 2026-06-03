import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductCardDeal {
  final bool showBadge;
  final bool showPriceCut;
  final double? originalPrice;
  final double? discountedPrice;

  const ProductCardDeal({
    required this.showBadge,
    required this.showPriceCut,
    this.originalPrice,
    this.discountedPrice,
  });

  static const none = ProductCardDeal(showBadge: false, showPriceCut: false);
}

class FirstUserDiscountController extends GetxController {
  static const double guestCardDiscountPercent = 10.0;

  final isStatusLoading = false.obs;
  final isPreviewLoading = false.obs;
  final hasAuthSession = false.obs;
  final eligible = false.obs;
  final reason = ''.obs;
  final hasAnyOrder = false.obs;
  final discount = Rxn<Map<String, dynamic>>();
  final previewApplied = false.obs;
  final previewDiscountAmount = 0.0.obs;
  final previewEligibleSubtotal = 0.0.obs;
  final previewDiscount = Rxn<Map<String, dynamic>>();

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('Guest') == true) return null;
    return prefs.getString('token');
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  void clearPreview() {
    previewApplied.value = false;
    previewDiscountAmount.value = 0.0;
    previewEligibleSubtotal.value = 0.0;
    previewDiscount.value = null;
  }

  void clearAll() {
    hasAuthSession.value = false;
    eligible.value = false;
    reason.value = '';
    hasAnyOrder.value = false;
    discount.value = null;
    clearPreview();
  }

  void markAuthSessionPresent() {
    hasAuthSession.value = true;
  }

  Future<void> loadStatus() async {
    isStatusLoading.value = true;
    final authToken = await _token();
    if (authToken == null || authToken.isEmpty) {
      clearAll();
      isStatusLoading.value = false;
      return;
    }
    hasAuthSession.value = true;

    try {
      final response = await http.get(
        Uri.parse(Configss.firstUserDiscountStatus),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          eligible.value = data['eligible'] == true;
          reason.value = data['reason']?.toString() ?? '';
          hasAnyOrder.value = data['hasAnyOrder'] == true;
          final rawDiscount = data['discount'];
          discount.value = rawDiscount is Map
              ? Map<String, dynamic>.from(rawDiscount)
              : null;
          if (!eligible.value) clearPreview();
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        clearAll();
      } else {
        log('First user discount status failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('First user discount status error: $e');
    } finally {
      isStatusLoading.value = false;
    }
  }

  Future<void> previewCart(List<CartOtherInfo> cartItems) async {
    final authToken = await _token();
    if (authToken == null ||
        authToken.isEmpty ||
        !eligible.value ||
        cartItems.isEmpty) {
      clearPreview();
      return;
    }

    final orderItems = cartItems
        .where((item) =>
            (item.productId ?? '').isNotEmpty &&
            (item.productPrice ?? 0) > 0 &&
            (item.quantity ?? 0) > 0)
        .map((item) => {
              'product': item.productId,
              'price': item.productPrice,
              'quantity': item.quantity ?? 1,
            })
        .toList();

    if (orderItems.isEmpty) {
      clearPreview();
      return;
    }

    isPreviewLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(Configss.firstUserDiscountPreview),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'orderItems': orderItems}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          previewApplied.value = data['applied'] == true;
          previewDiscountAmount.value = _toDouble(data['discountAmount']);
          previewEligibleSubtotal.value = _toDouble(data['eligibleSubtotal']);
          final rawDiscount = data['discount'];
          previewDiscount.value = rawDiscount is Map
              ? Map<String, dynamic>.from(rawDiscount)
              : null;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        clearAll();
      } else {
        clearPreview();
        log('First user discount preview failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      clearPreview();
      log('First user discount preview error: $e');
    } finally {
      isPreviewLoading.value = false;
    }
  }

  Future<void> refreshAfterOrder() async {
    await loadStatus();
  }

  ProductCardDeal _guestProductCardDeal(dynamic product) {
    if (product is! Map || hasAnyOrder.value) {
      return ProductCardDeal.none;
    }

    final offerPrice = _toDouble(product['offerPrice']);
    final regularPrice = _toDouble(product['price']);
    final basePrice = offerPrice > 0 ? offerPrice : regularPrice;
    if (basePrice <= 0) {
      return const ProductCardDeal(showBadge: true, showPriceCut: false);
    }

    final discountedPrice = (basePrice * (1 - guestCardDiscountPercent / 100))
        .clamp(0.0, basePrice)
        .toDouble();

    return ProductCardDeal(
      showBadge: true,
      showPriceCut: discountedPrice < basePrice,
      originalPrice: basePrice,
      discountedPrice: discountedPrice,
    );
  }

  ProductCardDeal getProductCardDeal(
    dynamic product, {
    bool showGuestFallback = false,
  }) {
    if (hasAnyOrder.value || isStatusLoading.value) {
      return ProductCardDeal.none;
    }

    if (!eligible.value || discount.value == null || product is! Map) {
      if (showGuestFallback && !hasAuthSession.value) {
        return _guestProductCardDeal(product);
      }
      return ProductCardDeal.none;
    }

    final currentDiscount = discount.value!;
    final productId = (product['_id'] ?? product['id'] ?? '').toString();
    if (productId.isEmpty) return ProductCardDeal.none;

    final appliesTo = currentDiscount['appliesTo']?.toString();
    var matchesScope = appliesTo == 'all';

    if (!matchesScope && appliesTo == 'products') {
      final products = currentDiscount['products'];
      if (products is List) {
        matchesScope = products.any((entry) {
          if (entry is Map) {
            return (entry['_id'] ?? entry['id'] ?? entry['product'] ?? '')
                    .toString() ==
                productId;
          }
          return entry.toString() == productId;
        });
      }
    }

    if (!matchesScope) return ProductCardDeal.none;

    final offerPrice = _toDouble(product['offerPrice']);
    final regularPrice = _toDouble(product['price']);
    final basePrice = offerPrice > 0 ? offerPrice : regularPrice;
    if (basePrice <= 0) {
      return const ProductCardDeal(showBadge: true, showPriceCut: false);
    }

    final minOrderAmount = _toDouble(currentDiscount['minOrderAmount']);
    if (minOrderAmount > basePrice) {
      return const ProductCardDeal(showBadge: true, showPriceCut: false);
    }

    final discountType = currentDiscount['discountType']?.toString();
    final discountValue = _toDouble(currentDiscount['discountValue']);
    var rawDiscount = 0.0;
    if (discountType == 'percentage') {
      rawDiscount = basePrice * (discountValue / 100);
    } else if (discountType == 'fixed') {
      rawDiscount = discountValue;
    }

    final maxDiscountAmount = _toDouble(currentDiscount['maxDiscountAmount']);
    final effectiveDiscount = (maxDiscountAmount > 0
            ? rawDiscount.clamp(0.0, maxDiscountAmount)
            : rawDiscount.clamp(0.0, double.infinity))
        .toDouble();
    final discountedPrice =
        (basePrice - effectiveDiscount).clamp(0.0, basePrice).toDouble();

    return ProductCardDeal(
      showBadge: true,
      showPriceCut: discountedPrice < basePrice,
      originalPrice: basePrice,
      discountedPrice: discountedPrice,
    );
  }
}
