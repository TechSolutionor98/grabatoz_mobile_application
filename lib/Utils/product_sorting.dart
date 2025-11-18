List<dynamic> sortProductsForDisplay(List<dynamic> productList) {
  if (productList.isEmpty) return const [];

  final preorder = <dynamic>[];
  final available = <dynamic>[];
  final outOfStock = <dynamic>[];

  for (final e in productList) {
    if (e is! Map<String, dynamic>) {
      available.add(e);
      continue;
    }
    final s = (e['stockStatus'] ?? '').toString().toLowerCase();
    if (s == 'preorder' || s == 'pre order') {
      preorder.add(e);
    } else if (s == 'out of stock') {
      outOfStock.add(e);
    } else {
      available.add(e);
    }
  }
  // CHANGE: Available -> PreOrder -> Out of Stock
  return [...available, ...preorder, ...outOfStock];
}
