import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:get/get.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/checkout_controller.dart';
import 'package:graba2z/Utils/appcolors.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Utils/packages.dart'; // for AuthController
import 'package:graba2z/Views/Home/Screens/Cart/address_formt.dart';
import 'package:graba2z/Views/Home/Screens/Cart/new_payment.dart';
import 'package:graba2z/Views/Home/Screens/Cart/new_summary_view.dart';
import 'package:graba2z/Views/Home/Screens/Cart/store_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CheckoutStepper extends StatefulWidget {
  bool isforguest;
  CheckoutStepper({super.key, required this.isforguest});

  @override
  State<CheckoutStepper> createState() => _CheckoutStepperState();
}

class _CheckoutStepperState extends State<CheckoutStepper> {
  String userEmail = '';
  getUserInformation() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    userEmail = sp.getString('userEmail') ?? '';
    _userController.homeemailAddress.text = userEmail;
    setState(() {});
  }

  final AuthController _authController =
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController(), permanent: true);

  @override
  void initState() {
    super.initState();
    getUserInformation();
    fetchDeliveryMethods();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userController.getUserInformation();
      // Fetch profile like Edit Profile, prefill now, and keep in sync when data arrives
      _authController.getUserProfileData();
      _attachAuthControllerListeners();
      _prefillFromProfile(); // immediate attempt (in case data is already available)
    });
  }

  void _attachAuthControllerListeners() {
    // Keep checkout fields in sync when Edit Profile text controllers get populated
    _authController.editPhoneController.addListener(_syncFromAuthControllers);
    _authController.editaddressController.addListener(_syncFromAuthControllers);
    _authController.editcityController.addListener(_syncFromAuthControllers);
    _authController.editzipcodeController.addListener(_syncFromAuthControllers);
    _authController.editStateController.addListener(_syncFromAuthControllers); // Add this line
  }

  void _syncFromAuthControllers() {
    // Sync all fields including state from Edit Profile to Checkout
    final phone = _authController.editPhoneController.text.trim();
    final street = _authController.editaddressController.text.trim();
    final city = _authController.editcityController.text.trim();
    final zip = _authController.editzipcodeController.text.trim();
    final state = _authController.editStateController.text.trim(); // Add this
    bool changed = false;
    
    if (phone.isNotEmpty && _userController.homePhoneController.text != phone) {
      _userController.homePhoneController.text = phone;
      _userController.phoneController.text = phone;
      changed = true;
    }
    
    if (street.isNotEmpty && _userController.street.value != street) {
      _userController.street.value = street;
      changed = true;
    }
    
    if (city.isNotEmpty && _userController.city.value != city) {
      _userController.city.value = city;
      changed = true;
    }
    
    if (zip.isNotEmpty && _userController.zipcode.value != zip) {
      _userController.zipcode.value = zip;
      changed = true;
    }
    
    // Sync state - including when it's cleared (empty string)
    if (_userController.state.value != state) {
      _userController.state.value = state;
      changed = true;
      print("🔄 Synced state from Edit Profile: '$state'");
    }
    
    if (changed && mounted) setState(() {});
  }

  // Pull data from AuthController (used in Edit Profile) into checkout fields
  void _prefillFromProfile() {
    try {
      final phone = _authController.editPhoneController.text.trim();
      if (phone.isNotEmpty) {
        _userController.homePhoneController.text = phone;
        _userController.phoneController.text = phone;
      }
      final street = _authController.editaddressController.text.trim();
      final city = _authController.editcityController.text.trim();
      final zip = _authController.editzipcodeController.text.trim();
      final state = _authController.editStateController.text.trim();
      
      if (street.isNotEmpty) _userController.street.value = street;
      if (city.isNotEmpty) _userController.city.value = city;
      if (zip.isNotEmpty) _userController.zipcode.value = zip;
      _userController.state.value = state; // Sync state even if empty
      
      if (mounted) setState(() {});
    } catch (_) {
      // swallow; keep existing values
    }
  }

  void _syncToAuthController() {
    // Sync checkout data back to edit profile controllers
    if (_userController.isHomeDelivery.value) {
      _authController.editPhoneController.text = _userController.homePhoneController.text;
    } else {
      _authController.editPhoneController.text = _userController.phoneController.text;
    }
    
    _authController.editaddressController.text = _userController.street.value;
    _authController.editcityController.text = _userController.city.value;
    _authController.editzipcodeController.text = _userController.zipcode.value;
    _authController.editStateController.text = _userController.state.value;
    
    // Also update observable values in auth controller
    _authController.phoneNumber.value = _userController.isHomeDelivery.value 
        ? _userController.homePhoneController.text 
        : _userController.phoneController.text;
    _authController.address.value = _userController.street.value;
  }

  @override
  void dispose() {
    // Remove listeners to avoid leaks
    _authController.editPhoneController.removeListener(_syncFromAuthControllers);
    _authController.editaddressController.removeListener(_syncFromAuthControllers);
    _authController.editcityController.removeListener(_syncFromAuthControllers);
    _authController.editzipcodeController.removeListener(_syncFromAuthControllers);
    _authController.editStateController.removeListener(_syncFromAuthControllers); // Add this line
    super.dispose();
  }

  final _cartNotifier = Get.put(CartNotifier());
  double vatPerItem = 0.0;
  double subtotal = 0.0;
  String? _homePhoneError;

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isValidUaePhone(String input) {
    final d = _digitsOnly(input);
    final numPart = d.startsWith('0') ? d.substring(1) : d; // drop leading 0
    return numPart.length == 9;
  }

  getcalculations() {
    subtotal = _cartNotifier.cartOtherInfoList.fold(
        0.0, (sum, item) => sum + (item.productPrice! * (item.quantity ?? 0)));

    if (subtotal <= 500) {
      _cartNotifier.totalAmount.value =
          subtotal + _cartNotifier.deliveryFeeCharge.value;
    } else {
      _cartNotifier.totalAmount.value = subtotal;
    }
  }

  List<DeliveryMethod> deliveryMethods = [];

  Future<void> fetchDeliveryMethods() async {
    final response = await http.get(Uri.parse(Configss.getShippingCharge));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      deliveryMethods = data.map((e) => DeliveryMethod.fromJson(e)).toList();

      if (deliveryMethods.isNotEmpty) {
        _cartNotifier.selectedDeliveryMethodId.value =
            deliveryMethods.first.id;
        _cartNotifier.deliveryFeeCharge.value = deliveryMethods.first.charge;
        getcalculations();
      }

      setState(() {});
    } else {
      throw Exception("Failed to load delivery methods");
    }
  }

  String? selectedSubCategoryId;
  UserController _userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    // Re-sync state every time widget rebuilds (when returning from Edit Profile)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = _userController.state.value;
      final authState = _authController.editStateController.text;
      if (currentState != authState && mounted) {
        _userController.state.value = authState;
        setState(() {});
        print("🔄 Force synced state on rebuild: '$authState'");
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Obx(
                  () => EasyStepper(
                    activeStep: _userController.activeStep.value,
                    stepShape: StepShape.circle,
                    stepRadius: 20,
                    showLoadingAnimation: false,
                    direction: Axis.horizontal,
                    activeStepTextColor: Colors.green,
                    finishedStepTextColor: Colors.black,
                    internalPadding: 8,
                    unreachedStepTextColor: Colors.grey,
                    activeStepBorderColor: Colors.green,
                    steps: const [
                      EasyStep(
                          icon: Icon(Icons.local_shipping), title: 'Shipping'),
                      EasyStep(
                          icon: Icon(Icons.receipt_long), title: 'Summary'),
                      EasyStep(icon: Icon(Icons.payment), title: 'Payment'),
                    ],
                    onStepReached: (index) => setState(
                        () => _userController.activeStep.value = index),
                  ),
                )),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => _buildStepContent()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_userController.activeStep.value) {
      case 0:
        return _shippingStep();
      case 1:
        return NewSummaryView(
          addressCustomer:
              "${_userController.street.value.replaceAll('"', '')}, "
              "${_userController.city.value.replaceAll('"', '')}, "
              "${_userController.state.value.replaceAll('"', '')}, "
              "${_userController.zipcode.value.replaceAll('"', '')}",
          companyAddress: _userController.storeAddress.value,
          companyName: _userController.storeName.value,
          customerEmail: userEmail,
          phone: _userController.isHomeDelivery.value
              ? _userController.homePhoneController.text
              : _userController.phoneController.text,
          shippingType: _userController.isHomeDelivery.value
              ? 'Home Delivery'
              : 'Store Pickup',
          subtotal: subtotal,
          deliveryMethods: deliveryMethods,
        );
      case 2:
        return PaymentMethodScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _shippingStep() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _userController.isHomeDelivery.value = true;
                    setState(() {});
                  },
                  child: defaultStyledContainer(
                    backgroundColor: _userController.isHomeDelivery.value
                        ? kPrimaryColor
                        : kdefwhiteColor,
                    child: Column(
                      children: [
                        Text(
                          "Home Delivery",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _userController.isHomeDelivery.value
                                ? kdefwhiteColor
                                : kdefblackColor,
                          ),
                        ),
                        4.0.heightbox,
                        Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _userController.isHomeDelivery.value
                                ? kdefwhiteColor
                                : kPrimaryColor,
                          ),
                        ),
                        4.0.heightbox,
                        Text(
                          "Deliver at doorstep",
                          style: TextStyle(
                            fontSize: 13,
                            color: _userController.isHomeDelivery.value
                                ? kdefwhiteColor
                                : kdefblackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              10.0.widthbox,
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _userController.isHomeDelivery.value = false;
                    setState(() {});
                  },
                  child: defaultStyledContainer(
                    backgroundColor:
                        _userController.isHomeDelivery.value == false
                            ? kPrimaryColor
                            : kdefwhiteColor,
                    child: Column(
                      children: [
                        Text(
                          "Pick From Point",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _userController.isHomeDelivery.value == false
                                ? kdefwhiteColor
                                : kdefblackColor,
                          ),
                        ),
                        4.0.heightbox,
                        Text(
                          "Free Delivery",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _userController.isHomeDelivery.value == false
                                ? kdefwhiteColor
                                : kPrimaryColor,
                          ),
                        ),
                        4.0.heightbox,
                        Text(
                          "Pick from the Store",
                          style: TextStyle(
                            fontSize: 13,
                            color: _userController.isHomeDelivery.value == false
                                ? kdefwhiteColor
                                : kdefblackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _userController.isHomeDelivery.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Contact Details",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _userController.homeemailAddress,
                      decoration: InputDecoration(
                          labelText: "E-mail",
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: "example@email.com",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: _userController.homePhoneController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9), // limit to 9 digits
                            ],
                            onChanged: (v) {
                              setState(() {
                                if (v.trim().isEmpty) {
                                  _homePhoneError = 'Phone is required';
                                } else if (!_isValidUaePhone(v)) {
                                  _homePhoneError = 'Enter a valid number';
                                } else {
                                  _homePhoneError = null;
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
                              errorText: _homePhoneError,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => _userController.street.value.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Shipping Address",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(
                                      "${_userController.street.value.replaceAll('"', '')}, "
                                      "${_userController.city.value.replaceAll('"', '')}, "
                                      "${_userController.state.value.replaceAll('"', '')}, "
                                      "${_userController.zipcode.value.replaceAll('"', '')}"),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            builder: (context) =>
                                                AddressDetailsBottomSheet(
                                              isforGuest: widget.isforguest,
                                              phone: _userController
                                                  .homePhoneController.text
                                                  .toString(),
                                              existingStreet: _userController.street.value,
                                              existingCity: _userController.city.value,
                                              existingState: _userController.state.value,
                                              existingZipCode: _userController.zipcode.value,
                                            ),
                                          );
                                        },
                                        child: const Text("Edit Address"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Clear from checkout controller
                                          _userController.street.value = '';
                                          _userController.city.value = '';
                                          _userController.state.value = '';
                                          _userController.zipcode.value = '';
                                          
                                          // Also clear from AuthController for Edit Profile sync
                                          _authController.editaddressController.clear();
                                          _authController.editcityController.clear();
                                          _authController.editzipcodeController.clear();
                                          _authController.editStateController.clear();
                                          
                                          // Update observable values
                                          _authController.address.value = '';
                                          
                                          // Clear from SharedPreferences to prevent reload
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.remove('user_address');
                                          await prefs.remove('user_zipCode');
                                          await prefs.remove('user_city');
                                          await prefs.remove('user_state');
                                          
                                          // IMPORTANT: Update backend API to persist the removal
                                          await _authController.sendUserData(
                                            phone: _authController.editPhoneController.text,
                                            name: _authController.editNameController.text,
                                            email: _authController.editemailController.text,
                                            street: '',
                                            city: '',
                                            state: '',
                                            zipCode: '',
                                            country: 'UAE',
                                            showSuccessMessage: false,
                                          );
                                        },
                                        child: const Text(
                                          "Remove Address",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          : SizedBox.fromSize(),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : StoreSelectionScreen(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (_userController.isHomeDelivery.value) {
                  final homePhone =
                      _userController.homePhoneController.text.trim();
                  if (homePhone.isEmpty || !_isValidUaePhone(homePhone)) {
                    setState(() {
                      _homePhoneError = homePhone.isEmpty
                          ? 'Phone is required'
                          : 'Enter a valid UAE number';
                    });
                    Get.snackbar('Warning', 'Please enter a valid phone number',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }
                  
                  // Sync phone to edit profile first
                  _authController.editPhoneController.text = homePhone;
                  _authController.phoneNumber.value = homePhone;
                  
                  if (_userController.street.value.isEmpty && _userController.activeStep.value == 0) {
                    // Save phone to backend BEFORE showing address form
                    await _authController.sendUserData(
                      phone: homePhone,
                      name: _authController.editNameController.text,
                      email: _authController.editemailController.text,
                      street: _authController.editaddressController.text,
                      city: _authController.editcityController.text,
                      state: _authController.editStateController.text,
                      zipCode: _authController.editzipcodeController.text,
                      country: 'UAE',
                      showSuccessMessage: false,
                    );
                    
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => AddressDetailsBottomSheet(
                        isforGuest: widget.isforguest,
                        phone: homePhone,
                      ),
                    );
                  } else {
                    // Sync phone and address to edit profile before continuing
                    _syncToAuthController();
                    
                    setState(() {
                      _userController.activeStep.value = 1;
                    });
                  }
                } else {
                  final pickupPhone =
                      _userController.phoneController.text.trim();
                  
                  // Debug current state
                  print('🔍 Continue button pressed for pickup');
                  print('   selectedStoreIndex: ${_userController.selectedStoreIndex?.value}');
                  print('   storeId: "${_userController.storeId.value}"');
                  print('   storeName: "${_userController.storeName.value}"');
                  print('   storeAddress: "${_userController.storeAddress.value}"');
                  print('   storePhone: "${_userController.storePhone.value}"');
                  print('   pickupPhone: "$pickupPhone"');
                  
                  // Validate store selection
                  if (_userController.selectedStoreIndex?.value == null ||
                      _userController.selectedStoreIndex!.value == -1) {
                    print('❌ No store selected');
                    Get.snackbar('Warning', 'Please choose one store address',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }
                  
                  // Validate phone
                  if (pickupPhone.isEmpty || !_isValidUaePhone(pickupPhone)) {
                    print('❌ Invalid pickup phone');
                    Get.snackbar('', 'Please enter a valid phone number',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }
                  
                  // Validate store details are populated
                  if (_userController.storeId.value.trim().isEmpty ||
                      _userController.storeName.value.trim().isEmpty ||
                      _userController.storeAddress.value.trim().isEmpty) {
                    print('❌ Store details missing after selection');
                    Get.snackbar('Error', 
                        'Store information is missing. Please select a store again.',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }
                  
                  print('✅ All validations passed');
                  
                  // Sync phone to edit profile first
                  _authController.editPhoneController.text = pickupPhone;
                  _authController.phoneNumber.value = pickupPhone;
                  
                  // Save phone to backend
                  await _authController.sendUserData(
                    phone: pickupPhone,
                    name: _authController.editNameController.text,
                    email: _authController.editemailController.text,
                    street: _authController.editaddressController.text,
                    city: _authController.editcityController.text,
                    state: _authController.editStateController.text,
                    zipCode: _authController.editzipcodeController.text,
                    country: 'UAE',
                    showSuccessMessage: false,
                  );
                  
                  _syncToAuthController();
                  
                  setState(() {
                    _userController.activeStep.value = 1;
                  });
                }
              },
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
