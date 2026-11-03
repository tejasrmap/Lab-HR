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

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _lowStockOnly = false;
  QuantitySortOrder _sortOrder = QuantitySortOrder.none;

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

    final filtered = items.where((item) {
      final matchesSearch = query.isEmpty ||
          item.itemName.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesLowStock = !_lowStockOnly || (item.quantity <= item.reorderLevel);

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();

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
      backgroundColor: const Color(0xFFF1F5F9), // Light slate gray background
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stock Inventory Manager',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'NET4207 Cross Platform Mobile App Development',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ActionChip(
              avatar: Icon(
                _isFormExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                _isFormExpanded ? 'Collapse Form' : 'New Item',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFF334155)),
              onPressed: () {
                setState(() {
                  _isFormExpanded = !_isFormExpanded;
                });
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 1. Task 1: Stock Entry Form (Collapsible)
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: const StockForm(),
                  secondChild: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _isFormExpanded = true),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Open Stock Entry Form'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  crossFadeState: _isFormExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                ),
              ),

              // 2. Task 3: Search & Filter Controls
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 4),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: Color(0xFF334155)),
                          SizedBox(width: 8),
                          Text(
                            'Inventory Records & Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
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

              // 3. Task 2 & Task 5: Real-time Firestore Stream
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
                            Text(
                              'Connecting to Cloud Firestore...',
                              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
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
                              const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFDC2626)),
                              const SizedBox(height: 12),
                              const Text(
                                'Error retrieving Firestore data',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Inventory Records in Firestore Yet',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Fill in the form above and tap "Save Stock Item" to add your first record.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFD97706)),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No matching items found',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try clearing your filters or adjusting your search keywords.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Reset All Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E40AF),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Results Header + Cards
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${displayItems.length} of ${rawItems.length} items',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '\u25CF Firestore Live Sync',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF166534), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
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
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
