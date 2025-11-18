import 'package:intl/intl.dart';

class Order {
  final List<OrderItem> items;
  final String trackingNo;
  final int quantity;
  final double price;
  final String dateStamp;
  final String status;

  Order({
    required this.items,
    required this.trackingNo,
    required this.quantity,
    required this.price,
    required this.dateStamp,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = (json['line_items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList();

    return Order(
      items: items,
      trackingNo: json['number'],
      quantity: json['line_items'][0]['quantity'],
      price: double.parse(json['total']),
      dateStamp: json['date_created'] != null
          ? _formatDate(json['date_created'])
          : "No Date",
      status: json['status'],
    );
  }
  // Helper function to format the date properly

  static String _formatDate(String dateString) {
    try {
      // Convert API UTC time to local time
      DateTime parsedDate =
          DateTime.parse(dateString).toUtc(); // API returns UTC
      DateTime localDate = parsedDate.toLocal(); // Convert to Local Time

      return DateFormat('dd MMM yyyy, hh:mm a')
          .format(localDate); // Format the local time
    } catch (e) {
      print("Date parsing error: $e");
      return dateString; // Return original if parsing fails
    }
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price; // ✅ Added price field

  OrderItem(
      {required this.productName, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(), // ✅ Ensure price is a double
    );
  }
}
