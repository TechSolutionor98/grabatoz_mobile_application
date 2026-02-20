import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graba2z/Controllers/checkout_controller.dart';
import 'package:graba2z/Utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreSelectionScreen extends StatefulWidget {
  @override
  _StoreSelectionScreenState createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  String? _pickupPhoneError;

  final List<Map<String, String>> stores = [
    {
      "storeId": '0',
      "title": "CROWN EXCEL (Experience Center)",
      "address":
          "Admiral Plaza Hotel Building - 37C Street - Shop 5 - Khalid Bin Al Waleed Rd - Bur Dubai - Dubai - United Arab Emirates",
      "phone": "+971543540656"
    },
    {
      "title": "Crown Excel Head Office",
      "storeId": '1',
      "address":
          "Al Jahra Building, 2nd floor, office 204, 18th st - Al Raffa - Khalid Bin Al Waleed Rd - Bur Dubai - Dubai - United Arab Emirates",
      "phone": "+971543540656"
    },
    {
      "title": "CROWN EXCEL (branch 2)",
      "storeId": '2',
      "address":
          "Shop No. 2, Building 716 Khalid Bin Al Waleed Rd - opposite Main Entrance of Admiral Plaza Hotel - Dubai - Al Souq Al Kabeer - Dubai - United Arab Emirates",
      "phone": "+97142316533"
    },
    // {
    //   "title": "GrabAtoZ",
    //   "storeId": '3',
    //   "address":
    //       "Al Jahra Building, 2nd floor, 18th st - Khalid Bin Al Waleed Rd - Al Raffa - Dubai - United Arab Emirates",
    //   "phone": "+97143357974"
    // },
  ];

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isValidUaePhone(String input) {
    final d = _digitsOnly(input);
    final numPart = d.startsWith('0') ? d.substring(1) : d;
    return numPart.length == 9;
  }

  UserController _userController = Get.put(UserController());
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Phone number field with same style as new_checkout_view
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _userController.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  onChanged: (v) {
                    setState(() {
                      if (v.trim().isEmpty) {
                        _pickupPhoneError = 'Phone is required';
                      } else if (!_isValidUaePhone(v)) {
                        _pickupPhoneError = 'Enter a valid number';
                      } else {
                        _pickupPhoneError = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    prefix: const Text('+971    '),
                    labelText: "Phone number",
                    hintText: "041234567",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    errorText: _pickupPhoneError,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Store *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton(
                    onPressed: () {
                      openMapLocation(
                          _userController.storeAddress.value.toString());
                    },
                    child: Text(
                      'Open In Map',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: kPrimaryColor),
                    ))
              ],
            ),
          ),
          SizedBox(height: 10),

          ListView.builder(
            itemCount: stores.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final store = stores[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _userController.selectedStoreIndex?.value == index
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<int>(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  value: index,
                  groupValue: _userController.selectedStoreIndex?.value,
                  onChanged: (val) {
                    print('🔘 Radio onChanged called with value: $val');
                    print('   Store data from map:');
                    print('   - storeId: ${store['storeId']}');
                    print('   - title: ${store['title']}');
                    print('   - address: ${store['address']}');
                    print('   - phone: ${store['phone']}');
                    
                    setState(() {
                      // Set all values directly without nullable operators
                      if (_userController.selectedStoreIndex != null) {
                        _userController.selectedStoreIndex!.value = val ?? 0;
                      }
                      _userController.storeId.value = store['storeId'] ?? '';
                      _userController.storeName.value = store['title'] ?? '';
                      _userController.storeAddress.value = store['address'] ?? '';
                      _userController.storePhone.value = store['phone'] ?? '';
                      
                      // Verify values were set immediately
                      print('✅ Values set in controller:');
                      print('   - selectedStoreIndex: ${_userController.selectedStoreIndex?.value}');
                      print('   - storeId: "${_userController.storeId.value}"');
                      print('   - storeName: "${_userController.storeName.value}"');
                      print('   - storeAddress: "${_userController.storeAddress.value}"');
                      print('   - storePhone: "${_userController.storePhone.value}"');
                    });
                    
                    log('Store selection completed: ${val}');
                  },
                  title: Text(
                    store['title'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        store['address'] ?? '',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 6),
                      Text(
                        store['phone'] ?? '',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> openMapLocation(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Maps for $address';
    }
  }
}
