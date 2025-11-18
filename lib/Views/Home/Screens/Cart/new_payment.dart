import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/checkout_controller.dart';
import 'package:graba2z/Utils/packages.dart';
import 'package:graba2z/Views/success_page/successpayment.dart';
import 'package:graba2z/Views/Home/Screens/Cart/pay_by_card_webview.dart';
import 'package:graba2z/Views/Home/home.dart';
import 'package:http/http.dart' as http;

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = 'COD';
  CartNotifier _cartNotifier = Get.put(CartNotifier());
  UserController _usercontroller = Get.put(UserController());
  double vatPerItem = 0.0;
  double totalVAT = 0.0;
  double total = 0.0;
  double deliveryFee = 0.0;
  double subtotal = 0.0;
  getcalculations() {
    subtotal = _cartNotifier.cartOtherInfoList.fold(
        0.0, (sum, item) => sum + (item.productPrice! * (item.quantity ?? 0)));
    // _userController.subtotalAmount.value = subtotal;
    // Fixed VAT per item (1.19 AED)

    // Fixed delivery charge (AED 5)
    deliveryFee = _cartNotifier.deliveryFee;

    // Calculate total VAT (multiply VAT per item by the quantity of each item)
    totalVAT = _cartNotifier.cartOtherInfoList
        .fold(0.0, (sum, item) => sum + (vatPerItem * (item.quantity ?? 0)));

    // Total amount (subtotal + total VAT)
    total = subtotal + totalVAT + deliveryFee;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcalculations();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPaymentTile(
          value: 'Tamara',
          title: 'Tamara',
          subtitle: 'Buy now, pay later in 3 installments',
          logo: 'assets/images/tmara.png', // Replace with your asset
        ),
        _buildPaymentTile(
          value: 'Tabby',
          title: 'Tabby',
          subtitle: 'Split your purchase into 4 payments',
          logo: 'assets/images/tabby.jpg',
        ),
        _buildPaymentTile(
          value: 'Card',
          title: 'Pay By Card',
          subtitle: 'Credit/Debit card payment',
          logo: 'assets/images/master.jpg',
        ),
        _buildPaymentTile(
          value: 'COD',
          title: 'Cash On Delivery',
          subtitle: 'Pay when you receive your order',
          logo: 'assets/image ',
        ),
        // const Spacer(),
        Row(
          children: [
            // Expanded(
            //   child: OutlinedButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: const Text("Back"),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
                child: Obx(
              () => _usercontroller.iscardLoading.value
                  ? Container(
                      margin: EdgeInsets.only(top: 30),
                      height: 30,
                      width: 25,
                      child: Center(child: CircularProgressIndicator()))
                  : ElevatedButton(
                      onPressed: () {
                        // Resolve customer name: prefer typed name, then stored full name, else empty
                        final String customerName =
                            _usercontroller.homeNameController.text.trim().isNotEmpty
                                ? _usercontroller.homeNameController.text.trim()
                                : _usercontroller.fullName.value.trim();

                        if (selectedMethod == 'COD' ||
                            selectedMethod == "Card" ||
                            selectedMethod == "Tabby" ||
                            selectedMethod == "Tamara") {
                          if (_usercontroller.isHomeDelivery.value) {
                            createOrder(
                                _usercontroller.orderItems,
                                'home',
                                {
                                  "name": customerName,
                                  "email":
                                      _usercontroller.homeemailAddress.text,
                                  "phone":
                                      _usercontroller.homePhoneController.text,
                                  "address": _usercontroller.street.value
                                      .replaceAll('"', ''),
                                  "city": _usercontroller.city.value
                                      .replaceAll('"', ''),
                                  "state": _usercontroller.state.value
                                      .replaceAll('"', ''),
                                  "zipCode": _usercontroller.zipcode.value
                                      .replaceAll('"', '')
                                },
                                {},
                                _usercontroller.subtotalAmount.value,
                                _cartNotifier.deliveryFee, // was 0.0
                                _cartNotifier.totalAmount.value,
                                _mapPaymentMethod(selectedMethod), // normalized
                                _usercontroller.optionalNote.text);
                          } else {
                            createOrder(
                                _usercontroller.orderItems,
                                'pickup',
                                {
                                  "name": customerName,
                                  "email":
                                      _usercontroller.homeemailAddress.text,
                                  "phone":
                                      _usercontroller.homePhoneController.text,
                                  "address": _usercontroller.street.value
                                      .replaceAll('"', ''),
                                  "city": _usercontroller.city.value
                                      .replaceAll('"', ''),
                                  "state": _usercontroller.state.value
                                      .replaceAll('"', ''),
                                  "zipCode": _usercontroller.zipcode.value
                                      .replaceAll('"', '')
                                },
                                {
                                  "phone": _usercontroller.storePhone.value,
                                  "location": _usercontroller.storeName.value,
                                  "storeId": _usercontroller.storeId.value
                                },
                                _usercontroller.subtotalAmount.value,
                                _cartNotifier.deliveryFee, // was 0.0
                                _cartNotifier.totalAmount.value,
                                _mapPaymentMethod(selectedMethod), // normalized
                                _usercontroller.optionalNote.text);
                          }
                        } else {
                          EasyLoading.showError('Payment Method Not Available');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: Obx(
                        () => Text(
                          _cartNotifier.totalAmount.value == 0.0
                              ? "Place Order - AED ${total}"
                              : "Place Order - AED ${_cartNotifier.totalAmount.value}",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
            )),
          ],
        )
      ],
    );
  }

  // Map UI selection to backend-expected identifiers
  String _mapPaymentMethod(String method) {
    switch (method) {
      case 'COD':
        return 'cod';
      case 'Card':
        return 'ngenius'; // align with backend alias if needed
      case 'Tabby':
        return 'tabby';
      case 'Tamara':
        return 'tamara';
      default:
        return method.toLowerCase();
    }
  }

  Future<void> createOrder(
    List orderItems,
    String deliveryType,
    dynamic shippingAdress,
    dynamic pickupDetails,
    double itemsPrice,
    double shippingPrice,
    double totalPrice,
    String paymentMethod,
    String customerNotes,
  ) async {
    final url = Uri.parse(Configss.createOrder);
    SharedPreferences sp = await SharedPreferences.getInstance();
    _usercontroller.token.value = sp.getString('token') ?? '';

    // Basic validations (do not set loading yet)
    if (_usercontroller.token.value.isEmpty) {
      EasyLoading.showError('Session expired. Please login again.');
      return;
    }
    // Validate based on actual cart content, not the passed orderItems list
    if (_cartNotifier.cartOtherInfoList.isEmpty) {
      EasyLoading.showError('Your cart is empty.');
      return;
    }
    if (deliveryType == 'home') {
      final hasAddress = shippingAdress != null &&
          (shippingAdress['address']?.toString().trim().isNotEmpty ?? false);
      if (!hasAddress) {
        EasyLoading.showError('Please provide a valid shipping address.');
        return;
      }
    }

    // If orderItems is empty, build it from cart
    List composedOrderItems = orderItems;
    if (composedOrderItems.isEmpty) {
      composedOrderItems = _buildOrderItemsFromCart();
      log('Composed orderItems from cart: ${jsonEncode(composedOrderItems)}');
    }

    _usercontroller.iscardLoading.value = true;

    final Map<String, dynamic> orderData = {
      "orderItems": composedOrderItems,
      "deliveryType": deliveryType,
      "shippingAddress": shippingAdress,
      "pickupDetails": pickupDetails,
      "itemsPrice": (itemsPrice).toDouble(),
      "shippingPrice": (shippingPrice).toDouble(),
      "totalPrice": (totalPrice).toDouble(),
      "paymentMethod": paymentMethod,
      "customerNotes": customerNotes
    };

    log('POST $url');
    log('Token present: ${_usercontroller.token.value.isNotEmpty}');
    log('Order payload: ${jsonEncode(orderData)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_usercontroller.token.value}',
        },
        body: jsonEncode(orderData),
      );
      _usercontroller.iscardLoading.value = false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (selectedMethod == 'Card' || selectedMethod == 'Tabby') {
          await paymentRequest(data['_id'], totalPrice);
        } else if (selectedMethod == 'Tamara') {
          await tamaraPaymentRequest(
            orderId: data['_id'],
            totalAmount: totalPrice,
            customer: {
              "name": shippingAdress?['name'] ?? '',
              "email": shippingAdress?['email'] ?? '',
              "phone": shippingAdress?['phone'] ?? '',
            },
          );
        } else {
          final navigationProvider = Get.put(BottomNavigationController());
          navigationProvider.setTabIndex(0);
          String? userId = sp.getString('userId')?.toString();
          setState(() {});
          _cartNotifier.clearCartDataInPrefs(userId);
          Get.offAll(() => SuccessPayment());
        }
        print('Order Created: $data');
      } else {
        final msg = _extractServerMessage(response.body);
        EasyLoading.showError('Create order failed: $msg');
        print('Failed to create order: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      _usercontroller.iscardLoading.value = false;
      EasyLoading.showError('Create order error: ${e.toString()}');
      print('Error creating order: $e');
    }
  }

  Future<void> tamaraPaymentRequest({
    required String orderId,
    required double totalAmount,
    Map<String, dynamic>? customer,
  }) async {
    final url = Uri.parse(Configss.paymentTamaraRequest);
    SharedPreferences sp = await SharedPreferences.getInstance();
    _usercontroller.token.value = sp.getString('token') ?? '';
    EasyLoading.show(status: 'Please wait...');

    // Derive customer info and split name
    final name = (customer?['name'] as String? ?? '').trim();
    final email = (customer?['email'] as String? ?? '').trim();
    final phone = (customer?['phone'] as String? ?? '').trim();
    final firstLast = _splitName(name);

    // Build Tamara-required payload
    final List<Map<String, dynamic>> items = _buildTamaraItemsFromCart();
    final shippingAddress = _buildTamaraAddress();
    final billingAddress = shippingAddress; // use same for now

    final Map<String, dynamic> payload = {
      "order_reference_id": orderId,
      "order_number": "ORD_$orderId",
      "total_amount": {
        "amount": totalAmount,
        "currency": "AED",
      },
      "shipping_amount": {
        "amount": 0,
        "currency": "AED",
      },
      "tax_amount": {
        "amount": 0,
        "currency": "AED",
      },
      "items": items,
      "consumer": {
        "email": email,
        "first_name": firstLast['first_name'],
        "last_name": firstLast['last_name'],
        "phone_number": phone,
      },
      "country_code": "AE",
      "description": "Order for ${items.length} item(s) from Graba2z",
      "merchant_url": {
        "cancel": "${Configss.webBaseUrl}/payment/cancel",
        "failure": "${Configss.webBaseUrl}/payment/failure",
        "success": "${Configss.webBaseUrl}/payment/success",
        "notification": "${Configss.baseUrl}/api/webhooks/tamara",
      },
      "payment_type": "PAY_BY_INSTALMENTS",
      "instalments": 3,
      "billing_address": billingAddress,
      "shipping_address": shippingAddress,
      "platform": "Graba2z Mobile App",
      "is_mobile": true,
      "locale": "en_US",
    };

    log('Tamara request payload: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_usercontroller.token.value}',
        },
        body: jsonEncode(payload),
      );
      EasyLoading.dismiss();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String checkoutUrl = data['checkout_url'] ?? data['paymentUrl'] ?? '';
        if (checkoutUrl.isEmpty) {
          EasyLoading.showError('Invalid Tamara response');
          return;
        }
        Get.to(() => WebViewScreen(url: checkoutUrl));
      } else {
        final msg = _extractServerMessage(response.body);
        EasyLoading.showError('Tamara init failed: $msg');
        log('Tamara init failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Tamara init error: ${e.toString()}');
    }
  }

  // Build Tamara items format
  List<Map<String, dynamic>> _buildTamaraItemsFromCart() {
    final List<Map<String, dynamic>> list = [];
    for (final item in _cartNotifier.cartOtherInfoList) {
      try {
        final qty = (item.quantity ?? 1).toInt();
        final unit = (item.productPrice ?? 0.0).toDouble();
        final total = (unit * qty).toDouble();
        list.add({
          "name": item.productName ?? "",
          "type": "Physical",
          "reference_id": (item.productId ?? '').toString(),
          "sku": (item.productId ?? '').toString(),
          "quantity": qty,
          "discount_amount": {"amount": 0, "currency": "AED"},
          "tax_amount": {"amount": 0, "currency": "AED"},
          "unit_price": {"amount": unit, "currency": "AED"},
          "total_amount": {"amount": total, "currency": "AED"},
        });
      } catch (e) {
        log('Skipping cart item for Tamara mapping: $e');
      }
    }
    return list;
  }

  // Build Tamara address from current shipping data
  Map<String, dynamic> _buildTamaraAddress() {
    final String fullName = _usercontroller.homeNameController.text.trim().isNotEmpty
        ? _usercontroller.homeNameController.text.trim()
        : _usercontroller.fullName.value.trim();
    final name = _splitName(fullName);
    return {
      "city": _usercontroller.city.value.replaceAll('"', ''),
      "country_code": "AE",
      "first_name": name['first_name'],
      "last_name": name['last_name'],
      "line1": _usercontroller.street.value.replaceAll('"', ''),
      "line2": "",
      "phone_number": _usercontroller.homePhoneController.text,
      "region": _usercontroller.state.value.replaceAll('"', ''),
    };
  }

  Map<String, String> _splitName(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) {
      return {"first_name": "", "last_name": ""};
    }
    if (parts.length == 1) {
      return {"first_name": parts.first, "last_name": ""};
    }
    return {
      "first_name": parts.first,
      "last_name": parts.sublist(1).join(' '),
    };
  }

  Future<void> paymentRequest(String orderId, double totalAmount) async {
    final url = Uri.parse(Configss.paymentCardRequest); // <-- replace this
    SharedPreferences sp = await SharedPreferences.getInstance();
    _usercontroller.token.value = sp.getString('token') ?? '';
    EasyLoading.show(status: 'Please wait...');
    final Map<String, dynamic> orderData = {
      "amount": totalAmount,
      "currencyCode": "AED",
      "orderId": orderId
    };
    log('the object from my side ${orderData}');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${_usercontroller.token.value}', // <-- Add your token here
        },
        body: jsonEncode(orderData),
      );
      EasyLoading.dismiss();
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.to(() => WebViewScreen(
              url: data['paymentUrl'],
            ));
        print('payment order Created: $data');
      } else {
        EasyLoading.showError('Failed to create order');
        print('Failed to create order: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      EasyLoading.dismiss();
      print('Error creating order: $e');
    }
  }

  Widget _buildPaymentTile({
    required String value,
    required String title,
    required String subtitle,
    required String logo,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
          log('the select method is ${selectedMethod}');
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        // width: MediaQuery.of(context).size.width / 2 - 22,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedMethod == value ? Colors.green.shade50 : Colors.white,
          border: Border.all(
            color:
                selectedMethod == value ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedMethod,
              onChanged: (val) {
                setState(() {
                  selectedMethod = val!;
                  log('the select method is ${selectedMethod}');
                });
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(
              logo,
              height: 28,
              width: 40,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.payment),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  // Build orderItems in backend expected format (used when controller list is empty)
  List<Map<String, dynamic>> _buildOrderItemsFromCart() {
    final List<Map<String, dynamic>> items = [];
    for (final item in _cartNotifier.cartOtherInfoList) {
      try {
        items.add({
          "product": item.productId,
          "name": item.productName ?? '',
          "quantity": (item.quantity ?? 1),
          "price": (item.productPrice ?? 0.0).toDouble(),
          "image": item.productImage ?? '',
        });
      } catch (e) {
        log('Skipping cart item due to mapping error: $e');
      }
    }
    return items;
  }

  String _extractServerMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        return (data['message'] ??
                data['error'] ??
                data['errors'] ??
                data['detail'] ??
                body)
            .toString();
      }
      return body;
    } catch (_) {
      return body;
    }
  }
}
