import 'package:flutter/material.dart';

class ScrollCategoryProvider with ChangeNotifier {
  int _selectedIndex = -1; // No category is selected initially

  int get selectedIndex => _selectedIndex;

  void selectCategory(int index) {
    _selectedIndex = index;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
