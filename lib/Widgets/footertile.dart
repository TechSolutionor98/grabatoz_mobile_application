import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utils/appcolors.dart'; // for kSecondaryColor etc.

class FooterTile extends StatelessWidget {
  final String title;
  final List<Widget> children;

  FooterTile({
    super.key,
    required this.title,
    this.children = const [],
  });

  // 👇 RxBool to track expansion state
  final RxBool _isExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          trailing: Icon(
            _isExpanded.value ? Icons.remove : Icons.add,
            color: kSecondaryColor,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          onExpansionChanged: (expanded) => _isExpanded.value = expanded,
          children: children.isNotEmpty
              ? children
              : const [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Coming soon...",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
