import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../services/firestore_service.dart';
import '../widgets/stock_form.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/stock_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Search & Filter state variables
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _lowStockOnly = false;
  QuantitySortOrder _sortOrder = QuantitySortOrder.none;

  // UI state for showing/collapsing the Form
  bool _isFormExpanded = true;

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'All';
      _lowStockOnly = false;
      _sortOrder = QuantitySortOrder.none;
    });
  }

  List<StockItem> _applyFiltersAndSort(List<StockItem> items) {
    final query = _searchQuery.trim().toLowerCase();

    // Combined filtering using AND logic
    final filtered = items.where((item) {
      // 1. Keyword search: partial case-insensitive match against itemName OR sku
      final matchesSearch = query.isEmpty ||
          item.itemName.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      // 2. Category filter: 'All' or exact category match
      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 3. Low-stock filter: quantity <= reorderLevel
      final matchesLowStock = !_lowStockOnly || (item.quantity <= item.reorderLevel);

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();

    // 4. Sort visible results by quantity
    if (_sortOrder == QuantitySortOrder.ascending) {
      filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
    } else if (_sortOrder == QuantitySortOrder.descending) {
      filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Inventory Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _isFormExpanded ? 'Collapse Form' : 'Expand Form',
            icon: Icon(_isFormExpanded ? Icons.expand_less : Icons.add_circle_outline),
            onPressed: () {
              setState(() {
                _isFormExpanded = !_isFormExpanded;
              });
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Task 1: Stock Entry Form (Collapsible/Scrollable)
          SliverToBoxAdapter(
            child: AnimatedCrossFade(
              firstChild: StockForm(
                onItemSaved: () {
                  // Optional scroll or feedback
                },
              ),
              secondChild: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isFormExpanded = true),
                  icon: const Icon(Icons.add),
                  label: const Text('Open Stock Entry Form'),
                ),
              ),
              crossFadeState: _isFormExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            ),
          ),

          // 2. Task 3: Search & Filter Controls positioned above inventory list
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Firestore Inventory & Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SearchFilterBar(
                  searchQuery: _searchQuery,
                  onSearchQueryChanged: (val) => setState(() => _searchQuery = val),
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (val) => setState(() => _selectedCategory = val),
                  lowStockOnly: _lowStockOnly,
                  onLowStockChanged: (val) => setState(() => _lowStockOnly = val),
                  sortOrder: _sortOrder,
                  onSortOrderChanged: (val) => setState(() => _sortOrder = val),
                  onClearFilters: _clearFilters,
                ),
              ],
            ),
          ),

          // 3. Task 2 & Task 5: Real-time Firestore Inventory Stream
          StreamBuilder<List<StockItem>>(
            stream: _firestoreService.getStockItemsStream(),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Connecting to Firestore...'),
                      ],
                    ),
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          const Text(
                            'Error retrieving Firestore data',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final rawItems = snapshot.data ?? [];

              // Database empty state
              if (rawItems.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No items found in Firestore collection "stockItems".',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Fill in the form above and tap "Save Item" to record stock.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Apply Filters and Sorting
              final displayItems = _applyFiltersAndSort(rawItems);

              // No matching search results state
              if (displayItems.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.orange.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching stock items found.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try adjusting your search keywords, category, or low-stock criteria.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Results Count Badge
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'Showing ${displayItems.length} of ${rawItems.length} items',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      );
                    }
                    final item = displayItems[index - 1];
                    return StockCard(item: item);
                  },
                  childCount: displayItems.length + 1,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
