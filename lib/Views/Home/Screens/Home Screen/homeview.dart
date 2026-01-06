import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Api/Models/categorymodel.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/brand_controller.dart';
import 'package:graba2z/Controllers/home_controller.dart';
import 'package:graba2z/Controllers/menuController.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Utils/image_helper.dart';
import 'package:graba2z/Views/Auth/login.dart';
import 'package:graba2z/Views/Auth/signup.dart';
import 'package:graba2z/Views/Home/Screens/Favorite%20Product/favproduct_screen.dart';
import 'package:graba2z/Views/Home/Screens/Search%20Screen/searchscreen.dart';
import 'package:graba2z/Views/Home/Screens/Settings/Modules/Order%20History/track_order_view.dart';
import 'package:graba2z/Widgets/buildCategoryDrawer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:graba2z/Views/Categories%20Folder/allcategoriesscreen.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cart.dart';
import 'package:graba2z/Views/Home/Screens/Home%20Screen/horizontal_scrolling_products.dart';
import 'package:graba2z/Views/Product%20Folder/new_all_products.dart';
import 'package:graba2z/Views/Brand%20Folder/allbrandscreen.dart';
import 'package:graba2z/Views/Brand%20Folder/brandcard.dart';
import 'package:graba2z/Widgets/homecaresoule.dart';
import '../../../../Utils/packages.dart';
import 'package:graba2z/Widgets/servicecard.dart';
import 'package:graba2z/Widgets/footertile.dart';
import '../../../../Widgets/socialicon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:graba2z/Configs/config.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final HomeController _homeController = Get.put(HomeController());
  final BrandController _brandController = Get.put(BrandController());
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categoriesSectionKey = GlobalKey();

  static const String _asusSectionBrandId = '687609800de49396755b8ffa';
  static const String _hpSectionBrandId = '687609800de49396755b8ffe';
  static const String _msiSectionBrandId = '687609810de49396755b9002';
  static const String _appleSectionBrandId = '6874de4381c33433c61f9bd4';
  static const String _lenovoSectionBrandId = '687609800de49396755b9000';

  static const String accessoriesCategoryId = '687659fcac482fc1560134d1';
  static const String networkingCategoryId = '68765a76ac482fc156013ad0';

  static const int homeScreenSectionFetchLimit = 20;
  static const int homeScreenSectionDisplayLimit = 5;
 

  final ScrollController _brandsScrollController = ScrollController();
  bool _brandsAutoLoopStarted = false;
  double _brandStepExtent = 0.0; // one-slot step
  double _brandLoopSpan = 0.0;   // full cycle width
  bool _brandsCentered = false;  // center only once

  @override
  void initState() {
    super.initState();
    _homeController.fetchFeaturedProducts(fetchLimit: homeScreenSectionFetchLimit);
    _brandController.fetchProductsForBrand(_hpSectionBrandId, brandNameForLog: 'HP Home Section', fetchLimit: homeScreenSectionFetchLimit);
    _brandController.fetchProductsForBrand(_asusSectionBrandId, brandNameForLog: 'Asus Home Section', fetchLimit: homeScreenSectionFetchLimit);
    _brandController.fetchProductsForBrand(_msiSectionBrandId, brandNameForLog: 'MSI Home Section', fetchLimit: homeScreenSectionFetchLimit);
    _brandController.fetchProductsForBrand(_appleSectionBrandId, brandNameForLog: 'Apple Home Section', fetchLimit: homeScreenSectionFetchLimit);
    _brandController.fetchProductsForBrand(_lenovoSectionBrandId, brandNameForLog: 'Lenovo Home Section', fetchLimit: homeScreenSectionFetchLimit);

    _homeController.fetchProductsForCategory(accessoriesCategoryId, categoryNameForLog: 'Accessories Home Section', fetchLimit: homeScreenSectionFetchLimit);
    _homeController.fetchProductsForCategory(networkingCategoryId, categoryNameForLog: 'Networking Home Section', fetchLimit: homeScreenSectionFetchLimit);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startBrandsAutoScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _brandsScrollController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      print('URL is empty, cannot launch.');
      Get.snackbar("Error", "Link is not available.", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        print('Could not launch $url (canLaunchUrlString returned false).');
        Get.snackbar("Error", "Could not open link.", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception trying to launch $url: $e');
      Get.snackbar("Error", "Error opening link.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _scrollToTop() { // Renamed and updated method
    _scrollController.animateTo(
      0.0, // Scroll to the top of the scroll view
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToCategoryByName(String categoryName) {
    categoriesModel? foundCategory;
    for (var cat in _homeController.category) {
      if (cat.name?.toLowerCase() == categoryName.toLowerCase()) {
        foundCategory = cat;
        break;
      }
    }

    if (foundCategory != null && foundCategory.sId != null && foundCategory.sId!.isNotEmpty) {
      Get.to(() => NewAllProduct(id: foundCategory!.sId!, parentType: "parentCategory", displayTitle: foundCategory.name ?? categoryName));
    } else {
      print("Footer Navigation: Category '$categoryName' not found or has no ID.");
      Get.snackbar(
        "Info",
        "Could not navigate to '$categoryName'. Category details not found.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  double getResponsiveProductCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 400) {
      return MediaQuery.of(context).size.height * 0.24;
    } else if (screenWidth <= 600) {
      return MediaQuery.of(context).size.height * 0.21;
    } else if (screenWidth <= 900) {
      return MediaQuery.of(context).size.height * 0.18;
    } else {
      return MediaQuery.of(context).size.height * 0.14;
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
      Map<String, dynamic> product = productElement;

      if (product.containsKey('stockStatus')) {
        final status = product['stockStatus'].toString().toLowerCase();
        if (status == 'preorder' || status == 'pre order') {
          preorderItems.add(product);
        } else if (status == 'out of stock') {
          outOfStockItems.add(product);
        } else { // Treat others/unknown as available
          availableItems.add(product);
        }
      } else {
        availableItems.add(product);
      }
    }
    // CHANGE: Available -> PreOrder -> Out of Stock
    return [...availableItems, ...preorderItems, ...outOfStockItems];
  }

  void _showAddedToCartPopup() {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Added to cart',
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final scale = Curves.easeOutBack.transform(anim.value);
        return Center(
          child: Transform.scale(
            scale: scale,
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    });
  }

  void _startBrandsAutoScroll() {
    if (_brandsAutoLoopStarted) return;
    _brandsAutoLoopStarted = true;
    _autoScrollBrandsLoop();
  }

  Future<void> _autoScrollBrandsLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3)); // wait before each step
      if (!mounted || !_brandsScrollController.hasClients) continue;
      if (_brandStepExtent <= 0 || _brandLoopSpan <= 0) continue;

      double current = _brandsScrollController.offset;

      // If near the end of the middle copy, jump back by one full span (seamless wrap)
      final double wrapThreshold = _brandLoopSpan * 2 - (_brandStepExtent * 1.5);
      if (current >= wrapThreshold) {
        try {
          _brandsScrollController.jumpTo(current - _brandLoopSpan);
          current = _brandsScrollController.offset;
        } catch (_) {}
      }

      final double next = current + _brandStepExtent;
      try {
        await _brandsScrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } catch (_) {
        // ignore interrupted animations
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuController controller = Get.find<menuController>();
    return Scaffold(
      drawer: buildCategoryDrawer(),
      appBar: CustomAppBar(
        // Show Drawer Menu
        showLeading: true,
          leadingWidget: Builder(
    builder: (context) {
      return IconButton(
        icon: const Icon(Icons.menu, color: kdefwhiteColor),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      );
    },
  ),
  
        
        // Change: always show logo on Home
        titleWidget: Image.asset(
          AppImages.logoicon,
          width: 100,
          height: 100,
          color: kdefwhiteColor,
        ),
        actionicon:Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: (){ 
              Navigator.push(context
                , MaterialPageRoute(builder: (context) => SearchScreen()));
            }, icon: const Icon(Icons.search, color: kdefwhiteColor, size: 28)),
             GetBuilder<CartNotifier>(
          builder: (cartNotifier) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    context.route(const Cart());
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
            );
          },
        ),
        
          ],
      
      
        )
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(children: [
          const ImageCarouselSlider(),
          10.0.heightbox,
          Column(
            children: [
              GestureDetector(
                key: _categoriesSectionKey,
                onTap: () {
                  context.route(const AllCategoriesScreen());
                },
                child: Padding(
                  padding: defaultPadding(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Categories", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kSecondaryColor)),
                      Row(
                        children: [
                          Text("Show All", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kSecondaryColor)),
                          Icon(Icons.arrow_forward_ios, size: 12, color: kSecondaryColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GetBuilder<HomeController>(
                builder: (homeCtrl) {
                  if (homeCtrl.isCateloading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (homeCtrl.category.isEmpty) {
                    return const Center(child: Text('No categories available'));
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: defaultPadding(horizontal: 8, vertical: 5),
                      itemCount: homeCtrl.category.length >= 6 ? 6 : homeCtrl.category.length,
                      itemBuilder: (ctx, index) {
                        final category = homeCtrl.category[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Change: do NOT set Home title; pass displayTitle to the next screen
                                  Get.to(() => NewAllProduct(
                                        id: category.sId ?? '',
                                        parentType: "parentCategory",
                                        displayTitle: category.name ?? '',
                                      ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kdefgreyColor,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 3, spreadRadius: 1),
                                    ],
                                  ),
                                  child: CachedNetworkImage(
                                 imageUrl: Configss.baseUrl + category.image!,
                                    imageBuilder: (context, imageProvider) => Container(
                                      height: 65, width: 60,
                                      decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                    ),
                                    placeholder: (context, url) => SizedBox(
                                      height: 65, width: 60,
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                                        child: Container(decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(6))),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 65, width: 60,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), image: const DecorationImage(image: AssetImage('assets/images/noimage.png'), fit: BoxFit.contain)),
                                    ),
                                  ),
                                ),
                              ),
                              8.0.heightbox,
                              Text(
                                (category.name?.characters.take(12).toString() ?? '') + ((category.name?.length ?? 0) > 12 ? '...' : ''),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kSecondaryColor),
                                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          if (_lenovoSectionBrandId.isNotEmpty) {
                            Get.to(() => NewAllProduct(id: _lenovoSectionBrandId, parentType: "brand"));
                          } else {
                            Get.snackbar("Info", "Lenovo brand page not available yet.");
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset('assets/images/home1.png', fit: BoxFit.cover, height: 110),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          if (_msiSectionBrandId.isNotEmpty) {
                            Get.to(() => NewAllProduct(id: _msiSectionBrandId, parentType: "brand"));
                          } else {
                            Get.snackbar("Info", "MSI brand page not available yet.");
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset('assets/images/home2.png', fit: BoxFit.cover, height: 110),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset('assets/images/tamara.png', height: 70, fit: BoxFit.fill, width: double.infinity),
                ),
              ),
              const SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => NewAllProduct(id: "_featured_", parentType: "featured"));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/feature.png',
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: 140,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              // START: New Featured Products Section
              Obx(() {
                final isLoadingFeatured = _homeController.isLoadingFeaturedProducts?.value ?? true;
                final featuredProductList = _homeController.featuredProducts ?? <dynamic>[].obs;
                final sortedFeaturedProducts = _getSortedDisplayProducts(featuredProductList);
                final displayFeaturedProducts = sortedFeaturedProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayFeaturedProducts.isEmpty && !isLoadingFeatured) {
                  return const SizedBox.shrink(); // Don't show if empty and not loading
                }

                return HorizontalProducts(
                  onTap: () {
                    Get.to(() => NewAllProduct(id: "_featured_", parentType: "featured"));
                  },
                  name: "Featured Products",
                  loading: isLoadingFeatured,
                  productList: displayFeaturedProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),
              const SizedBox(height: 10), // Spacing after Featured Products section
              // END: New Featured Products Section

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    if (_hpSectionBrandId.isNotEmpty) {
                      Get.to(() => NewAllProduct(id: _hpSectionBrandId, parentType: "brand"));
                    } else {
                      Get.snackbar("Info", "HP brand page not available yet.");
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('assets/images/hp.png', height: 140, fit: BoxFit.fill, width: double.infinity),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final isLoadingHp = _brandController.isLoadingProductsByBrandIdMap[_hpSectionBrandId]?.value ?? true;
                final hpProductList = _brandController.productsByBrandIdMap[_hpSectionBrandId] ?? <dynamic>[].obs;
                final sortedHpProducts = _getSortedDisplayProducts(hpProductList);
                final displayHpProducts = sortedHpProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayHpProducts.isEmpty && !isLoadingHp) {
                  return const SizedBox.shrink();
                }

                return HorizontalProducts(
                  onTap: () {
                    if (_hpSectionBrandId.isNotEmpty) {
                      Get.to(() => NewAllProduct(id: _hpSectionBrandId, parentType: "brand"));
                    } else {
                       Get.snackbar("Developer Info", "HP Brand ID needs to be configured by the developer.");
                    }
                  },
                  name: "HP Products",
                  loading: isLoadingHp,
                  productList: displayHpProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                     Get.to(() => NewAllProduct(id: accessoriesCategoryId, parentType: "category"));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('assets/images/acessories.png', height: 140, fit: BoxFit.fill, width: double.infinity),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final isLoadingAccessories = _homeController.isLoadingProductsByCategoryIdMap[accessoriesCategoryId]?.value ?? true;
                final accessoriesProductList = _homeController.productsByCategoryIdMap[accessoriesCategoryId] ?? <dynamic>[].obs;
                final sortedAccessoriesProducts = _getSortedDisplayProducts(accessoriesProductList);
                final displayAccessoriesProducts = sortedAccessoriesProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayAccessoriesProducts.isEmpty && !isLoadingAccessories) {
                  return const SizedBox.shrink();
                }

                return HorizontalProducts(
                  onTap: () {
                     Get.to(() => NewAllProduct(id: accessoriesCategoryId, parentType: "category"));
                  },
                  name: "Accessories",
                  loading: isLoadingAccessories,
                  productList: displayAccessoriesProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => NewAllProduct(id: _asusSectionBrandId, parentType: "brand"));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('assets/images/asus.png', height: 140, fit: BoxFit.fill, width: double.infinity),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final isLoadingAsus = _brandController.isLoadingProductsByBrandIdMap[_asusSectionBrandId]?.value ?? true;
                final asusProductList = _brandController.productsByBrandIdMap[_asusSectionBrandId] ?? <dynamic>[].obs;
                final sortedAsusProducts = _getSortedDisplayProducts(asusProductList);
                final displayAsusProducts = sortedAsusProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayAsusProducts.isEmpty && !isLoadingAsus) {
                  return const SizedBox.shrink();
                }

                return HorizontalProducts(
                  onTap: () {
                    Get.to(() => NewAllProduct(id: _asusSectionBrandId, parentType: "brand"));
                  },
                  name: "Shop Asus",
                  loading: isLoadingAsus,
                  productList: displayAsusProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => NewAllProduct(id: networkingCategoryId, parentType: "subcategory"));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    // child: Image.asset('assets/images/networking.png', height: 140, fit: BoxFit.fill, width: double.infinity),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final isLoadingNetworking = _homeController.isLoadingProductsByCategoryIdMap[networkingCategoryId]?.value ?? true;
                final networkingProductList = _homeController.productsByCategoryIdMap[networkingCategoryId] ?? <dynamic>[].obs;
                final sortedNetworkingProducts = _getSortedDisplayProducts(networkingProductList);
                final displayNetworkingProducts = sortedNetworkingProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayNetworkingProducts.isEmpty && !isLoadingNetworking) {
                  return const SizedBox.shrink();
                }

                return HorizontalProducts(
                  onTap: () {
                     Get.to(() => NewAllProduct(id: networkingCategoryId, parentType: "subcategory"));
                  },
                  name: "Networking",
                  loading: isLoadingNetworking,
                  productList: displayNetworkingProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    if (_msiSectionBrandId.isNotEmpty) {
                       Get.to(() => NewAllProduct(id: _msiSectionBrandId, parentType: "brand"));
                    } else {
                       Get.snackbar("Info", "MSI brand page not available yet.");
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('assets/images/msi.png', height: 140, fit: BoxFit.fill, width: double.infinity),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final isLoadingMsi = _brandController.isLoadingProductsByBrandIdMap[_msiSectionBrandId]?.value ?? true;
                final msiProductList = _brandController.productsByBrandIdMap[_msiSectionBrandId] ?? <dynamic>[].obs;
                final sortedMsiProducts = _getSortedDisplayProducts(msiProductList);
                final displayMsiProducts = sortedMsiProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayMsiProducts.isEmpty && !isLoadingMsi) {
                  return const SizedBox.shrink();
                }

                return HorizontalProducts(
                  onTap: () {
                    if (_msiSectionBrandId.isNotEmpty) {
                       Get.to(() => NewAllProduct(id: _msiSectionBrandId, parentType: "brand"));
                    } else {
                       Get.snackbar("Info", "MSI brand page not available yet.");
                    }
                  },
                  name: "Shop MSI",
                  loading: isLoadingMsi,
                  productList: displayMsiProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    if (_appleSectionBrandId.isNotEmpty) {
                       Get.to(() => NewAllProduct(id: _appleSectionBrandId, parentType: "brand"));
                    } else {
                       Get.snackbar("Info", "Apple brand page not available yet.");
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('assets/images/apple.png', height: 140, fit: BoxFit.fill, width: double.infinity),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final isLoadingApple = _brandController.isLoadingProductsByBrandIdMap[_appleSectionBrandId]?.value ?? true;
                final appleProductList = _brandController.productsByBrandIdMap[_appleSectionBrandId] ?? <dynamic>[].obs;
                final sortedAppleProducts = _getSortedDisplayProducts(appleProductList);
                final displayAppleProducts = sortedAppleProducts.take(homeScreenSectionDisplayLimit).toList();

                if (displayAppleProducts.isEmpty && !isLoadingApple) {
                  return const SizedBox.shrink();
                }

                return HorizontalProducts(
                  onTap: () {
                    if (_appleSectionBrandId.isNotEmpty) {
                       Get.to(() => NewAllProduct(id: _appleSectionBrandId, parentType: "brand"));
                    } else {
                       Get.snackbar("Info", "Apple brand page not available yet.");
                    }
                  },
                  name: "Show Apple",
                  loading: isLoadingApple,
                  productList: displayAppleProducts,
                  onAddedToCart: _showAddedToCartPopup, // ADD
                );
              }),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  context.route(AllBrandScreen(brandList: _brandController.brandList));
                },
                child: Padding(
                  padding: defaultPadding(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Featured Brands", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kSecondaryColor)),
                      Row(
                        children: [
                          Text("Show All", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kSecondaryColor)),
                          Icon(Icons.arrow_forward_ios, size: 12, color: kSecondaryColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                // Touch Rx at top-level of Obx to avoid improper use warning
                final bool isLoadingBrands = _brandController.isbrandLoaded.value;
                final List<dynamic> brands = _brandController.brandList;

                // Reduced outer horizontal padding
                final basePad = defaultPadding();
                final sectionPad = EdgeInsets.fromLTRB(4.0, basePad.top, 4.0, basePad.bottom);

                return Padding(
                  padding: sectionPad,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Width inside section padding
                      final double contentWidth = constraints.maxWidth;

                      // Slightly reduced gap between cards
                      final double gap = contentWidth >= 360 ? 10.0 : 6.0;
                      // Smaller equal left/right edge padding inside the scroll
                      final double edgePad = 3.0;

                      // Snap helper to avoid fractional pixel overflow/clipping
                      final double dpr = MediaQuery.of(context).devicePixelRatio;
                      double snap(double v) => (v * dpr).floor() / dpr;

                      // Fit two items exactly with equal edges:
                      // contentWidth = edgePad + itemW + gap + itemW + edgePad
                      final double available = contentWidth - (2 * edgePad) - gap - 0.5;
                      final double itemWidth = snap(available / 2).clamp(80.0, contentWidth);

                      // Slightly reduce shrink so the card is a bit larger (~9%)
                      final double shrink = (itemWidth * 0.09).clamp(6.0, 18.0);
                      final double cardWidth = (itemWidth - shrink).clamp(90.0, itemWidth);

                      // one-slot step and full cycle span
                      final double stepExtent = itemWidth + gap;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _brandStepExtent = stepExtent;
                      });

                      if (!isLoadingBrands && brands.isNotEmpty) {
                        final double span = stepExtent * brands.length;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          _brandLoopSpan = span;
                          if (!_brandsCentered && _brandsScrollController.hasClients && span > 0) {
                            try {
                              // center on the middle copy
                              _brandsScrollController.jumpTo(span);
                              _brandsCentered = true;
                            } catch (_) {}
                          }
                        });
                      }

                      if (isLoadingBrands) {
                        return SingleChildScrollView(
                          controller: _brandsScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: edgePad),
                          child: Row(
                            children: [
                              ...List.generate(6, (index) {
                                return Container(
                                  width: itemWidth, // fixed slot
                                  margin: EdgeInsets.only(right: index == 5 ? 0 : gap),
                                  child: Center(
                                    child: Container(
                                      width: cardWidth,
                                      height: cardWidth,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              SizedBox(width: edgePad),
                            ],
                          ),
                        );
                      } else if (brands.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No Brands available.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      } else {
                        // Repeat brands 3x to simulate infinite list visually
                        final int total = brands.length * 3;
                        return SingleChildScrollView(
                          controller: _brandsScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: edgePad),
                          child: Row(
                            children: [
                              ...List.generate(total, (index) {
                                final realIndex = index % brands.length;
                                final brand = brands[realIndex];
                                final bool isLast = index == total - 1;
                                return Container(
                                  width: itemWidth, // fixed slot to keep 2-per-view
                                  margin: EdgeInsets.only(right: isLast ? 0 : gap),
                                  child: Center(
                                    child: BrandCard(
                                      id: (brand['_id'] ?? '').toString(),
                                      imageUrl: (ImageHelper.getUrl(brand['logo']) ?? 'https://i.postimg.cc/SsWYSvq6/noimage.png').toString(),
                                      name: (brand['name'] ?? 'No Name').toString(),
                                      width: cardWidth, // visual size inside the slot
                                    ),
                                  ),
                                );
                              }),
                              SizedBox(width: edgePad),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                );
              }),
              40.0.heightbox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 17.0),
                child: Column(
                  children: [
                    // const Text(
                    //   "Core Service Aspects",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //     color: kSecondaryColor,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(height: 20),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: const [
                    //     ServiceCard(
                    //       image: "assets/images/wallet.png",
                    //       title: "Secure Payment Method",
                    //       subtitle: "Available Different secure Payment Methods",
                    //     ),
                    //     ServiceCard(
                    //       image: "assets/images/delivery.png",
                    //       title: "Extreme Fast Delivery",
                    //       subtitle: "Fast and convenient From door to door delivery",
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 20), SizedBox(height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: const [
                    //     ServiceCard(
                    //       image: "assets/images/heart.png",
                    //       title: "Quality & Savings",
                    //       subtitle: "Comprehensive quality control and affordable price",
                    //     ),
                    //     ServiceCard(
                    //       image: "assets/images/headphone1.png",
                    //       title: "Professional Support",
                    //       subtitle: "Efficient customer support from passionate team",
                    //     ),
                    //   ],
                    // ),
                    // 40.0.heightbox,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FooterTile(title: "Categories", children: [
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Accessories & Components", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Accessories & Components"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("All in one", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("All in one"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Desktop", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Desktop"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Laptops", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Laptops"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Mobiles", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Mobiles"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Monitors", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Monitors"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Networking", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Networking"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Printers & Copier", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Printers & Copier"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Projector", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Projector"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Routers & Switches", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _navigateToCategoryByName("Routers & Switches"),
                                ),
                          ],),
                          Divider(height: 1, color: Color(0xFFEEEEEE)),
                          FooterTile(title: "Legal", children: [
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("About Us", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/about"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Contact Us", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/contact"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Blog", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://blog.grabatoz.ae/"),
                            ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Shop", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: _scrollToTop, // Updated onTap to call _scrollToTop
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Login", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => Get.to(() => Login()),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Register", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => Get.to(() => SignUp()),
                                ),
                          ],),
                          Divider(height: 1, color: Color(0xFFEEEEEE)),
                          FooterTile(title: "Support", children: [
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Refund and Return", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/refund-return"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Cookies Policy", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/cookies-policy"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Terms & Conditions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/terms-conditions"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Privacy Policy", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/privacy-policy"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Disclaimer Policy", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => _launchURL("https://www.grabatoz.ae/disclaimer-policy"),
                                ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Track Order", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => Get.to(() => TrackOrderScreen()),
                            ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Wishlist", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => Get.to(() => Favorite()),
                            ),
                            ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                title: Text("Cart", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                                onTap: () => Get.to(() => Cart()),
                            ),
                          ],),
                          Divider(height: 1, color: Color(0xFFEEEEEE)),
                          FooterTile(
                            title: "Connect",
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      SocialIcon(assetPath: "assets/icons/facebook.png", url: "https://www.facebook.com/grabatozae/"),
                                      SocialIcon(assetPath: "assets/icons/twitter.png", url: "https://x.com/GrabAtoz"),
                                      SocialIcon(assetPath: "assets/icons/instagram.png", url: "https://www.instagram.com/grabatoz/"),
                                      SocialIcon(assetPath: "assets/icons/linkedin.png", url: "https://www.linkedin.com/company/grabatozae"),
                                      SocialIcon(assetPath: "assets/icons/pinterest.png", url: "https://www.pinterest.com/grabatoz/"),
                                      SocialIcon(assetPath: "assets/icons/tiktok.png", url: "https://www.tiktok.com/@grabatoz"),
                                      SocialIcon(assetPath: "assets/icons/youtube.png", url: "https://www.youtube.com/@grabAtoZ"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ])),
      ),
    );
  }
}
