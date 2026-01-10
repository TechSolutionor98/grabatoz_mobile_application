import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Controllers/checkout_controller.dart';
import 'package:graba2z/Utils/packages.dart'; // for AuthController

class AddressDetailsBottomSheet extends StatefulWidget {
  String phone;
  bool isforGuest;
  String? existingStreet;
  String? existingCity;
  String? existingState;
  String? existingZipCode;
  
  AddressDetailsBottomSheet({
    super.key,
    required this.phone,
    required this.isforGuest,
    this.existingStreet,
    this.existingCity,
    this.existingState,
    this.existingZipCode,
  });
  
  @override
  _AddressDetailsBottomSheetState createState() =>
      _AddressDetailsBottomSheetState();
}

class _AddressDetailsBottomSheetState extends State<AddressDetailsBottomSheet> {
  String addressType = 'Home';
  String selectedState = 'Select State';
  List<String> states = [
    'Select State',
    'Abu Dhabi',
    'Ajman',
    'Al Ain',
    'Dubai',
    'Fujairah',
    'Ras Al Khaimah',
    'Sharjah',
    'Umm al-Qaywain',
  ];

  bool isDefault = false;
  final addressController = TextEditingController();
  final zipCodeController = TextEditingController();
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  UserController _userController = Get.put(UserController());
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Prefill with existing data if available
    if (widget.existingStreet != null && widget.existingStreet!.isNotEmpty) {
      addressController.text = widget.existingStreet!.replaceAll('"', '');
    }
    if (widget.existingCity != null && widget.existingCity!.isNotEmpty) {
      cityController.text = widget.existingCity!.replaceAll('"', '');
    }
    if (widget.existingZipCode != null && widget.existingZipCode!.isNotEmpty) {
      zipCodeController.text = widget.existingZipCode!.replaceAll('"', '');
    }
    if (widget.existingState != null && widget.existingState!.isNotEmpty) {
      final cleanState = widget.existingState!.replaceAll('"', '');
      if (states.contains(cleanState)) {
        selectedState = cleanState;
      }
    }
  }

  Future<void> _saveAndSyncAddress() async {
    if (addressController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        selectedState != 'Select State' &&
        zipCodeController.text.isNotEmpty || nameController.text.isNotEmpty) {
      if(widget.isforGuest) {

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('guest_name', nameController.text);
        await prefs.setString('guest_city', cityController.text);
        await prefs.setString('guest_address', addressController.text);
        await prefs.setString('guest_zip', zipCodeController.text);
        await prefs.setString('guest_state', selectedState );
        await prefs.setBool('Guest', true);

        _userController.saveAddress(
          phone: widget.phone,
          street: addressController.text.toString(),
          city: cityController.text.toString(),
          state: selectedState,
          zipCode: zipCodeController.text.toString(),
          country: 'UAE',
        );

      }
      else{
        _userController.saveAddress(
          phone: widget.phone,
          street: addressController.text.toString(),
          city: cityController.text.toString(),
          state: selectedState,
          zipCode: zipCodeController.text.toString(),
          country: 'UAE',
        );

        // Also sync to AuthController for Edit Profile
        _authController.editaddressController.text = addressController.text;
        _authController.editcityController.text = cityController.text;
        _authController.editzipcodeController.text = zipCodeController.text;
        _authController.editStateController.text = selectedState;

        // Update observable values too
        _authController.address.value = addressController.text;
      }
      
    } else {
      Get.snackbar('Warning', "Some fields are missing",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Address Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRadioOption('Home'),
                      SizedBox(width: 20),
                      _buildRadioOption('Office'),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (widget.isforGuest) ...[
                    _buildTextField('Name *', controller: nameController),
                    SizedBox(height: 12),
                  ],
                  _buildTextField('Address *', controller: addressController),
                  SizedBox(height: 12),
                  _buildTextField('Zip Code *', controller: zipCodeController),
                  SizedBox(height: 12),
                  Text('Country'),
                  SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: 'UAE',
                    items: ['UAE']
                        .map((country) => DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            ))
                        .toList(),
                    onChanged: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('State/Region *'),
                  SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedState,
                    items: states
                        .map((state) => DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedState = value!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildTextField('City *', controller: cityController),
                  SizedBox(height: 12),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                          child: Obx(
                        () => _userController.isLoading.value
                            ? Container(
                                width: 30,
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF8FD034),
                                ),
                                onPressed: _saveAndSyncAddress,
                                child: Text(
                                  "Save Address",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      )),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRadioOption(String type) {
    return Row(
      children: [
        Radio<String>(
          value: type,
          groupValue: addressType,
          onChanged: (value) {
            setState(() {
              addressType = value!;
            });
          },
        ),
        Text(type),
      ],
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
