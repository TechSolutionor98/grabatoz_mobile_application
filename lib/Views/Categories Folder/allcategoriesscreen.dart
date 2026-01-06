import 'package:get/get.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/home_controller.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Categories%20Folder/subcategories_view.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cart.dart';
import 'package:graba2z/Views/Home/home.dart';
import '../../Utils/packages.dart';
import 'package:graba2z/Configs/config.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "All Categories",
        actionicon: GetBuilder<CartNotifier>(
          builder: (
            cartNotifier,
          ) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Home Icon
                // GestureDetector(
                //   onTap: () async {
                //     // Update the bottom navigation index safely
                //     Get.put(BottomNavigationController()).setTabIndex(0);

                //     Get.to(() => Home());
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 10.0),
                //     child: Text(
                //       '🏠',
                //       style: TextStyle(fontSize: 25),
                //     ),
                //   ),
                // ),
                // Cart Icon with Badge
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
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),

                    // Badge for cart count
                    if (cartNotifier.cartOtherInfoList.isNotEmpty) ...[
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: kredColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cartNotifier.cartOtherInfoList.length.toString(),
                            style: const TextStyle(
                              color: kdefwhiteColor,
                              fontSize: 8,
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
      body: SafeArea(
        child: GetBuilder<HomeController>(builder: (
          apiservice,
        ) {
          if (apiservice.isCateloading.value) {
            return Padding(
              padding: defaultPadding(),
              child: GridView.builder(
                itemCount: apiservice
                    .category.length, // Number of shimmer items to show
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
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
            );
          }

          if (apiservice.category.isEmpty) {
            return const Center(
              child: Text('No Categories available'),
            );
          }
          return Padding(
            padding: defaultPadding(vertical: 15),
            child: GridView.builder(
              itemCount: apiservice.category.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final category = apiservice.category[index];
                // final imageUrl = category.image?.src;
                // print('Image URL: $imageUrl');
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => SubCategoryScreen(
                                title: category.name ?? '',
                                selectedCategoryId: category.sId ?? '',
                              ));
                          // Get.to(() => NewAllProduct(
                          //       id: category.sId ?? '',
                          //       parentType: "parentCategory",
                          //     ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: kdefgreyColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: Offset(0, 2),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: CachedNetworkImage(
                            
                                 imageUrl: Configss.baseUrl + category.image!,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 80,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => SizedBox(
                              height: 80,
                              width: 75,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 80,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/noimage.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      8.0.heightbox,
                      Text(
                        category.name ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  //     CategoricalServiceCard(
                  //   id: category.sId ?? '',
                  //   maxLine: 1,
                  //   categoryAPIModel: categoriesModel(
                  //     name: category.name,
                  //     image: category.image,
                  //   ),
                  // ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
