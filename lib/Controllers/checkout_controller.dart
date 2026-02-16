import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Utils/packages.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  final String apiUrl =
      Configss.getuserProfile; // Replace this with your API URL
  // final String apiUrl = Configss.userProfile; // Replace this with your API URL
  final isHomeDelivery = true.obs;
  var isLoading = false.obs;
  var iscodLoading = false.obs;
  var iscardLoading = false.obs;
  var token = ''.obs;
  var street = ''.obs;
  var city = ''.obs;
  var state = ''.obs;
  var subtotalAmount = 0.0.obs;
  var fullName = ''.obs;
  final namecontroller = TextEditingController();
  final homeNameController = TextEditingController();
  final homeemailAddress = TextEditingController();
  final optionalNote = TextEditingController();
  final homePhoneController = TextEditingController();
  final orderItems = [].obs;
  var storeAddress = ''.obs;
  var storeId = ''.obs;
  var storePhone = ''.obs;
  var storeName = ''.obs;
  final activeStep = 0.obs;
  var phoneController = TextEditingController();
  var zipcode = ''.obs;
  RxInt? selectedStoreIndex = (-1).obs; // Changed back to -1 for no selection
  
  @override
  void onInit() {
    super.onInit();
    // Ensure selectedStoreIndex is initialized
    selectedStoreIndex ??= (-1).obs;
    
    // Debug initialization
    print('🔧 UserController.onInit()');
    print('   storeId initialized: ${storeId.value}');
    print('   storeName initialized: ${storeName.value}');
    print('   storeAddress initialized: ${storeAddress.value}');
    print('   storePhone initialized: ${storePhone.value}');
    print('   selectedStoreIndex initialized: ${selectedStoreIndex?.value}');
  }

  getUserInformation() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    fullName.value = sp.getString('user_name') ?? '';

    if (fullName.value.isNotEmpty) {
      homeNameController.text = fullName.value;
    }
    street.value = sp.getString('user_address') ?? '';
    city.value = sp.getString('user_city') ?? '';
    state.value = sp.getString('user_state') ?? '';
    zipcode.value = sp.getString('user_zipCode') ?? '';
  }

  Future<void> saveAddress({
    required String phone,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    String? name, // optional name mapping to "name" field
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token.value = prefs.getString('token') ?? '';
      isLoading.value = true;

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${token.value}', // Replace with dynamic token if needed
        },
        body: jsonEncode({
          if (name != null && name.isNotEmpty) "name": name,
          "phone": phone,
          "address": {
            "street": street,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "country": country,
          }
        }),
      );
      log('the response is${response.statusCode}');
      log('the response is${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if ((data['name'] ?? '').toString().isNotEmpty) {
          await prefs.setString('user_name', data['name'].toString());
          fullName.value = data['name'].toString();
          homeNameController.text = fullName.value;
        } else if (name != null && name.isNotEmpty) {
          await prefs.setString('user_name', name);
          fullName.value = name;
          homeNameController.text = fullName.value;
        }
        await prefs.setString(
            'user_address', jsonEncode(data['address']['street']));
        await prefs.setString('user_city', jsonEncode(data['address']['city']));
        await prefs.setString(
            'user_zipCode', jsonEncode(data['address']['zipCode']));
        await prefs.setString(
            'user_state', jsonEncode(data['address']['state']));
        // await prefs.setString('user_token', data['token']);
        getUserInformation();
        Get.back();
        // Get.snackbar("Success", "Address updated successfully",
        //     backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Get.snackbar("Error", "Failed to update address");
        final prefs = await SharedPreferences.getInstance();

        if (name != null && name.isNotEmpty) {
          await prefs.setString('user_name', name);
          fullName.value = name;
          homeNameController.text = fullName.value;
        }
        await prefs.setString('user_address', jsonEncode(street));
        await prefs.setString('user_city', jsonEncode(city));
        await prefs.setString('user_zipCode', jsonEncode(zipCode));
        await prefs.setString('user_state', jsonEncode(state));
        Get.back();
        // await prefs.setString('user_token', data['token']);
        getUserInformation();
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}


