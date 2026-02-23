import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:graba2z/Api/Models/menumodel.dart';
import 'package:graba2z/Controllers/menuController.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Utils/appcolors.dart';

class ShopCategoryFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final String? initialCategoryId;
  final String? initialSubCategoryId;
  final List<dynamic> products; // Products list to extract brands
  final List<String>? initialSelectedBrands; // Initially selected brands

  const ShopCategoryFilter({
    Key? key,
    required this.onApplyFilters,
    this.initialCategoryId,
    this.initialSubCategoryId,
    this.products = const [],
    this.initialSelectedBrands,
  }) : super(key: key);

  @override
  State<ShopCategoryFilter> createState() => _ShopCategoryFilterState();
}

class _ShopCategoryFilterState extends State<ShopCategoryFilter> {
  final menuController _menuController = Get.find<menuController>();

  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String? _selectedTitle; // Store selected category/subcategory title
  final Set<String> _expandedCategories = {};
  bool _isCategorySectionExpanded = true;

  // Brand filter
  Map<String, String> _allBrandsMap = {}; // All brands from API: {id: name}
  List<Map<String, String>> _availableBrands = []; // Brands in current products
  Set<String> _selectedBrandIds = {};
  bool _isBrandSectionExpanded = true;
  bool _isBrandsLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 'all';
    _selectedSubCategoryId = widget.initialSubCategoryId;

    // Auto-expand the parent category if it's selected
    if (_selectedCategoryId != null && _selectedCategoryId != 'all') {
      _expandedCategories.add(_selectedCategoryId!);
    }

    // Also expand parent if subcategory is selected
    if (_selectedSubCategoryId != null && _selectedSubCategoryId!.isNotEmpty) {
      // Add parent category to expanded set
      if (_selectedCategoryId != null && _selectedCategoryId != 'all') {
        _expandedCategories.add(_selectedCategoryId!);
      }
      // Also add the subcategory itself in case it has children
      _expandedCategories.add(_selectedSubCategoryId!);

      // Find and expand all parent categories in the hierarchy after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _expandParentCategoriesForSubcategory(_selectedSubCategoryId!);
      });
    }

    // Initialize selected brands
    if (widget.initialSelectedBrands != null) {
      _selectedBrandIds = Set<String>.from(widget.initialSelectedBrands!);
    }

    // Fetch all brands from API, then extract brands from products
    _fetchAllBrands();
  }

  // Find and expand all parent categories for a given subcategory
  void _expandParentCategoriesForSubcategory(String subcategoryId) {
    bool found = false;
    // Search through all categories to find the path to this subcategory
    for (final category in _menuController.categories) {
      final categoryId = idValues.reverse[category.id] ?? '';
      if (_findAndExpandPath(category.children, subcategoryId, categoryId)) {
        _expandedCategories.add(categoryId);
        found = true;
        break;
      }
    }

    // Refresh UI if we found and expanded categories
    if (found && mounted) {
      setState(() {});
    }
  }

  // Recursively find subcategory and expand the path
  bool _findAndExpandPath(List<Child> children, String targetId, String parentId) {
    for (final child in children) {
      if (child.id == targetId) {
        return true;
      }
      if (child.children.isNotEmpty) {
        if (_findAndExpandPath(child.children, targetId, child.id)) {
          _expandedCategories.add(child.id);
          return true;
        }
      }
    }
    return false;
  }

  // Fetch all brands from API
  Future<void> _fetchAllBrands() async {
    try {
      setState(() => _isBrandsLoading = true);

      final response = await http.get(Uri.parse(Configss.getallbrands));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          for (final brand in data) {
            if (brand is Map<String, dynamic>) {
              final brandId = brand['_id']?.toString() ?? '';
              final brandName = brand['name']?.toString() ?? '';
              if (brandId.isNotEmpty && brandName.isNotEmpty) {
                _allBrandsMap[brandId] = brandName;
              }
            }
          }
        }

        log('Fetched ${_allBrandsMap.length} brands from API');
      }
    } catch (e) {
      log('Error fetching brands: $e');
    } finally {
      // Now extract brands from products using the map
      _extractBrandsFromProducts();
      setState(() => _isBrandsLoading = false);
    }
  }

  // Extract brands from current products and map to names
  void _extractBrandsFromProducts() {
    final Set<String> brandIdsInProducts = {};

    for (final product in widget.products) {
      if (product is Map<String, dynamic>) {
        final brand = product['brand'];
        String? brandId;

        if (brand is Map<String, dynamic>) {
          brandId = brand['_id']?.toString();
        } else if (brand is String && brand.isNotEmpty) {
          brandId = brand;
        }

        if (brandId != null && brandId.isNotEmpty) {
          brandIdsInProducts.add(brandId);
        }
      }
    }

    // Map brand IDs to names using _allBrandsMap
    final List<Map<String, String>> brandsList = [];
    for (final brandId in brandIdsInProducts) {
      final brandName = _allBrandsMap[brandId];
      if (brandName != null && brandName.isNotEmpty) {
        brandsList.add({'id': brandId, 'name': brandName});
      }
    }

    // Sort by name
    brandsList.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

    setState(() {
      _availableBrands = brandsList;
    });

    log('Found ${_availableBrands.length} brands in ${widget.products.length} products');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = 'all';
      _selectedSubCategoryId = null;
      _selectedTitle = null;
      _selectedBrandIds.clear();
      _expandedCategories.clear();
    });

    // Call onApplyFilters with "all categories" filter to reset the shop view
    final resetFilters = <String, dynamic>{
      'categoryId': '',
      'subCategoryId': '',
      'selectedId': '',
      'parentType': '',
      'title': 'All Products',
      'selectedBrandIds': [],
    };
    log('Resetting filters: $resetFilters');
    widget.onApplyFilters(resetFilters);
    Navigator.of(context).pop();
  }

  // Build parent category tile (level 0)
  Widget _buildCategoryTile(Menumodel category) {
    final categoryId = idValues.reverse[category.id] ?? '';
    final categoryName = category.name;
    final hasChildren = category.children.isNotEmpty;
    final isExpanded = _expandedCategories.contains(categoryId);
    final isSelected = _selectedCategoryId == categoryId && _selectedSubCategoryId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryId = categoryId;
              _selectedSubCategoryId = null;
              _selectedTitle = categoryName;
              log('Selected category: $categoryName ($categoryId)');
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Category name
                Expanded(
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? kPrimaryColor : Colors.black87,
                    ),
                  ),
                ),
                // Expand/collapse button
                if (hasChildren)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedCategories.remove(categoryId);
                        } else {
                          _expandedCategories.add(categoryId);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Children (subcategories level 1) - only show level 1 children
        if (hasChildren && isExpanded)
          ...category.children.where((c) => c.level == 1).map((child) => _buildChildTile(child, parentId: categoryId, level: 1)).toList(),
      ],
    );
  }

  // Build child category tile (levels 1, 2, 3, 4...)
  Widget _buildChildTile(Child child, {required String parentId, int level = 1}) {
    final childId = child.id;
    final childName = child.name;
    final hasChildren = child.children.isNotEmpty;
    final isExpanded = _expandedCategories.contains(childId);
    final isSelected = _selectedSubCategoryId == childId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryId = parentId;
              _selectedSubCategoryId = childId;
              _selectedTitle = childName;
              log('Selected subcategory level $level: $childName ($childId)');
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: level * 20.0,
              top: 6,
              bottom: 6,
              right: 4,
            ),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Category name
                Expanded(
                  child: Text(
                    childName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? kPrimaryColor : Colors.black54,
                    ),
                  ),
                ),
                // Expand/collapse button
                if (hasChildren)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedCategories.remove(childId);
                        } else {
                          _expandedCategories.add(childId);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Nested children (levels 2, 3, 4...)
        if (hasChildren && isExpanded)
          ...child.children.map((nestedChild) => _buildChildTile(
            nestedChild,
            parentId: parentId,
            level: level + 1,
          )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kSecondaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Divider(),

              // Scrollable content - Categories then Brands
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories Section
                      _buildCategoriesSection(),

                      const SizedBox(height: 16),

                      // Brands Section (below categories)
                      _buildBrandsSection(),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _resetFilters,
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Determine the ID and parentType based on selection
                        String? selectedId;
                        String parentType = '';
                        String title = _selectedTitle ?? 'Products';

                        if (_selectedSubCategoryId != null && _selectedSubCategoryId!.isNotEmpty) {
                          // Subcategory selected
                          selectedId = _selectedSubCategoryId;
                          parentType = 'subcategory';
                        } else if (_selectedCategoryId != null && _selectedCategoryId != 'all' && _selectedCategoryId!.isNotEmpty) {
                          // Parent category selected
                          selectedId = _selectedCategoryId;
                          parentType = 'parentCategory';
                        }

                        final filters = <String, dynamic>{
                          'categoryId': _selectedCategoryId == 'all' ? '' : _selectedCategoryId,
                          'subCategoryId': _selectedSubCategoryId ?? '',
                          'selectedId': selectedId ?? '',
                          'parentType': parentType,
                          'title': title,
                          'selectedBrandIds': _selectedBrandIds.toList(),
                        };
                        log('Applying filters: $filters');
                        widget.onApplyFilters(filters);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Categories Section
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories Header
        InkWell(
          onTap: () {
            setState(() {
              _isCategorySectionExpanded = !_isCategorySectionExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              Icon(
                _isCategorySectionExpanded ? Icons.remove : Icons.add,
                color: kPrimaryColor,
              ),
            ],
          ),
        ),

        if (_isCategorySectionExpanded) ...[
          const SizedBox(height: 8),

          // Use Obx to listen to menuController
          Obx(() {
            if (_menuController.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // All Categories option
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = 'all';
                      _selectedSubCategoryId = null;
                      _selectedTitle = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedCategoryId == 'all'
                                  ? kPrimaryColor
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: _selectedCategoryId == 'all'
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "All Categories",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedCategoryId == 'all'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedCategoryId == 'all'
                                ? kPrimaryColor
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category list from menuController
                ..._menuController.categories.map((category) => _buildCategoryTile(category)).toList(),
              ],
            );
          }),
        ],
      ],
    );
  }

  // Brands Section (shows brands available in current products)
  Widget _buildBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brands Header
        InkWell(
          onTap: () {
            setState(() {
              _isBrandSectionExpanded = !_isBrandSectionExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isBrandsLoading ? "Brands" : "Brands (${_availableBrands.length})",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              Icon(
                _isBrandSectionExpanded ? Icons.remove : Icons.add,
                color: kPrimaryColor,
              ),
            ],
          ),
        ),

        if (_isBrandSectionExpanded) ...[
          const SizedBox(height: 8),

          if (_isBrandsLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_availableBrands.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No brands available in this category',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            // Brand list with checkboxes
            ..._availableBrands.map((brand) {
              final brandId = brand['id'] ?? '';
              final brandName = brand['name'] ?? '';
              final isSelected = _selectedBrandIds.contains(brandId);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedBrandIds.remove(brandId);
                    } else {
                      _selectedBrandIds.add(brandId);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      // Checkbox
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? kPrimaryColor : Colors.grey,
                            width: 2,
                          ),
                          color: isSelected ? kPrimaryColor : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          brandName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? kPrimaryColor : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ],
    );
  }
}
