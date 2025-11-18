import 'package:flutter/material.dart';
import '../Utils/packages.dart'; // ismein aapke constants (kSecondaryColor etc.) honge

class ServiceCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const ServiceCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(image, width: 36, height: 36),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
