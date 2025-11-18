import 'package:get/get.dart';
import 'package:graba2z/Utils/packages.dart';

class DeliveryController extends GetxController {
  String _selectedDelivery = "";

  String get selectedDelivery => _selectedDelivery;

  void selectDelivery(String delivery) {
    _selectedDelivery = delivery;
    update();
  }
}
