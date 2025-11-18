// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:get/get.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cart.dart';
import 'package:graba2z/Views/Home/Screens/Favorite%20Product/favproduct_screen.dart';
import 'package:graba2z/Views/Home/Screens/Settings/Modules/Notification%20Toggle/notificationtoggle.dart';
import 'package:graba2z/Views/Home/Screens/Settings/Modules/Order%20History/track_order_view.dart';
import 'package:graba2z/Views/Home/home.dart';
import 'package:graba2z/Widgets/secondarybutton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:graba2z/Services/notification_permission_preloader.dart';
import '../../../../Controllers/addtocart.dart';
import '../../../../Utils/packages.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  // Optional: call this instead of Navigator.push to ensure preloaded state
  static Future<void> open(BuildContext context) async {
    await NotificationPermissionPreloader.preload();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const Settings()),
    );
  }

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  getUserData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    name = sp.getString('userName') ?? '';
    email = sp.getString('userEmail') ?? '';
    print('its initstae ${sp.getString('token')}');
    setState(() {});
  }

  String name = '';
  String email = '';
  Future<bool>? _notifInitialFuture;

  @override
  void initState() {
    super.initState();
    getUserData();
    _authController.loadUserData();

    // Kick preloading early; uses cache for instant first frame
    NotificationPermissionPreloader.preload();
    // Preload effective notification state (userPref AND OS permission)
    _notifInitialFuture = _loadInitialNotificationEffective();
  }

  Future<bool> _loadInitialNotificationEffective() async {
    final prefs = await SharedPreferences.getInstance();
    final userPref = prefs.getBool('notification_enabled') ?? false;
    final osAllowed = await AwesomeNotifications().isNotificationAllowed();
    return userPref && osAllowed;
  }

  AuthController _authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Settings",
        showLeading: false,
        actionicon: GetBuilder<CartNotifier>(
          builder: (
            cartNotifier,
          ) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                // The cart icon
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

                // The dynamic badge showing cart count
                if (cartNotifier.cartOtherInfoList.isNotEmpty) ...[
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 15,
                      height: 15,
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
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: defaultPadding(),
                child: defaultStyledContainer(
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 20,
                          child: Icon(
                            Icons.person,
                            size: 25,
                          )),
                      20.0.widthbox,
                      Expanded(
                        child: GetBuilder<AuthController>(builder: (
                          authProvider,
                        ) {
                          if (authProvider.userID.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$name",
                                  style: Get.textTheme.headlineSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: kSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  email,
                                  style: Get.textTheme.bodyLarge!.copyWith(
                                    color: kSecondaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            );
                          } else {
                            // If not logged in, show Guest User info and a login button
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Guest",
                                  style: Get.textTheme.headlineSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: kSecondaryColor),
                                ),

                                const SizedBox(
                                    height: 5), // Spacer between text and button
                                SecondaryButton(
                                  buttonColor: kPrimaryColor,
                                  textColor: kdefwhiteColor,
                                  onPressFunction: () {
                                    // Navigate to Login screen
                                    context.route(Login());
                                  },
                                  buttonText: "Login",
                                ),
                              ],
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
              ),
              20.0.heightbox,
              Padding(
                padding: defaultPadding(),
                child: defaultStyledContainer(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      GetBuilder<AuthController>(builder: (
                        authprovider,
                      ) {
                        if (authprovider.userID.value.isNotEmpty) {
                          return Column(
                            children: [
                              ListTile(
                                minLeadingWidth: 0,
                                onTap: () async {
                                  SharedPreferences sp =
                                      await SharedPreferences.getInstance();
                                  // Get.to(() => DummyView(
                                  //       url:
                                  //           "https://championfootballer-client.vercel.app/",
                                  //     ));
                                  String token = sp.getString('token') ?? '';
                                  log('the token is ${token}');
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile()),
                                  );

                                  if (result == true) {
                                    setState(
                                        () {}); // Refresh FutureBuilder when returning
                                  }
                                },
                                leading: Image.asset("assets/icons/profile.png",
                                    color: kSecondaryColor,
                                    width: 20,
                                    height: 20),
                                title: const Text('Your Profile',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kSecondaryColor,
                                  size: 16,
                                ),
                              ),
                              Divider(
                                height: 0,
                                color: Colors.grey.withValues(alpha: .2),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      }),

                      // Consumer<AuthProvider>(
                      //   builder: (ctx, authprovider, child) {
                      //     if (authprovider.isLoggedIn) {
                      //       return Column(
                      //         children: [
                      //           ListTile(
                      //             minLeadingWidth: 0,
                      //             onTap: () {
                      //               context.route(SavedAddressesScreen());
                      //             },
                      //             leading: Image.asset(
                      //                 "assets/icons/location.png",
                      //                 color: kSecondaryColor,
                      //                 width: 20,
                      //                 height: 20),
                      //             title: const Text('Manage Address',
                      //                 style: TextStyle(
                      //                     fontSize: 12,
                      //                     fontWeight: FontWeight.w600)),
                      //             trailing: const Icon(
                      //               Icons.arrow_forward_ios,
                      //               color: kSecondaryColor,
                      //               size: 16,
                      //             ),
                      //           ),
                      //           Divider(
                      //             height: 0,
                      //             color: Colors.grey.withValues(alpha: .2),
                      //           ),
                      //         ],
                      //       );
                      //     } else {
                      //       return Container();
                      //     }
                      //   },
                      // ),

                      // Consumer<AuthProvider>(builder: (ctx, authprovider, child) {
                      //   if (authprovider.isLoggedIn) {
                      //     return Column(
                      //       children: [
                      //         ListTile(
                      //           minLeadingWidth: 0,
                      //           onTap: () async {
                      //             final prefs =
                      //                 await SharedPreferences.getInstance();
                      //             String? userId = prefs
                      //                 .getInt('userId')
                      //                 ?.toString(); // Retrieve user ID
                      //             context.route(PaymentMethodScreen(
                      //               userId: userId!,
                      //             ));
                      //           },
                      //           leading: Image.asset("assets/icons/payment.png",
                      //               color: kSecondaryColor,
                      //               width: 20,
                      //               height: 20),
                      //           title: const Text('Payment Cards',
                      //               style: TextStyle(
                      //                   fontSize: 12,
                      //                   fontWeight: FontWeight.w600)),
                      //           trailing: const Icon(
                      //             Icons.arrow_forward_ios,
                      //             color: kSecondaryColor,
                      //             size: 16,
                      //           ),
                      //         ),
                      //         Divider(
                      //           height: 0,
                      //           color: Colors.grey.withValues(alpha: .2),
                      //         ),
                      //       ],
                      //     );
                      //   } else {
                      //     return Container();
                      //   }
                      // }),

                      //wishlist
                      GetBuilder<AuthController>(builder: (
                        authprovider,
                      ) {
                        if (authprovider.userID.isNotEmpty) {
                          return Column(
                            children: [
                              ListTile(
                                minLeadingWidth: 0,
                                onTap: () {
                                  context.route(const OrderHistoryScreen());
                                },
                                leading: Image.asset("assets/icons/myorder.png",
                                    color: kSecondaryColor,
                                    width: 20,
                                    height: 20),
                                title: Text('Order History',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    )),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kSecondaryColor,
                                  size: 16,
                                ),
                              ),
                              Divider(
                                height: 0,
                                color: Colors.grey.withValues(alpha: .2),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      }),
                      GetBuilder<AuthController>(builder: (
                        authprovider,
                      ) {
                        return Column(
                          children: [
                            ListTile(
                              minLeadingWidth: 0,
                              onTap: () {
                                context.route(TrackOrderScreen());
                              },
                              leading: Icon(Icons.local_shipping),
                              title: Text('Track Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  )),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: kSecondaryColor,
                                size: 16,
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey.withValues(alpha: .2),
                            ),
                          ],
                        );
                      }),
                      GetBuilder<AuthController>(builder: (
                        authprovider,
                      ) {
                        if (authprovider.userID.isNotEmpty) {
                          return ListTile(
                            minLeadingWidth: 0,
                            onTap: () {
                              context.route(const Favorite());
                            },
                            leading: Image.asset("assets/icons/favor.png",
                                color: kSecondaryColor, width: 20, height: 20),
                            title: const Text('My WishList',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: kSecondaryColor,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                      Divider(
                        height: 0,
                        color: Colors.grey.withValues(alpha: .2),
                      ),
                      10.0.heightbox,

                      // Render immediately using cached/preloaded state (no FutureBuilder)
                      NotificationTile(
                        initialValue: NotificationPermissionPreloader.effectiveOrFalse,
                        key: ValueKey(NotificationPermissionPreloader.effectiveOrFalse),
                      ),

                      Divider(
                        height: 0,
                        color: Colors.grey.withValues(alpha: .2),
                      ),

                      ListTile(
                        minLeadingWidth: 0,
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(
                              'https://graba2z.ae/about',
                            ),
                          );
                          // context.route(const AboutUsScreen());
                        },
                        leading: Image.asset("assets/icons/info.png",
                            color: kSecondaryColor, width: 20, height: 20),
                        title: const Text('About Us',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: kSecondaryColor,
                        ),
                      ),
                      Divider(
                        height: 0,
                        color: Colors.grey.withValues(alpha: .2),
                      ),
                      ListTile(
                        minLeadingWidth: 0,
                        onTap: () async {
                          await launchUrl(
                            Uri.parse("https://graba2z.ae/privacy-policy"),
                          );
                          // context.route(const PrivacyPolicyScreen());
                        },
                        leading: Image.asset("assets/icons/policy.png",
                            color: kSecondaryColor, width: 20, height: 20),
                        title: const Text('Privacy Policy',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: kSecondaryColor,
                        ),
                      ),
                      Divider(
                        height: 0,
                        color: Colors.grey.withValues(alpha: .2),
                      ),
                      ListTile(
                        minLeadingWidth: 0,
                        onTap: () async {
                          await launchUrl(
                            Uri.parse("https://graba2z.ae/terms-conditions/"),
                          );
                          // context.route(const TermsAndConditionsScreen());
                        },
                        leading: Image.asset("assets/icons/terms.png",
                            color: kSecondaryColor, width: 20, height: 20),
                        title: const Text('Terms & Conditions',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: kSecondaryColor,
                          size: 16,
                        ),
                      ),
                      Divider(
                        height: 0,
                        color: Colors.grey.withValues(alpha: .2),
                      ),
                      // Divider(
                      //   height: 0,
                      //   color: Colors.grey.withValues(alpha: .2),
                      // ),
                      // ListTile(
                      //   minLeadingWidth: 0,
                      //   onTap: () async {
                      //     const url = 'https://grabatoz.ae/contact-grabatoz/';

                      //     final Uri uri = Uri.parse(url);

                      //     // Check if the URL can be launched
                      //     if (await canLaunchUrl(uri)) {
                      //       await launchUrl(uri); // Launch the URL
                      //     } else {
                      //       // Handle the case where the URL can't be launched
                      //       print('Could not launch $url');
                      //     }
                      //   },
                      //   leading: Image.asset("assets/icons/contact.png",
                      //       color: kSecondaryColor, width: 20, height: 20),
                      //   title: const Text('Contact Us',
                      //       style: TextStyle(
                      //           fontSize: 12, fontWeight: FontWeight.w600)),
                      //   trailing: const Icon(
                      //     Icons.arrow_forward_ios,
                      //     color: kSecondaryColor,
                      //     size: 16,
                      //   ),
                      // ),
                      // Divider(
                      //   height: 0,
                      //   color: Colors.grey.withValues(alpha: .2),
                      // ),
                      GetBuilder<AuthController>(
                        builder: (
                          authprovider,
                        ) {
                          if (authprovider.userID.isNotEmpty) {
                            return ListTile(
                              minLeadingWidth: 0,
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: kdefwhiteColor,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                  ),
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Logout',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Divider(
                                                color: kdefgreyColor.withValues(
                                                    alpha: .2)),
                                            const Text(
                                              'Are you sure you want to log out?',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: kmediumblackColor,
                                              ),
                                            ),
                                            16.0.heightbox,
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 12.0,
                                                          horizontal: 32.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                kPrimaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  kPrimaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                15.0.widthbox,
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final authProvider =
                                                          Get.find<
                                                              AuthController>();
                                                      Navigator.pop(context);
                                                      authProvider.logout();

                                                      // Clear SharedPreferences
                                                      final prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      await prefs
                                                          .remove('userId');

                                                      // Reset the bottom navigation index (assuming you have a provider for it)
                                                      final bottomNavProvider =
                                                          Get.find<
                                                              BottomNavigationController>();
                                                      bottomNavProvider
                                                          .setTabIndex(0);

                                                      // // Navigate to Login screen and clear all previous screens
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Home()),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false,
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 12.0,
                                                          horizontal: 32.0),
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          'Yes, Logout',
                                                          style: TextStyle(
                                                              color:
                                                                  kdefwhiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            10.0.heightbox,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              leading: Image.asset("assets/icons/logout.png",
                                  color: kSecondaryColor,
                                  width: 20,
                                  height: 20),
                              title: const Text('Logout',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: kSecondaryColor,
                              ),
                            );
                          } else {
                            return Container();
                            // return ListTile(
                            //   minLeadingWidth: 0,
                            //   onTap: () {
                            //     // Navigate to Login screen
                            //     context.route(Login());
                            //   },
                            //   leading: Image.asset("assets/icons/login.png",
                            //       color: kSecondaryColor, width: 20, height: 20),
                            //   title: const Text('Login',
                            //       style: TextStyle(
                            //           fontSize: 12, fontWeight: FontWeight.w600)),
                            //   trailing: const Icon(
                            //     Icons.arrow_forward_ios,
                            //     size: 16,
                            //     color: kSecondaryColor,
                            //   ),
                            // );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              20.0.heightbox,
            ],
          ),
        ),
      ),
    );
  }
}

// GestureDetector(
//   onTap: () async {
//     final SharedPreferences pref =
//         await SharedPreferences.getInstance();
//     pref.remove('userID').then((_) {
//       context.routeoffall('/login');
//     });
//   },
//   child: Container(
//     decoration: BoxDecoration(
//         color: context.colorScheme.brightness == Brightness.dark
//             ? kdarkmodeColor
//             : kdefwhiteColor,
//         border: Border.all(color: kdarkgreyColor),
//         borderRadius: BorderRadius.circular(10)),
//     child: ListTile(
//       leading: const Icon(
//         Icons.logout_rounded,
//       ),
//       title: Text(
//         'Logout',
//         style: context.textTheme.bodyLarge!.copyWith(),
//       ),
//       trailing: const Icon(Icons.arrow_forward_ios),
//     ),
//   ),
// ),
