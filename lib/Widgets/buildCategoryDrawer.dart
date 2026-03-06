import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controllers/menuController.dart';
import '../Utils/packages.dart';
import '../Views/Home/Screens/Shop Screen/Shop.dart';
import 'MenuTile.dart';

Drawer buildCategoryDrawer() {
  final menuController controller = Get.find<menuController>();

  return Drawer(
    child: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(color: kPrimaryColor),
              child: Center(
                child: Image.asset(
                  AppImages.logoicon,
                  width: 90,
                  height: 90,
                  color: kdefwhiteColor,
                ),
              ),
            ),
          ),
          // Crownyx Tile - Opens website
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://www.crownexcel.ae');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Crownyx',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Gaming Zone Tile
          GestureDetector(
            onTap: () {
              Get.to(() => Shop(
                id: "",
                parentType: "",
                displayTitle: "Gaming Zone",
                slug: "gaming-zone",
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Gaming Zone',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: controller.categories.map((category) {
                return CategoryTile(
                  title: category.name,
                  slug: category.slug,
                  id: category.id,
                  children: category.children.where((c) => c.level == 1).toList(),
                );
              }).toList(),
            ),
          ),

        ],
      );
    }),
  );
}
