import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart'; // compute
import 'package:graba2z/Utils/product_sorting.dart'; // isolate sorter
import 'package:get/get.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/brand_controller.dart';
import 'package:graba2z/Controllers/home_controller.dart';
import 'package:graba2z/Controllers/searchController.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Filter%20Screen/filter.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cart.dart';
import 'package:graba2z/Views/Home/home.dart';
import 'package:graba2z/Views/Product%20Folder/newProduct_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/packages.dart';

const String _homeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M4 12L12 4L20 12" />
  <path d="M5 12V20H10V15H14V20H19V12" />
</svg>
''';

class NewAllProduct extends StatefulWidget {
  final String id; // Initial category/brand/etc. ID
  final String parentType; // 'parentCategory', 'brand', 'subcategory', 'featured'
  final String? displayTitle; // Add: human-readable title to show on AppBar
  NewAllProduct({
    super.key,
    required this.id,
    required this.parentType,
    this.displayTitle,
  });

  @override
  State<NewAllProduct> createState() => _NewAllProductState();
}

class _NewAllProductState extends State<NewAllProduct> {
  double minPrice = 0;
  double maxPrice = 50000;

  final HomeController _homeController = Get.find<HomeController>();
  final BrandController _brandController = Get.find<BrandController>();

  String sortby = '';
  String firstNameFromFilter = '';
  String firstValueFromFilter = '';
  String secondNameFromFilter = '';
  String secondValueFromFilter = '';
  String brandNameFromFilter = '';
  String brandIdFromFilter = '';

  late String _effectiveId;
  late String _effectiveParentType;

  // Pagination state
  static const int _pageSize = 10;
  int _visibleCount = _pageSize;

  // Fetch-all support (SearchScreen parity)
  // CHANGE: use a local (non-Get registered) SearchScController to avoid affecting SearchScreen
  final SearchScController _searchScController = SearchScController();
  bool _loadingAll = false;

  // NEW: keep last-used fetch params for pagination
  String _p1n = '', _p1v = '', _p2n = '', _p2v = '', _p3n = '', _p3v = '';
  double _minP = 0, _maxP = 0;
  bool _loadingMore = false;

  // NEW: cache sorted list for non-feature branch
  List<dynamic> _sortedLocalProducts = const [];
  late Worker _sortedWorker;

  // Sort button UI state
  String _sortLabel = 'Newest First';
  bool _sortMenuOpen = false;

  // Helper to cap sort button width responsively
  double _calcSortMaxWidth(BoxConstraints c) => math.min(220.0, c.maxWidth * 0.38);

  // Reusable sort menu button
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
        PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
        PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
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
              child: const Icon(Icons.expand_more, size: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Extractors for sorting
  num _priceOf(dynamic e) {
    if (e is Map) {
      final keys = ['finalPrice', 'discountedPrice', 'salePrice', 'sellingPrice', 'price'];
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

  // Apply the selected sorting inside stock groups, then combine (Available -> PreOrder -> Out of Stock)
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
        cmp = (a, b) => _nameOf(a).toLowerCase().compareTo(_nameOf(b).toLowerCase());
        break;
      case 'Newest First':
      default:
        // Preserve incoming order (already grouped)
        return base;
    }

    available.sort(cmp);
    preorder.sort(cmp);
    outOfStock.sort(cmp);

    return [...available, ...preorder, ...outOfStock];
  }

  // Tailwind-like style (small): px-3 py-1 bg-green-600 text-white rounded-md shadow hover:bg-green-700 transition-colors font-semibold
  ButtonStyle _webLikeLoadMoreStyle() {
    const Color green600 = Color(0xFF16A34A); // Tailwind green-600
    const Color green700 = Color(0xFF15803D); // Tailwind green-700
    return ButtonStyle(
      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 4)), // smaller px-3 py-1
      minimumSize: MaterialStateProperty.all(const Size(0, 32)), // compact height
      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // FIX: was MaterialStateProperty.shrinkWrap
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) => states.contains(MaterialState.pressed) ? green700 : green600, // hover/pressed -> green-700
      ),
      foregroundColor: MaterialStateProperty.all(Colors.white), // text-white
      elevation: MaterialStateProperty.all(4), // shadow
      shadowColor: MaterialStateProperty.all(Colors.black.withOpacity(0.25)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // rounded-md
      ),
      textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), // text-sm
      overlayColor: MaterialStateProperty.all(green700.withOpacity(0.12)), // transition-colors feedback
    );
  }

  @override
  void initState() {
    super.initState();
    _effectiveId = widget.id;
    _effectiveParentType = _normalizeParentType(widget.parentType);
    _visibleCount = _pageSize;
    log("parent type $_effectiveParentType id $_effectiveId");
    // NEW: recompute sorted list when local controller's products change (debounced)
    _sortedWorker = debounce<List<dynamic>>(
      _searchScController.searhProducts,
      (_) => _recomputeSortedLocal(),
      time: const Duration(milliseconds: 60),
    );

    _fetchAllFromSearchForInitial();

  }

  Future<void> _recomputeSortedLocal() async {
    final listCopy = _searchScController.searhProducts.toList(growable: false);
    if (listCopy.isEmpty) {
      _sortedLocalProducts = const [];
      if (mounted) setState(() {});
      return;
    }
    try {
      final sorted = await compute(sortProductsForDisplay, listCopy);
      _sortedLocalProducts = sorted;
      if (mounted) setState(() {});
    } catch (_) {
      _sortedLocalProducts = _getSortedDisplayProducts(listCopy);
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    // NEW: dispose debounce worker
    _sortedWorker.dispose();
    super.dispose();
  }

  // Normalize to API param names
  String _normalizeParentType(String v) {
    if (v.toLowerCase() == 'category') return 'parentCategory';
    return v;
  }

  // Initial fetch using the same logic as SearchScreen
  Future<void> _fetchAllFromSearchForInitial() async {
    if (_effectiveParentType == 'featured') {
      // ...existing featured handling...
      return;
    }

    setState(() => _loadingAll = true);
    try {
      _searchScController.searhProducts.clear();
      _searchScController.fetchedIds.clear();

      // CHANGE: fetch up to 2.5k for accurate total count (instead of 10k+)
      _searchScController.limit.value = 2500;
      _searchScController.isrequesting.value = 1;
      _searchScController.isMoreDataAvailableForShop.value = true;
      _searchScController.setSearchQuery('');

      // remember params for Load More (kept for consistency)
      _p1n = _effectiveParentType;
      _p1v = _effectiveId;
      _p2n = _p2v = _p3n = _p3v = '';
      _minP = 0; _maxP = 0;

      await _searchScController.fetchAdsbysearchWithFilters(
        sortby, _p1n, _p1v, _p2n, _p2v, _p3n, _p3v, _minP, _maxP,
      );

      _searchScController.isrequesting.value = 0;
      // Stop further server paging; use local "Load More"
      _searchScController.isMoreDataAvailableForShop.value = false;
      if (mounted) setState(() => _loadingAll = false);
    } catch (_) {
      _searchScController.isrequesting.value = 0;
      _searchScController.isMoreDataAvailableForShop.value = false;
      if (mounted) setState(() => _loadingAll = false);
    }
  }

  // NEW: Load next page if available
  Future<void> _loadMoreIfAvailable() async {
    if (_loadingMore || !_searchScController.isMoreDataAvailableForShop.value) return;
    setState(() => _loadingMore = true);
    try {
      await _searchScController.fetchAdsbysearchWithFilters(
        sortby, _p1n, _p1v, _p2n, _p2v, _p3n, _p3v, _minP, _maxP,
      );
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // NEW: local unified filter apply, mirrors SearchScreen but scoped to this page
  Future<void> _applyFiltersForThisScreen(Map<String, dynamic> filters) async {
    double _asDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    String sanitize(dynamic v) {
      final s = (v ?? '').toString().trim();
      final low = s.toLowerCase();
      if (s.isEmpty || low == 'all' || low == 'null' || low == 'none') return '';
      return s;
    }

    // Reset/prepare local state
    _searchScController.limit.value = 2500; // CHANGE: fetch up to 2.5k for accuracy
    _searchScController.searhProducts.clear();
    _searchScController.fetchedIds.clear();
    _searchScController.hasFilterApplied.value = true;
    _searchScController.isrequesting.value = 1;
    _searchScController.isMoreDataAvailableForShop.value = true;
    _searchScController.setSearchQuery('');
    _visibleCount = _pageSize;
    setState(() {});

    final double minPrice = _asDouble(filters['minPrice']);
    final double maxPrice = _asDouble(filters['maxPrice']);
    final String sort = (filters['sortBy'] ?? '').toString();

    final bool isDefaultPrice = (minPrice <= 1) && (maxPrice >= 100000);
    final double apiMin = isDefaultPrice ? 0 : minPrice;
    final double apiMax = isDefaultPrice ? 0 : maxPrice;

    final String catId = sanitize(filters['parentCategoryId']);
    final String subId = sanitize(filters['subcategoryId']);
    final String brId  = sanitize(filters['brandId']);

    // remember params for Load More
    _minP = apiMin; _maxP = apiMax;

    try {
      if (brId.isNotEmpty && subId.isNotEmpty) {
        _p1n = 'subcategory'; _p1v = subId; _p2n = 'brand'; _p2v = brId; _p3n = _p3v = '';
      } else if (brId.isNotEmpty && catId.isNotEmpty) {
        _p1n = 'parentCategory'; _p1v = catId; _p2n = _p2v = ''; _p3n = 'brand'; _p3v = brId;
      } else if (brId.isNotEmpty) {
        _p1n = 'brand'; _p1v = brId; _p2n = _p2v = _p3n = _p3v = '';
      } else if (catId.isNotEmpty) {
        _p1n = 'parentCategory'; _p1v = catId; _p2n = _p2v = _p3n = _p3v = '';
        _p1n = 'parentCategory'; _p1v = catId; _p2n = _p2v = _p3n = _p3v = '';
      } else if (subId.isNotEmpty) {
        _p1n = 'subcategory'; _p1v = subId; _p2n = _p2v = _p3n = _p3v = '';
      } else {
        _p1n = _p1v = _p2n = _p2v = _p3n = _p3v = '';
      }

      await _searchScController.fetchAdsbysearchWithFilters(
        sort, _p1n, _p1v, _p2n, _p2v, _p3n, _p3v, _minP, _maxP,
      );
    } finally {
      _searchScController.isrequesting.value = 0;
      // Stop further server paging; use local "Load More"
      _searchScController.isMoreDataAvailableForShop.value = false;
      if (mounted) setState(() {});
    }
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
        // Treat all other/unknown as available
        availableItems.add(product);
      }
    }
    // CHANGE: Available -> PreOrder -> Out of Stock
    return [...availableItems, ...preorderItems, ...outOfStockItems];
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  String _computeTitle() {
    // 1) Prefer explicit title if provided
    final t = (widget.displayTitle ?? '').trim();
    if (t.isNotEmpty) return t;

    // 2) Derive from type/id
    switch (_effectiveParentType) {
      case 'featured':
        return 'Featured Products';
      case 'brand':
        final name = _findBrandNameById(_effectiveId);
        return name?.isNotEmpty == true ? name! : 'Brand';
      case 'parentCategory':
        final name = _findCategoryNameById(_effectiveId);
        return name?.isNotEmpty == true ? name! : 'Category';
      case 'subcategory':
        final name = _findSubCategoryNameById(_effectiveId);
        return name?.isNotEmpty == true ? name! : 'Subcategory';
      default:
        return 'All Products';
    }
  }

  String? _findBrandNameById(String id) {
    for (final b in _brandController.brandList) {
      final bid = (b?['_id'] ?? '').toString();
      if (bid == id) return (b?['name'] ?? '').toString();
    }
    return null;
  }

  String? _findCategoryNameById(String id) {
    // Try both lists, whichever is populated
    try {
      for (final c in _homeController.category) {
        if ((c.sId ?? '') == id) return c.name ?? '';
      }
    } catch (_) {}
    try {
      for (final c in _homeController.filterCategory) {
        if ((c.sId ?? '') == id) return c.name ?? '';
      }
    } catch (_) {}
    return null;
  }

  String? _findSubCategoryNameById(String id) {
    try {
      for (final s in _homeController.filterSubcategory) {
        if ((s.sId ?? '') == id) return s.name ?? '';
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Get.put(BottomNavigationController());
    return Scaffold(
      endDrawer: FilterScreen(
        onApplyFilters: (filters) async {
          // Apply filters to this screen only (local controller)
          await _applyFiltersForThisScreen(filters);
        },
      ),
      appBar: CustomAppBar(
        // Change: show dynamic title
        showLeading: true,
        leadingWidget: Builder(
          builder: (context){
            return IconButton(onPressed: (){
              if (widget.id == '2') {
                navigationProvider.setTabIndex(0);
              } else {
                Navigator.of(context).pop();
              }
            }, icon: const Icon(Icons.arrow_back_ios, size: 20),);
          },),
        titleText: _computeTitle(),
        actionicon: GetBuilder<CartNotifier>(
          builder: (cartNotifier) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    Get.put(BottomNavigationController()).setTabIndex(0);
                    Get.offAll(() => Home());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SvgPicture.string(
                      _homeSvg,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      semanticsLabel: 'Home',
                    ),
                  ),
                ),
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
      // CHANGE: single Obx that switches from featured view to filtered-search view when filters are applied
      body: Obx(() {
        final bool showFeaturedView = _effectiveParentType == 'featured' && !_searchScController.hasFilterApplied.value;

        if (showFeaturedView) {
          final isLoading = _homeController.isLoadingFeaturedProducts?.value ?? true;
          final raw = _homeController.featuredProducts ?? <dynamic>[].obs;
          if (isLoading) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GridView.builder(
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.64,
                  ),
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
          final display = _getSortedDisplayProducts(raw);
          if (display.isEmpty) return const Center(child: Text("No products found."));
          // Apply UI sort
          final applied = _applySortOption(display);
          final visible = applied.take(_visibleCount).toList();
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header with responsive sort button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = _calcSortMaxWidth(constraints);
                        return Row(
                          children: [
                            const Icon(Icons.inventory_2, size: 18, color: kPrimaryColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${applied.length} products found',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.64,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final productData = visible[index];
                        return NewProductCard(
                          prdouctList: productData,
                          onAddedToCart: _showAddedToCartPopup,
                        );
                      },
                      childCount: visible.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: _visibleCount < display.length,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Center(
                        child: ElevatedButton(
                          style: _webLikeLoadMoreStyle(),
                          onPressed: () {
                            final total = display.length;
                            final next = _visibleCount + _pageSize;
                            setState(() {
                              _visibleCount = next > total ? total : next;
                            });
                          },
                          child: const Text('Load More'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          );
        }

        // Filtered/search branch (used for featured after filters are applied)
        final sc = _searchScController;

        // Show shimmer when requesting & list empty
        if ((sc.isrequesting.value == 1 || _loadingAll) && sc.searhProducts.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.64,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        // NEW: use cached sorted instead of re-sorting every build
        // If cache is empty, fall back to inline sort to avoid the brief "No products" flash
        final base = _sortedLocalProducts.isNotEmpty
            ? _sortedLocalProducts
            : _getSortedDisplayProducts(sc.searhProducts);
        if (base.isEmpty && sc.isrequesting.value == 0) {
          return const Center(child: Text("No products found."));
        }
        // Apply UI sort
        final displayable = _applySortOption(base);
        final visibleProducts = displayable.take(_visibleCount).toList();

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with responsive sort button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = _calcSortMaxWidth(constraints);
                      return Row(
                        children: [
                          const Icon(Icons.inventory_2, size: 18, color: kPrimaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${displayable.length} products',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                padding: const EdgeInsets.symmetric(horizontal: 5),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.64,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final productData = visibleProducts[index];
                      return NewProductCard(
                        prdouctList: productData,
                        onAddedToCart: _showAddedToCartPopup,
                      );
                    },
                    childCount: visibleProducts.length,
                    addAutomaticKeepAlives: false, // perf flags
                    addRepaintBoundaries: true,
                    addSemanticIndexes: false,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              // Load More reveals locally (server paging disabled when fetching 2.5k)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Center(
                    child: (_visibleCount < displayable.length)
                        ? ElevatedButton(
                            style: _webLikeLoadMoreStyle(),
                            onPressed: () {
                              final total = displayable.length;
                              final next = _visibleCount + _pageSize;
                              setState(() {
                                _visibleCount = next > total ? total : next;
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
          ),
        );
      }),

      bottomNavigationBar: widget.id == '2'
          ? const SizedBox.shrink()
          : SafeArea(
        child: SizedBox(
          height: 60,
          child: Builder(builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: Container(
                color: kSecondaryColor,
                child: Center(
                  child: Padding(
                    padding: defaultPadding(vertical: 10),
                    child: Text(
                      'Filter By',
                      style: TextStyle(
                        color: kdefwhiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),

    );
  }
}
