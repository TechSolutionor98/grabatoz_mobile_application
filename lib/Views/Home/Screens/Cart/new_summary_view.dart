import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:graba2z/Api/Services/apiservices.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/checkout_controller.dart';
import 'package:graba2z/Controllers/paymentprovider.dart';
import 'package:graba2z/Utils/appcolors.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Utils/image_helper.dart';
import 'package:graba2z/Utils/packages.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class NewSummaryView extends StatefulWidget {
  String shippingType;
  String phone;
  String companyName;
  String companyAddress;
  String customerEmail;
  String addressCustomer;
  double subtotal;
  List<DeliveryMethod> deliveryMethods;
  NewSummaryView(
      {super.key,
      required this.addressCustomer,
      required this.companyAddress,
      required this.companyName,
      required this.customerEmail,
      required this.phone,
      required this.shippingType,
      required this.subtotal,
      required this.deliveryMethods});

  @override
  State<NewSummaryView> createState() => _NewSummaryViewState();
}

class _NewSummaryViewState extends State<NewSummaryView> {
  UserController _userController = Get.put(UserController());
  CartNotifier _cartNotifier = Get.put(CartNotifier());
  final cart2provider = Get.put(CartNotifier());
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
          child: Row(
            children: [
              Text(
                'Delivery Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Replace with kdefblackColor if needed
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: defaultStyledContainer(
            child: widget.shippingType == 'Home Delivery'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Home Delivery',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(),
                      Text(widget.customerEmail),
                      Text("+971${widget.phone}"),
                      Text(widget.addressCustomer),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Store Pickup',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(),
                      Text("Phone: +971${widget.phone}"),
                      Text(widget.companyName),
                      Text(widget.companyAddress),
                      // text
                    ],
                  ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
          child: Row(
            children: [
              Text(
                'Order Notes (Optional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Replace with kdefblackColor if needed
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _userController.optionalNote,
          decoration: InputDecoration(
              labelText: "Note",
              hintStyle: TextStyle(color: Colors.grey),
              hintText: "Write here",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey))),
        ),
        widget.shippingType == 'Home Delivery'
            ? _cartNotifier.totalAmount.value <= 500
                ? Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              'Delivery Options',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 3,
                        child: DropdownButtonFormField(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            hintText: "Select Delivery Method",
                            border: InputBorder.none,
                          ),
                          value: _cartNotifier
                                  .selectedDeliveryMethodId.value.isEmpty
                              ? null
                              : _cartNotifier.selectedDeliveryMethodId.value,
                          items: widget.deliveryMethods.map((method) {
                            final formattedText =
                                "${method.name} (AED ${method.charge.toStringAsFixed(2)})";
                            return DropdownMenuItem(
                              value: method.id,
                              child: Text(formattedText),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _cartNotifier.selectedDeliveryMethodId.value =
                                value ?? '';

                            final selectedMethod =
                                widget.deliveryMethods.firstWhere(
                              (method) => method.id == value,
                              orElse: () => DeliveryMethod(
                                  id: '',
                                  name: '',
                                  charge: 0.0,
                                  deliveryTime: ''),
                            );

                            _cartNotifier.deliveryFeeCharge.value =
                                selectedMethod.charge;
                            _cartNotifier.totalAmount.value = widget.subtotal +
                                _cartNotifier.deliveryFeeCharge.value;

                            log('Selected delivery fee: ${_cartNotifier.deliveryFeeCharge.value}');
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
          child: Row(
            children: [
              Text(
                'YOUR ORDER',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Replace with kdefblackColor if needed
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart2provider.cartOtherInfoList.length,
          itemBuilder: (context, index) {
            var cartItem = cart2provider.cartOtherInfoList[index];

            String formattedDate = cartItem.addedToCartTime != null
                ? DateFormat('MMM dd, yyyy h:mm a')
                    .format(cartItem.addedToCartTime!)
                : 'No Date';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: cartItem.productImage?.isNotEmpty ?? false
                              ? ImageHelper.getUrl(cartItem.productImage.toString())!
                              : "https://i.postimg.cc/SsWYSvq6/noimage.png",
                          imageBuilder: (context, imageProvider) => Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey.shade200,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => SizedBox(
                            width: 55,
                            height: 55,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://i.postimg.cc/SsWYSvq6/noimage.png',
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.productName ?? "",
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${(cartItem.productPrice?.toDouble() ?? 0.0) * (cartItem.quantity ?? 0)} AED",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .green, // Use kPrimaryColor if needed
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dated: $formattedDate",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Quantity: ${cartItem.quantity == 1 ? '1 pc' : '${cartItem.quantity} pcs'}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0),
              child: defaultStyledContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow("Subtotal",
                        "AED ${widget.subtotal.toStringAsFixed(2)}"),
                    15.0.heightbox,
                    _buildSummaryRow(
                      "VAT Included",
                      "AED ${(widget.subtotal*5/100).toStringAsFixed(2)}",
                    ),
                    15.0.heightbox,
                    _buildSummaryRow(
                      "Shipping",
                      widget.shippingType == 'Home Delivery' &&
                              _cartNotifier.totalAmount.value <= 500
                          ? "AED ${_cartNotifier.deliveryFeeCharge.value.toStringAsFixed(2)}"
                          : 'Free',
                    ),
                    15.0.heightbox,
                    _buildSummaryRow(
                      "Total Amount",
                      widget.shippingType == 'Home Delivery' &&
                          _cartNotifier.totalAmount.value <= 500
                          ? "AED ${_cartNotifier.totalAmount.value}"
                          : 'AED ${_cartNotifier.totalAmount.value-20}',
                      // "AED ${_cartNotifier.totalAmount.value}",
                      isBold: true,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: defaultPadding(vertical: 10),
              child: GetBuilder<ApiServiceController>(builder: (
                provider,
              ) {
                return PrimaryButton(
                  buttonText: "Continue to payment",
                  onPressFunction: () async {
                    _userController.activeStep.value = 2;
                  },
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value,
      {bool isBold = false, VoidCallback? ontap}) {
    return GestureDetector(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryMethod {
  final String id;
  final String name;
  final double charge;
  final String deliveryTime;

  DeliveryMethod({
    required this.id,
    required this.name,
    required this.charge,
    required this.deliveryTime,
  });

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      id: json['_id'],
      name: json['name'],
      charge: (json['charge'] as num).toDouble(),
      deliveryTime: json['deliveryTime'] ?? '',
    );
  }
}
