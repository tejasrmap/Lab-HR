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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1527),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Search Field
          TextField(
            onChanged: onSearchQueryChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by Item Name or SKU (e.g. mouse, STK-101)...',
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () => onSearchQueryChanged(''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Row 2: Category Filter & Sort Dropdown
          Row(
            children: [
              // Category Filter
              Expanded(
                flex: 5,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category Filter',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      isDense: true,
                      isExpanded: true,
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
                ),
              ),
              const SizedBox(width: 12),

              // Sort By Quantity
              Expanded(
                flex: 5,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sort By Quantity',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<QuantitySortOrder>(
                      value: sortOrder,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      isDense: true,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: QuantitySortOrder.none,
                          child: Text('Default Order'),
                        ),
                        DropdownMenuItem(
                          value: QuantitySortOrder.ascending,
                          child: Text('Qty: Low to High \u2191'),
                        ),
                        DropdownMenuItem(
                          value: QuantitySortOrder.descending,
                          child: Text('Qty: High to Low \u2193'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) onSortOrderChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Low-Stock Toggle & Clear Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: lowStockOnly ? const Color(0xFF200E19) : const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: lowStockOnly ? const Color(0xFFF43F5E).withValues(alpha: 0.5) : const Color(0xFF1E293B),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => onLowStockChanged(!lowStockOnly),
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: lowStockOnly,
                        activeTrackColor: const Color(0xFFF43F5E),
                        onChanged: onLowStockChanged,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Low Stock Only (Qty \u2264 Reorder)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: lowStockOnly ? const Color(0xFFFDA4AF) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16, color: Color(0xFFF97316)),
                    label: const Text(
                      'Clear Filters',
                      style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
