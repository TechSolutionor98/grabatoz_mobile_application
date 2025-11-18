import 'package:graba2z/Utils/appextensions.dart';

import '../../../../../../Models/ordermodel.dart';
import '../../../../../../Utils/packages.dart';

class OrderCard extends StatelessWidget {
  final Widget actionButton;
  final Widget bottomWidget;
  final String status;
  String totalPrice;
  String createdDate;
  String orderId;
  List orderItems;
  OrderCard({
    super.key,
    required this.actionButton,
    required this.status,
    required this.bottomWidget,
    required this.orderItems,
    required this.totalPrice,
    required this.createdDate,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultPadding(),
      child: defaultStyledContainer(
        child: Column(
          children: [
            // Product List
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align products to the left
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: orderItems
                        .map(
                          (item) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                maxLines: 1,
                                overflow: TextOverflow
                                    .ellipsis, // Ensures text doesn't overflow
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Pcs:x${item['quantity']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kmediumblackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            10.0.heightbox,

// Tracking Number & Date Stamp in One Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dated:",
                  style: TextStyle(
                    fontSize: 12,
                    color: kSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  " ${createdDate}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            10.0.heightbox,
// Tracking Number & Date Stamp in One Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tracking Number:",
                  style: TextStyle(
                    fontSize: 12,
                    color: kSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "#${orderId.toString().substring((orderId.toString().length - 6))}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            10.0.heightbox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Total Products: ',
                    style: const TextStyle(
                        fontSize: 12,
                        color: kSecondaryColor,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: '(${orderItems.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: "Montserrat",
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Price: ',
                    style: const TextStyle(
                        fontSize: 12,
                        color: kSecondaryColor,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'AED${totalPrice}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            20.0.heightbox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bottomWidget,
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: status == 'Delivered'
                        ? kPrimaryColor
                        : status == 'Confirmed'
                            ? Colors.black
                            : status == 'Processing'
                                ? Colors.blue
                                : status == 'Cancelled'
                                    ? kredColor
                                    : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
