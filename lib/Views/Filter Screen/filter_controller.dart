import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  var minPrice = 0.0.obs;
  var maxPrice = 100000.0.obs;
  var selectedBrand = 'All'.obs;
  var nameAndSize = 'All'.obs;
  var selectedRangeAndnameValue = ''.obs;
  var brandId = ''.obs;
  var selectedCategoryId = 'all'.obs;
  var selectedSubCategoryId = RxnString();
  var selectedStockStatus = 'All'.obs;

  // Optionally hold TextEditingControllers too
  final minPriceController = TextEditingController(text: '0');
  final maxPriceController = TextEditingController(text: '100000');

  void resetFilters() {
    minPrice.value = 0;
    maxPrice.value = 100000;
    selectedBrand.value = 'All';
    brandId.value = '';
    selectedCategoryId.value = 'all';
    selectedSubCategoryId.value = null;
    selectedStockStatus.value = 'All';

    minPriceController.text = '0';
    maxPriceController.text = '100000';
  }
}
