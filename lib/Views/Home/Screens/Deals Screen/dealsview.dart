import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Product%20Folder/newProduct_card.dart';
import '../../../../Controllers/addtocart.dart';
import '../../../../Controllers/bottomController.dart';
import '../../../../Controllers/deals_controller.dart';
import '../../../../Utils/appcolors.dart';
import '../../../../Widgets/customappbar.dart';
import 'deals_product_card.dart';
import '../Cart/cart.dart';

class offerDeals extends StatefulWidget {
  final String? slug;
  final String? displayTitle;

  const offerDeals({
    Key? key,
    this.slug,
    this.displayTitle,
  }) : super(key: key);

  @override
  State<offerDeals> createState() => _offerDealsState();
}

class _offerDealsState extends State<offerDeals> {
  late DealsController controller;

  static const int pageSize = 12;
  int visibleCount = pageSize;

  double _calcSortMaxWidth(BoxConstraints c) =>
      math.min(220.0, c.maxWidth * 0.38);
  List<dynamic> _sortedLocalProducts = const [];

  @override
  void initState() {
    super.initState();
    // Use slug as tag to ensure unique controller instances
    final tag = widget.slug ?? 'default-deals';
    controller = Get.put(DealsController(), tag: tag);

    // Fetch products immediately
    if (widget.slug != null && widget.slug!.isNotEmpty) {
      controller.fetchDealsProducts(slug: widget.slug!);
      log("🔄 Fetching deals products for slug: ${widget.slug}");
    }
  }

  @override
  void dispose() {
    // Clean up controller when leaving this screen
    final tag = widget.slug ?? 'default-deals';
    Get.delete<DealsController>(tag: tag);
    super.dispose();
  }

  void _showAddedToCartPopup() {
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Added to cart',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (entry.mounted) entry.remove();
    });
  }

  String _sortLabel = 'Newest First';
  bool _sortMenuOpen = false;

  Widget _sortMenuButton() {
    return PopupMenuButton<String>(
      onOpened: () => setState(() => _sortMenuOpen = true),
      onCanceled: () => setState(() => _sortMenuOpen = false),
      onSelected: (val) => setState(() {
        _sortLabel = val;
        _sortMenuOpen = false;
      }),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'Newest First', child: Text('Newest First')),
        PopupMenuItem(
            value: 'Price: Low to High', child: Text('Price: Low to High')),
        PopupMenuItem(
            value: 'Price: High to Low', child: Text('Price: High to Low')),
        PopupMenuItem(value: 'Name: A to Z', child: Text('Name: A to Z')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                _sortLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(width: 6),
            Transform.rotate(
              angle: _sortMenuOpen ? 3.14159 : 0,
              child:
                  const Icon(Icons.expand_more, size: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _webLikeLoadMoreStyle() {
    const Color green600 = Color(0xFF16A34A);
    const Color green700 = Color(0xFF15803D);
    return ButtonStyle(
      padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
      minimumSize: MaterialStateProperty.all(const Size(0, 32)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) => states.contains(MaterialState.pressed)
            ? green700
            : green600,
      ),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.all(4),
      shadowColor: MaterialStateProperty.all(Colors.black.withOpacity(0.25)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
      ),
      textStyle: MaterialStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      overlayColor: MaterialStateProperty.all(
          green700.withOpacity(0.12)),
    );
  }

  // Extractors for sorting
  num _priceOf(dynamic e) {
    if (e is Map) {
      final keys = [
        'finalPrice',
        'discountedPrice',
        'salePrice',
        'sellingPrice',
        'price',
        'offerPrice'
      ];
      for (final k in keys) {
        final v = e[k];
        if (v is num) return v;
        if (v is String) {
          final n = num.tryParse(v);
          if (n != null) return n;
        }
      }
    }
    return 0;
  }

  String _nameOf(dynamic e) {
    if (e is Map) {
      final keys = ['name', 'productName', 'title'];
      for (final k in keys) {
        final v = e[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return '';
  }

  // Apply the selected sorting inside stock groups
  List<dynamic> _applySortOption(List<dynamic> base) {
    if (base.isEmpty) return base;

    final available = <dynamic>[];
    final preorder = <dynamic>[];
    final outOfStock = <dynamic>[];

    for (final e in base) {
      if (e is Map) {
        final s = (e['stockStatus'] ?? '').toString().toLowerCase();
        if (s == 'preorder' || s == 'pre order') {
          preorder.add(e);
        } else if (s == 'out of stock') {
          outOfStock.add(e);
        } else {
          available.add(e);
        }
      } else {
        available.add(e);
      }
    }

    int Function(dynamic, dynamic)? cmp;
    switch (_sortLabel) {
      case 'Price: Low to High':
        cmp = (a, b) => _priceOf(a).compareTo(_priceOf(b));
        break;
      case 'Price: High to Low':
        cmp = (a, b) => _priceOf(b).compareTo(_priceOf(a));
        break;
      case 'Name: A to Z':
        cmp = (a, b) =>
            _nameOf(a).toLowerCase().compareTo(_nameOf(b).toLowerCase());
        break;
      case 'Newest First':
      default:
        return base;
    }

    available.sort(cmp);
    preorder.sort(cmp);
    outOfStock.sort(cmp);

    return [...available, ...preorder, ...outOfStock];
  }

  List<dynamic> _getSortedDisplayProducts(List<dynamic> productList) {
    if (productList.isEmpty) return [];

    List<dynamic> preorderItems = [];
    List<dynamic> availableItems = [];
    List<dynamic> outOfStockItems = [];

    for (var productElement in productList) {
      if (productElement is! Map<String, dynamic>) {
        continue;
      }
      final product = productElement as Map<String, dynamic>;
      final s = (product['stockStatus'] ?? '').toString().toLowerCase();
      if (s == 'preorder' || s == 'pre order') {
        preorderItems.add(product);
      } else if (s == 'out of stock') {
        outOfStockItems.add(product);
      } else {
        availableItems.add(product);
      }
    }
    return [...availableItems, ...preorderItems, ...outOfStockItems];
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Get.put(BottomNavigationController());
    return Scaffold(
      appBar: CustomAppBar(
        showLeading: true,
        leadingWidget: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            );
          },
        ),
        titleText: widget.displayTitle ?? "Deals",
        actionicon: GetBuilder<CartNotifier>(
          builder: (cartNotifier) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.route(Cart());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image.asset(
                          "assets/icons/addcart.png",
                          color: kdefwhiteColor,
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                    if (cartNotifier.cartOtherInfoList.isNotEmpty) ...[
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: kredColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cartNotifier.cartOtherInfoList.length.toString(),
                            style: const TextStyle(
                                color: kdefwhiteColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),

      // 🔹 BODY
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.productList.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        final base = _sortedLocalProducts.isNotEmpty
            ? _sortedLocalProducts
            : _getSortedDisplayProducts(controller.productList);

        // Apply UI sort
        final displayable = _applySortOption(base);
        final products = displayable.take(visibleCount).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = _calcSortMaxWidth(constraints);
                    return Row(
                      children: [
                        const Icon(Icons.inventory_2,
                            size: 18, color: kPrimaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${controller.productList.length} products found',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: maxW,
                          child: _sortMenuButton(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return DealsProductCard(
                      offerName: widget.displayTitle.toString(),
                      productList: product,
                      onAddedToCart: _showAddedToCartPopup,
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
            // Load More
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Center(
                  child: (visibleCount < controller.productList.length)
                      ? ElevatedButton(
                          style: _webLikeLoadMoreStyle(),
                          onPressed: () {
                            final total = controller.productList.length;
                            final next = visibleCount + pageSize;
                            setState(() {
                              visibleCount = next > total ? total : next;
                            });
                          },
                          child: const Text('Load More'),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        );
      }),
    );
  }
}
