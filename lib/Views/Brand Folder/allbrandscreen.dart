import 'package:get/get.dart';
import 'package:graba2z/Api/Services/apiservices.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Brand%20Folder/brandcard.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cart.dart';
import '../../../Utils/packages.dart';

class AllBrandScreen extends StatelessWidget {
  List brandList;
  AllBrandScreen({super.key, required this.brandList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "All Brands",
        actionicon: GetBuilder<CartNotifier>(
          builder: (
            cartNotifier,
          ) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // // Home Icon
                // GestureDetector(
                //   onTap: () async {
                //     // Assuming you have a way to update the bottom navigation index
                //     // Replace `context.read<YourProvider>().updateIndex(0);` with your actual navigation logic
                //     showDialog(
                //       context: context,
                //       barrierDismissible: false,
                //       builder: (context) {
                //         return const Center(
                //           child: CircularProgressIndicator(
                //             color: kPrimaryColor, // Customize color if needed
                //           ),
                //         );
                //       },
                //     );

                //     // Small delay for a smooth transition (optional)
                //     await Future.delayed(const Duration(milliseconds: 300));

                //     // Dismiss the loading dialog first
                //     if (context.mounted) {
                //       Navigator.pop(context);
                //     }

                //     // Update the bottom navigation index safely
                //     Get.put(BottomNavigationController()).setTabIndex(0);

                //     // Close the settings screen if it is in a new route
                //     if (Navigator.canPop(context)) {
                //       Navigator.pop(context);
                //     }
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 10.0),
                //     child: Icon(Icons.home, color: kdefwhiteColor, size: 28),
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
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),

                    // Badge for cart count
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
      body: GetBuilder<ApiServiceController>(builder: (apiservice) {
        return SafeArea(
          child: GridView.builder(
            itemCount: brandList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .93,
            ),
            itemBuilder: (context, index) {
              final brand = brandList[index];
              return BrandCard(
                id: brand['_id'].toString(),
                imageUrl:
                    brand['logo'] != null && brand['logo'].toString().isNotEmpty
                        ? brand['logo']
                        : 'https://i.postimg.cc/SsWYSvq6/noimage.png',
                name: brand['name'] ?? 'No Name',
                // Pass as map if BrandCard accepts it
              );
            },
          ),
        );
      }),
    );
  }
}
