import 'package:flutter/material.dart';

enum QuantitySortOrder {
  none,
  ascending,
  descending,
}

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final bool lowStockOnly;
  final ValueChanged<bool> onLowStockChanged;
  final QuantitySortOrder sortOrder;
  final ValueChanged<QuantitySortOrder> onSortOrderChanged;
  final VoidCallback onClearFilters;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.lowStockOnly,
    required this.onLowStockChanged,
    required this.sortOrder,
    required this.onSortOrderChanged,
    required this.onClearFilters,
  });

  static const List<String> categories = [
    'All',
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = searchQuery.isNotEmpty ||
        selectedCategory != 'All' ||
        lowStockOnly ||
        sortOrder != QuantitySortOrder.none;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Keyword search (Name or SKU)
            TextField(
              onChanged: onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search by Item Name or SKU...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => onSearchQueryChanged(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),

            // 2. Category Dropdown & Sort by Quantity
            Row(
              children: [
                // Category Filter
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onCategoryChanged(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Sort By Quantity
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<QuantitySortOrder>(
                    value: sortOrder,
                    decoration: InputDecoration(
                      labelText: 'Sort Qty',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: QuantitySortOrder.none,
                        child: Text('Default'),
                      ),
                      DropdownMenuItem(
                        value: QuantitySortOrder.ascending,
                        child: Text('Qty: Low to High'),
                      ),
                      DropdownMenuItem(
                        value: QuantitySortOrder.descending,
                        child: Text('Qty: High to Low'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) onSortOrderChanged(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 3. Low Stock Switch & Clear Filters Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Low Stock Filter Checkbox/Switch
                InkWell(
                  onTap: () => onLowStockChanged(!lowStockOnly),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: lowStockOnly,
                        activeColor: Colors.redAccent,
                        onChanged: onLowStockChanged,
                      ),
                      const Text(
                        'Low Stock Only (Qty \u2264 Reorder)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Clear Filters Button
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.filter_alt_off, size: 18, color: Colors.deepOrange),
                    label: const Text(
                      'Clear Filters',
                      style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

