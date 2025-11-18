import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:graba2z/Utils/appcolors.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Product%20Folder/new_all_products.dart';

class BrandCard extends StatelessWidget {
  final String name;
  final String id;
  final String imageUrl;
  final double? width; // added

  const BrandCard({
    super.key,
    required this.name,
    required this.id,
    required this.imageUrl,
    this.width, // added
  });
  @override
  Widget build(BuildContext context) {
    final double cardWidth = width ?? 120; // added
    final double imgSize = (cardWidth * 0.66).clamp(70, 100); // added
    return GestureDetector(
      onTap: () {
        Get.to(() => NewAllProduct(
              id: id,
              parentType: "brand",
            ));
      },
      child: defaultStyledContainer(
        // height: 120,
        width: cardWidth, // was 120
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image Section
            Container(
              height: imgSize, // was 80
              width: imgSize,  // was 80
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color:
                    imageUrl.isNotEmpty ? Colors.transparent : Colors.grey[300],
              ),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey)
                  : null,
            ),
            8.0.heightbox,

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
