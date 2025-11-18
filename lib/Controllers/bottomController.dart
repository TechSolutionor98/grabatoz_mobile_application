import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigationController extends GetxController {
  int _tabIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final ScrollController _scrollController = ScrollController();

  int get tabIndex => _tabIndex;

  PageController get pageController => _pageController;
  ScrollController get scrollcontroller => _scrollController;
  // void setTabIndex(int index) {
  //   _tabIndex = index;
  //   _pageController.jumpToPage(index);
  //   notifyListeners();
  // }

  // /// Safely sets the tab index and navigates the PageController if attached
  // void setTabIndex(int index) {
  //   if (_pageController.hasClients) {
  //     _pageController.jumpToPage(index);
  //   }
  //   _tabIndex = index;
  //   notifyListeners();
  // }
  void setTabIndex(int index) {
    _tabIndex = index;
    update(); // Notify listeners before changing the page

    // Ensure the PageController is attached before navigating
    if (_pageController.hasClients) {
      Future.microtask(() {
        _pageController.jumpToPage(index);
      });
    }
  }

  /// Scrolls to the top of the current tab if the ScrollController is attached
  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
