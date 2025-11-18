import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:graba2z/Views/Home/home.dart';
import '../../../../../../Utils/packages.dart';
import '../../../../../../Controllers/delete_account_controller.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBottomSheetOpen = false;
  bool isLoading = false;
  String? _phoneError;
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

  @override
  void initState() {
    super.initState();
    // Always reload fresh data when screen opens
    _authController.getUserProfileData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stateValue = _authController.editStateController.text;
      if (stateValue.isNotEmpty && states.contains(stateValue)) {
        setState(() {
          selectedState = stateValue;
        });
      } else {
        setState(() {
          selectedState = 'Select State';
        });
      }
    });
    
    _authController.editStateController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final stateValue = _authController.editStateController.text;
    if (stateValue.isEmpty) {
      setState(() {
        selectedState = 'Select State';
      });
    } else if (states.contains(stateValue)) {
      setState(() {
        selectedState = stateValue;
      });
    }
  }

  @override
  void dispose() {
    _authController.editStateController.removeListener(_onStateChanged);
    _verificationCodeController.dispose();
    super.dispose();
  }

  AuthController _authController = Get.put(AuthController());
  final DeleteAccountController _deleteAccountController = Get.put(DeleteAccountController());
  final TextEditingController _verificationCodeController = TextEditingController();

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isValidUaePhone(String input) {
    if (input.isEmpty) return true;
    final d = _digitsOnly(input);
    final numPart = d.startsWith('0') ? d.substring(1) : d;
    return numPart.length == 9;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reload profile data when going back to discard unsaved changes
        await _authController.getUserProfileData();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          if (isBottomSheetOpen) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(titleText: "Profile"),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTextField("Full Name",
                                  controller: _authController.editNameController),
                              _buildTextField("Email",
                                  controller: _authController.editemailController),
                              _buildPhoneField(),
                              _buildTextField("Address",
                                  controller: _authController.editaddressController),
                              _buildStateDropdown(),
                              _buildTextField("City",
                                  controller: _authController.editcityController),
                              _buildTextField("Zip Code",
                                  controller: _authController.editzipcodeController),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Obx(
                              () => _authController.isprofileUpdating.value
                                  ? CircularProgressIndicator()
                                  : PrimaryButton(
                                      width: double.infinity,
                                      buttonColor: kPrimaryColor,
                                      textColor: kdefwhiteColor,
                                      onPressFunction: () {
                                        final phone = _authController.editPhoneController.text.trim();
                                        if (phone.isNotEmpty && !_isValidUaePhone(phone)) {
                                          setState(() {
                                            _phoneError = 'Enter a valid UAE phone number';
                                          });
                                          Get.snackbar('Warning', 'Please enter a valid phone number',
                                              backgroundColor: Colors.red, colorText: Colors.white);
                                          return;
                                        }
                                        
                                        _authController.sendUserData(
                                          phone: _authController.editPhoneController.text,
                                          name: _authController.editNameController.text,
                                          email: _authController.editemailController.text,
                                          street: _authController.editaddressController.text,
                                          city: _authController.editcityController.text,
                                          state: selectedState == 'Select State' ? '' : selectedState,
                                          zipCode: _authController.editzipcodeController.text,
                                          country: 'UAE',
                                          showSuccessMessage: true,
                                        );
                                      },
                                      buttonText: "Update",
                                    ),
                            )),
                            Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Text(
                            "or",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Obx(() => _deleteAccountController.isRequestingDeletion.value
                              ? CircularProgressIndicator()
                              : PrimaryButton(
                                  width: double.infinity,
                                  buttonColor: Colors.red,
                                  textColor: kdefwhiteColor,
                                  onPressFunction: _showDeleteConfirmationDialog,
                                  buttonText: "Delete Account",
                                )),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
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
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6,),
          Text("Phone Number"),
          SizedBox(height: 6),
          TextField(
            controller: _authController.editPhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            onChanged: (v) {
              setState(() {
                if (v.trim().isEmpty) {
                  _phoneError = null;
                } else if (!_isValidUaePhone(v)) {
                  _phoneError = 'Enter a valid 9-digit number';
                } else {
                  _phoneError = null;
                }
              });
            },
            decoration: InputDecoration(
              prefix: const Text('+971    '),
              labelText: 'Phone number',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintText: "041234567",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              border: OutlineInputBorder(),
              errorText: _phoneError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text("State/Region"),
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
                _authController.editStateController.text = value == 'Select State' ? '' : value;
              });
            },
            decoration: InputDecoration(
              hintText: "Select State",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.\n\nA verification code will be sent to your email.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestAccountDeletion();
              },
              child: Text('Continue', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestAccountDeletion() async {
    final success = await _deleteAccountController.requestAccountDeletion();
    if (success) {
      _showVerificationCodeDialog();
    }
  }

  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 50,
                      color: kPrimaryColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Enter the 6-digit code sent to your email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _verificationCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        letterSpacing: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '------',
                        hintStyle: TextStyle(
                          letterSpacing: 16,
                          color: Colors.grey[300],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.amber[800]),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Email may take 5-10 minutes to arrive. Check spam folder.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        _verificationCodeController.clear();
                        Navigator.of(context).pop();
                        Get.snackbar(
                          'Resending Code',
                          'Please wait...',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                        await _requestAccountDeletion();
                      },
                      icon: Icon(Icons.refresh, size: 18),
                      label: Text('Resend Code'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _verificationCodeController.clear();
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _deleteAccountController.isVerifyingCode.value
                              ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () => _verifyAndDelete(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _verifyAndDelete() async {
    final code = _verificationCodeController.text.trim();
    
    if (code.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the verification code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (code.length != 6) {
      Get.snackbar(
        'Error',
        'Verification code must be 6 digits',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _deleteAccountController.verifyAccountDeletion(code);
    
    if (success) {
      _verificationCodeController.clear();
      Navigator.of(context).pop(); // Close dialog
      
      // Reset bottom navigation to home tab (index 0)
      final bottomNavProvider = Get.find<BottomNavigationController>();
      bottomNavProvider.setTabIndex(0);
      
      // Navigate to home screen and clear all previous routes
      Get.offAll(() => Home());
    }
  }
}
