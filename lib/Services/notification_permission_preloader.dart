import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionPreloader extends GetxController {
  static final NotificationPermissionPreloader I =
      Get.put(NotificationPermissionPreloader(), permanent: true);

  // Cached effective state (userPref && osAllowed)
  final RxnBool _effective = RxnBool();

  static bool get hasValue => I._effective.value != null;
  static bool get effectiveOrFalse => I._effective.value ?? false;

  static Future<void> preload() async {
    final prefs = await SharedPreferences.getInstance();
    final osAllowed = await AwesomeNotifications().isNotificationAllowed();
    final userPref = prefs.getBool('notification_enabled');
    final effective = (userPref ?? osAllowed) && osAllowed;
    I._effective.value = effective;
    await prefs.setBool('notification_effective_cached', effective);
  }

  static Future<void> updateEffective(bool effective) async {
    I._effective.value = effective;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_effective_cached', effective);
  }
}
