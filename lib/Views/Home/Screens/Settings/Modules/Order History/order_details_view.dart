import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Utils/packages.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('MM/dd/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final orderItems = List<Map<String, dynamic>>.from(order['orderItems']);

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Order Details',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Order Tracking ID: #${order['_id'].toString().substring((order['_id'].toString().length - 6))}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 8,
                    ),
                    detailRow(title: 'Status', value: "${order['status']}"),

                    detailRow(
                        title: 'Created',
                        value: "${formatDate(order['createdAt'])}"),

                    detailRow(
                        title: 'Delivery Type',
                        value: "${order['deliveryType']}"),

                    detailRow(
                        title: 'Payment Method',
                        value: "${order['paymentMethod']}"),
                    // Text('Payment Method: ${order['paymentMethod']}'),

                    detailRow(
                        title: 'Customer Note',
                        value: order['customerNotes'] != null
                            ? order['customerNotes'].isEmpty
                                ? "N/A"
                                : "${order['customerNotes']}"
                            : "N/A"),
                    const Divider(),
                    Text('Total: AED ${order['totalPrice']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('Ordered Items:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Product List
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderItems[index];
                  final product = item['product'];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        product['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                          'Qty: ${item['quantity']}  •  AED${item['price']}'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailRow({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title:",
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
