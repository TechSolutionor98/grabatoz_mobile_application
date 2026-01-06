import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graba2z/Views/Home/Screens/Shop%20Screen/Shop.dart';
import '../Api/Models/menumodel.dart';
import '../Utils/packages.dart';
import '../Views/Product Folder/new_all_products.dart';

class CategoryTile extends StatefulWidget {
  final String title;
  final String slug;
  final List<Child> children;
  final String id;
  final int level;

  const CategoryTile({
    Key? key,
    required this.title,
    required this.slug,
    required this.children,
    required this.id,
    this.level = 0,
  }) : super(key: key);

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.level.isEven ? Colors.black : Colors.red;
    final parentType =
    widget.level == 0 ? 'parentCategory' : 'subcategory';

    // ---------------- LEAF ----------------
    if (widget.children.isEmpty) {
      return ListTile(
        contentPadding:
        EdgeInsets.only(left: 16 + widget.level * 16, right: 20),
        title: Text(widget.title,
            style: TextStyle(color: textColor)),
        onTap: () {
          debugPrint(
              "TAP → level=${widget.level}, id=${widget.id}, type=$parentType");

          Get.to(() => Shop(
            id: widget.id,
            parentType: parentType,
            displayTitle: widget.title,
          ));
        },
      );
    }

    // ---------------- NODE ----------------
    return Column(
      children: [
        InkWell(
          onTap: () {
            debugPrint(
                "TAP → level=${widget.level}, id=${widget.id}, type=$parentType");

            Get.to(() => Shop(
              id: widget.id,
              parentType: parentType,
              displayTitle: widget.title,
            ));
          },
          child: Container(
            height: 50,
            padding:
            EdgeInsets.only(left: 16 + widget.level * 16, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---------------- CHILDREN ----------------
        if (_isExpanded)
          Column(
            children: widget.children.map((child) {
              return CategoryTile(
                title: child.name ?? '',
                slug: child.slug ?? '',
                id: child.id.toString(), // ✅ FIX HERE
                children: child.children ?? [],
                level: widget.level + 1,
              );
            }).toList(),
          ),
      ],
    );
  }
}
