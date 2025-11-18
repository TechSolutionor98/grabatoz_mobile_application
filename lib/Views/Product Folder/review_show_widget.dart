import 'package:flutter/material.dart';
import 'package:graba2z/Utils/packages.dart';

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;
  const ReviewCard({required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  getUserData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    name = sp.getString('userName') ?? '';
    setState(() {});
  }

  String name = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(10),
      // constraints: BoxConstraints(
      //   maxWidth: MediaQuery.of(context).size.width * 0.9,
      // ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // force top align
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Rating stars in single row with overflow handling
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.review['name'],
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        widget.review['rating'] ?? 0,
                        (i) => const Icon(Icons.star,
                            color: Colors.amber, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.review['comment'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
