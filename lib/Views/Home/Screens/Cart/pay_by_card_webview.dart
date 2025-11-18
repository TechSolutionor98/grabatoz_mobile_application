import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cancel_page.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (progress < 1.0) LinearProgressIndicator(value: progress),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onProgressChanged: (controller, progressValue) {
                  setState(() {
                    progress = progressValue / 100;
                  });
                },
                onLoadStop: (controller, url) {
                  final currentUrl = url.toString();
                  if (currentUrl.contains("payment/success")) {
                    // Navigator.pushReplacementNamed(context, "/payment-success");
                  } else if (currentUrl.contains("payment/cancel")) {
                    log('get back to shopping');
                    Get.offAll(() => CancelPagePayment());
                    // Navigator.pushReplacementNamed(context, "/payment-cancel");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
