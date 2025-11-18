import 'package:flutter/cupertino.dart';

import 'packages.dart';

extension NavigationExtension on BuildContext {
  void route(Widget screen) {
    // Navigator.of(this).push(MaterialPageRoute(
    //   builder: (context) => screen,
    // ));
    // Navigator.of(this).push(
    //   ScalePageRoute(
    //     builder: (context) => screen,
    //   ),
    // );
    Navigator.of(this).push(
      CupertinoPageRoute(
        // fullscreenDialog: true,
        builder: (context) => screen,
      ),
    );
  }

  void routeoffall(Widget screen) {
    // Navigator.of(this)
    //     .pushReplacement(MaterialPageRoute(builder: (context) => screen));
    Navigator.of(this).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }
}

//  extenstion for sizedbox you will only use like hieght.10

extension SizedBoxExtension on double {
  SizedBox get heightbox => SizedBox(height: this);
  SizedBox get widthbox => SizedBox(width: this);
}

//  extenstion for mediaquery

extension MediaQueryExtension on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}

//  extenstion for theme

extension ThemeExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ColorScheme get darkColorScheme => Theme.of(this).colorScheme;
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  ScalePageRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

// snackbar
extension SnackBarExtension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}

// void configEasyLoading() {
//   EasyLoading.instance
//     ..indicatorType = EasyLoadingIndicatorType.circle
//     ..loadingStyle = EasyLoadingStyle.dark
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = Colors.yellow
//     ..backgroundColor = Colors.green
//     ..indicatorColor = Colors.yellow
//     ..textColor = Colors.white
//     ..maskColor = Colors.blue.withOpacity(0.5)
//     ..userInteractions = false
//     ..dismissOnTap = false;
// }
