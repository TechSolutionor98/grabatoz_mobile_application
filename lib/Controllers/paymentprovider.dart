import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodController extends GetxController {
  String _selectedPaymentMethod = 'Cash on Delivery';
  // String _selectedPaymentMethod = 'Ngenius';

  String get selectedPaymentMethod => _selectedPaymentMethod;

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    update();
  }
}
