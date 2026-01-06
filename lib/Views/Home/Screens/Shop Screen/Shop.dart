import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Utils/image_helper.dart';
import '../../../../Controllers/productcontroller.dart';

class Shop extends StatefulWidget {
  final String id;
  final String parentType;
  final String? displayTitle;

  const Shop({
    Key? key,
    required this.id,
    required this.parentType,
    this.displayTitle,
  }) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final ShopController controller = Get.put(ShopController());

  static const int pageSize = 12;
  int visibleCount = pageSize;

  @override
  void initState() {
    super.initState();
    controller.fetchProducts(
      id: widget.id,
      parentType: widget.parentType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 APP BAR WITH PRODUCT COUNT
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() {
          final count = controller.productList.length;
          return Text(
            widget.displayTitle != null
                ? "${widget.displayTitle} ($count)"
                : "Shop ($count)",
          );
        }),
      ),

      // 🔹 BODY
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.productList.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        final products =
        controller.productList.take(visibleCount).toList();

        return CustomScrollView(
          slivers: [

            // 🔹 SHOWING X OF Y TEXT
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  "Showing ${products.length} of ${controller.productList.length} products",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // 🔹 PRODUCT GRID
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = products[index];

                    final String name =
                        product['name']?.toString() ?? "No Name";

                    final int price =
                        int.tryParse(product['price'].toString()) ?? 0;

                    final int offerPrice =
                        int.tryParse(product['offerPrice'].toString()) ??
                            price;

                    final int discount =
                        int.tryParse(product['discount'].toString()) ?? 0;

                    final String rawImage = product['image']?.toString() ?? "";
                    final String imageUrl = ImageHelper.getUrl(rawImage);

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 IMAGE
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                              const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Image.asset("images.noimage.png"),
                              ),
                            ),
                          ),

                          // 🔹 NAME
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 🔹 PRICE
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Text(
                                  "\$$offerPrice",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (discount > 0)
                                  Text(
                                    "\$$price",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      decoration:
                                      TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),

            // 🔹 LOAD MORE BUTTON
            if (visibleCount < controller.productList.length)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          visibleCount += pageSize;
                          if (visibleCount >
                              controller.productList.length) {
                            visibleCount =
                                controller.productList.length;
                          }
                        });
                      },
                      child: const Text("Load More"),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      }),
    );
  }
}
