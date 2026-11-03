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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Search Field
            TextField(
              onChanged: onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search by Item Name or SKU (e.g. mouse, STK-101)...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () => onSearchQueryChanged(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Row 2: Category Filter & Sort Dropdown
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // Category Filter
                    Expanded(
                      flex: 5,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
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
                );
              },
            ),
            const SizedBox(height: 12),

            // Row 3: Low-Stock Toggle & Clear Filters Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: lowStockOnly ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: lowStockOnly ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => onLowStockChanged(!lowStockOnly),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch.adaptive(
                            value: lowStockOnly,
                            activeTrackColor: const Color(0xFFEF4444),
                            onChanged: onLowStockChanged,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Low Stock Only (Qty \u2264 Reorder Level)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: lowStockOnly ? const Color(0xFFB91C1C) : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton.icon(
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 16, color: Color(0xFFEA580C)),
                      label: const Text(
                        'Clear Filters',
                        style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
