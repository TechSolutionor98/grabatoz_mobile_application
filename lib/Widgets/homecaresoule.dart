import 'dart:convert';

import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Utils/image_helper.dart';

import '../Utils/packages.dart';
import 'package:http/http.dart' as http;

class ImageCarouselSlider extends StatefulWidget {
  const ImageCarouselSlider({super.key});

  @override
  ImageCarouselSliderState createState() => ImageCarouselSliderState();
}

class ImageCarouselSliderState extends State<ImageCarouselSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  // double getResponsivecaresoulHeight(BuildContext context) {
  //   final screenWidth = MediaQuery.of(context).size.width;

  //   if (screenWidth <= 400) {
  //     return MediaQuery.of(context).size.height * 0.15; // small phones
  //   } else if (screenWidth <= 600) {
  //     return MediaQuery.of(context).size.height * 0.12; // regular phones
  //   } else if (screenWidth <= 900) {
  //     return MediaQuery.of(context).size.height * 0.9; // small tablets
  //   } else {
  //     return MediaQuery.of(context).size.height *
  //         0.20; // tablets/iPads ✅ tested
  //   }
  // }

  List bannerList = [];
  Future<void> fetchBanners() async {
    String url = Configss.getBanners;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Map JSON to a list of ProductApiModel
        for (var i = 0; i < data.length; i++) {
          if (data[i]['deviceType'] == 'mobile') {
            bannerList.add(data[i]['image']);
          }
        }
        setState(() {});
      } else {
        print("Failed to fetch products. Status code: ${response.statusCode}");
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print("Error fetching products: $error");
    } finally {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: bannerList.map((imageUrl) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CachedNetworkImage(
                // fit: BoxFit.fill,
                width: double.infinity,
                  imageUrl: ImageHelper.getUrl(imageUrl ?? ""),
                // fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(12),
                    color: Colors.grey,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(12),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Column(
                  children: [
                    const Text(
                      "No image",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    10.0.heightbox,
                    const Icon(Icons.error, color: Colors.red),
                  ],
                ),
              ),
            );
          }).toList(),
          carouselController: _carouselController,
          options: CarouselOptions(
            autoPlayInterval: Duration(seconds: 6),
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            height: 160,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        // 10.0.heightbox,
        bannerList.isNotEmpty
            ? AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: bannerList.length,
                effect: const WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: kPrimaryColor,
                  dotColor: kdefgreyColor,
                ),
              )
            : const SizedBox(), // empty placeholder when no banners
      ],
    );
  }
}
