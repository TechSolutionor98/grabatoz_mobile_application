import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../Api/Models/menumodel.dart';
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
                  id: idValues.reverse[category.id] ?? '',
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
