import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:graba2z/Api/Models/ordercreatemodel.dart' as order_create;
import 'package:graba2z/Configs/config.dart';
import 'package:http/http.dart' as http;
import '../Utils/packages.dart';
import 'package:get/get.dart';

class CartNotifier extends GetxController {
  Map<String, String>? _selectedAddress; // Store selected address

  Map<String, String>? get selectedAddress => _selectedAddress;

  void setSelectedAddress(Map<String, String> address) {
    _selectedAddress = address;
    update();
  }

  final cartItems = <order_create.LineItems>[];
  // final coupon = <order_create.CouponLines>[];
  // double promoPrice = 0;

  var cartOtherInfoList = <CartOtherInfo>[];
  final postCouponList = [].obs;
  int get totalItems {
    return cartOtherInfoList.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  int? _selectedDeliveryIndex = 0;

  int? get selectedDeliveryIndex => _selectedDeliveryIndex;

  // void selectDelivreyOption(int index) {
  //   _selectedDeliveryIndex = index;
  //   update(); // Notify listeners to update UI
  // }

  void selectDelivreyOption(int index) {
    _selectedDeliveryIndex = index; // Update the selected delivery option
    update();
  }

  // double get deliveryFee {
  //   // Check which delivery option is selected
  //   if (_selectedDeliveryIndex == 0) {
  //     return _homeDeliveryFee; // Home Delivery
  //   } else {
  //     return 0; // Pick From Point
  //   }
  // }
  double get deliveryFee {
    if (_selectedDeliveryIndex == 0) {
      return cartTotalPriceF() < 500
          ? 20.0
          : 0.0; // ₹20 if <500, otherwise free
    } else if (_selectedDeliveryIndex == 1) {
      return 0.0; // Pickup from the point is free
    } else {
      return 0.0; // No selection, no fee
    }
  }

  Future<Map<String, dynamic>?> applyCouponRe(
      String couponCode, List cpList) async {
    final String baseUrl = Configss.applyCoupon;

    try {
      var bodyobj = {"code": couponCode, "cartItems": cpList};
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyobj),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body.toString());
        return responseData; // Return the coupon details
      } else {
        return null; // Coupon not found
      }
    } catch (e) {
      print("Error fetching coupon: $e");
      return null;
    }
  }

  /// **Get Cart Key (Guest or Logged-in User)**
  Future<String> _getCartKey(String? userId) async {
    return userId != null ? 'cartData_$userId' : 'guest_cart';
  }

  /// **Save Cart to SharedPreferences**
  Future<void> saveCartToPrefs(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartKey = await _getCartKey(userId);
    await prefs.setString(cartKey, cartOtherInfoListToJson(cartOtherInfoList));
  }

  /// **Load Cart from SharedPreferences**
  Future<void> loadCartFromPrefs(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartKey = await _getCartKey(userId);
    String? cartData = prefs.getString(cartKey);

    if (cartData != null && cartData.isNotEmpty) {
      cartOtherInfoList = cartOtherInfoListFromJson(cartData);
      createLineItems();
    } else {
      cartOtherInfoList = [];
    }
    update();
  }

  /// **Merge Guest Cart into User Cart After Login**
  Future<void> mergeGuestCart(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? guestCartData = prefs.getString('guest_cart');

    if (guestCartData != null && guestCartData.isNotEmpty) {
      List<CartOtherInfo> guestCart = cartOtherInfoListFromJson(guestCartData);

      for (var guestItem in guestCart) {
        int existingIndex = cartOtherInfoList
            .indexWhere((item) => item.productId == guestItem.productId);

        if (existingIndex >= 0) {
          cartOtherInfoList[existingIndex].quantity =
              (cartOtherInfoList[existingIndex].quantity ?? 0) +
                  (guestItem.quantity ?? 1);
        } else {
          cartOtherInfoList.add(guestItem);
        }
      }

      await prefs.remove('guest_cart'); // Remove guest cart after merging
      await saveCartToPrefs(userId);
      update();
    }
  }

  /// **Clear Cart**
  Future<void> clearCartDataInPrefs(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartKey = await _getCartKey(userId);
    await prefs.remove(cartKey);
    cartOtherInfoList.clear();
    update();
  }

  void increaseQuantity(int index, String? userId) {
    cartOtherInfoList[index].quantity =
        (cartOtherInfoList[index].quantity ?? 0) + 1;
    createLineItems();
    saveCartToPrefs(userId);
    update();
  }

  void decreaseQuantity(int index, String? userId) {
    if ((cartOtherInfoList[index].quantity ?? 1) > 1) {
      cartOtherInfoList[index].quantity =
          (cartOtherInfoList[index].quantity ?? 1) - 1;
      createLineItems();
      saveCartToPrefs(userId);
      update();
    }
  }

  void createLineItems() {
    cartItems.clear();
    for (var element in cartOtherInfoList) {
      cartItems.add(order_create.LineItems(
        productId: element.productId,
        quantity: element.quantity,
        variationId: element.variationId?.toInt() ?? 0,
        addedToCartTime: element.addedToCartTime?.toUtc().toString(),
      ));
    }
  }

  var selectedDeliveryMethodId = ''.obs;
  var deliveryFeeCharge = 0.0.obs;

  var totalAmount = 0.0.obs;
  var discountAmountApplied = 0.0.obs;

  addCoupon(String couponCode, TextEditingController couponController,
      List cpList, BuildContext context) async {
    EasyLoading.show(status: 'Applying Coupon...');

    var couponData = await applyCouponRe(couponCode, cpList);

    if (couponData == null) {
      EasyLoading.dismiss();
      EasyLoading.showError("Invalid Coupon Code");
      print("❌ Invalid Coupon Code: $couponCode");
      return;
    }

    double discountValue =
        double.tryParse(couponData['coupon']['discountValue'].toString()) ??
            0.0;
    String discountType =
        couponData['coupon']['discountType']; // 'fixed' or 'percentage'

    double originalTotal = cartTotalPriceF();
    double discountAmount = 0.0;

    if (discountType == 'percentage') {
      discountAmount = (discountValue / 100) * originalTotal;
    } else if (discountType == 'fixed') {
      discountAmount = discountValue;
    }

    // Ensure discount doesn't exceed total
    if (discountAmount > originalTotal) {
      discountAmount = originalTotal;
    }

    double finalTotal = originalTotal - discountAmount;

    // Save values in observables
    discountAmountApplied.value =
        double.parse(discountAmount.toStringAsFixed(2));
    totalAmount.value = double.parse(finalTotal.toStringAsFixed(2));

    // Clear field & update UI
    couponController.clear();
    update();

    EasyLoading.dismiss();
    EasyLoading.showSuccess(
        "Coupon Applied!\nDiscount: ${discountAmountApplied.value.toStringAsFixed(2)} AED\n"
        "Total After Discount: ${totalAmount.value.toStringAsFixed(2)} AED");

    print("✅ Coupon Applied: $couponCode");
    print("🔹 Original Total: $originalTotal");
    print("🔹 Discount Type: $discountType");
    print("🔹 Discount Amount: ${discountAmountApplied.value}");
    print("🔹 Final Total: ${totalAmount.value}");
  }

  // var totalAmount = 0.0.obs;

  // addCoupon(String couponCode, TextEditingController couponController,
  //     List cpList, BuildContext context) async {
  //   EasyLoading.show(status: 'Applying Coupon...'); // ✅ Show loading indicator
  //   // var couponData = await null;
  //   var couponData = await applyCouponRe(couponCode, cpList);

  //   if (couponData == null) {
  //     EasyLoading.showError("Invalid Coupon Code"); // ❌ Hide loading on failure
  //     EasyLoading.dismiss(); // ❌ Hide loading on failure

  //     print("❌ Invalid Coupon Code: $couponCode");

  //     return;
  //   }

  //   double discountAmount =
  //       double.tryParse(couponData['coupon']['discountValue'].toString()) ??
  //           0.0;
  //   String discountType =
  //       couponData['coupon']['discountType']; // 'fixed' or 'percentage'

  //   update(); // Update the UI

  //   // ✅ Clear the text field
  //   couponController.clear();
  //   EasyLoading.showSuccess(
  //       "Coupon Applied! Discount: ${discountAmount.toStringAsFixed(2)} AED");
  //   EasyLoading.dismiss(); // ✅ Hide loading after applying coupon
  // }

  void removeCoupon() {
    // coupon.clear();
    totalAmount.value = 0.0;
    update();
  }

  /// **Add Item to Cart (Handles Guest & Logged-in User)**
  Future<void> addItemInfo(CartOtherInfo cart, String? userId, {bool showNotification = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationEnabled = prefs.getBool('notification_enabled') ?? true;
    int existingItemIndex = cartOtherInfoList
        .indexWhere((item) => item.productId == cart.productId);

    if (existingItemIndex >= 0) {
      cartOtherInfoList[existingItemIndex].quantity =
          (cartOtherInfoList[existingItemIndex].quantity ?? 0) +
              (cart.quantity ?? 1);
      cartOtherInfoList[existingItemIndex].addedToCartTime = DateTime.now();

      if (isNotificationEnabled && showNotification) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "basic_channel",
            title: "Cart Updated",
            body:
                '${cart.productName} quantity updated to ${cartOtherInfoList[existingItemIndex].quantity}',
            actionType: ActionType.Default,
          ),
        );
      }
    } else {
      cart.addedToCartTime = DateTime.now();
      cartOtherInfoList.add(cart);

      if (isNotificationEnabled && showNotification) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "basic_channel",
            title: "Item Added to Cart",
            body: '${cart.productName} has been added to your cart!',
            actionType: ActionType.Default,
          ),
        );
      }
    }

    createLineItems();
    await saveCartToPrefs(userId);
    update();
  }

  void removeItemInfo(String name, String? userId) {
    cartOtherInfoList.removeWhere((element) => element.productName == name);
    createLineItems();
    saveCartToPrefs(userId);
    update();
  }

  double cartTotalPriceF() {
    double cartTotalPrice = cartOtherInfoList.fold(
        0.0,
        (sum, element) =>
            sum + ((element.productPrice ?? 0.0) * (element.quantity ?? 1)));

    return double.parse(cartTotalPrice.toStringAsFixed(2));
  }

  String cartOtherInfoListToJson(List<CartOtherInfo> cartList) {
    List<Map<String, dynamic>> cartJsonList =
        cartList.map((cart) => cart.toJson()).toList();
    return jsonEncode(cartJsonList);
  }

  List<CartOtherInfo> cartOtherInfoListFromJson(String cartData) {
    List<dynamic> cartJsonList = jsonDecode(cartData);
    return cartJsonList.map((json) => CartOtherInfo.fromJson(json)).toList();
  }
}

class CartOtherInfo {
  int? variationId;
  String? productId;
  String? type;
  String? productName;
  String? productImage;
  double? productPrice;
  Color? productColor;
  String? productSize;
  int? quantity;
  DateTime? addedToCartTime;

  List<dynamic>? attributesName;
  List<dynamic>? selectedAttributes;

  CartOtherInfo({
    this.variationId,
    this.productId,
    this.type,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productColor,
    this.productSize,
    this.quantity,
    this.attributesName,
    this.selectedAttributes,
    this.addedToCartTime,
  }) {
    variationId = variationId?.toInt();
  }

  CartOtherInfo.fromJson(Map<String, dynamic> json) {
    variationId = json['variationId']?.toInt();
    productId = json['productId'];
    type = json['type'];
    productName = json['productName'];
    productImage = json['productImage'];
    productPrice = json['productPrice'];
    productColor = json['productColor'];
    productSize = json['productSize'];
    quantity = json['quantity'];
    attributesName = json['attributesName'];
    selectedAttributes = json['selectedAttributes'];
    addedToCartTime = json['addedToCartTime'] != null
        ? DateTime.parse(json['addedToCartTime'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variationId'] = variationId;
    data['productId'] = productId;
    data['type'] = type;
    data['productName'] = productName;
    data['productImage'] = productImage;
    data['productPrice'] = productPrice;
    data['productColor'] = productColor;
    data['productSize'] = productSize;
    data['quantity'] = quantity;
    data['attributesName'] = attributesName;
    data['selectedAttributes'] = selectedAttributes;
    // Store addedToCartTime as a String (ISO8601 format)
    data['addedToCartTime'] = addedToCartTime?.toIso8601String();

    return data;
  }
}
