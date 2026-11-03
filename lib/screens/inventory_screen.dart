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
      backgroundColor: const Color(0xFF070B14), // Dark midnight background
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        titleSpacing: 20,
        title: Row(
          children: [
            // GT INNOX-style Brand Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'GT INNOX',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Pill tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1527),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: const Text(
                'NET4207 CLOUD LAB',
                style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ActionChip(
              avatar: Icon(
                _isFormExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 14,
                color: Colors.white,
              ),
              label: Text(
                _isFormExpanded ? 'Collapse Form' : 'New Item',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF0F172A),
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
          constraints: const BoxConstraints(maxWidth: 960),
          child: CustomScrollView(
            slivers: [
              // Hero Section: GT INNOX Studio Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1527),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF06B6D4)),
                            SizedBox(width: 4),
                            Text(
                              'GT INNOX STUDIO & LAB  •  V2.1.0',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Stock Inventory Studio',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enterprise-grade stock management suite with Firestore live sync, validation, and multi-criteria filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 1. Task 1: Stock Entry Form (Collapsible)
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: const StockForm(),
                  secondChild: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _isFormExpanded = true),
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF38BDF8)),
                      label: const Text(
                        'Expand Stock Entry Form',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1527),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF1E293B)),
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
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: Color(0xFF38BDF8)),
                          SizedBox(width: 8),
                          Text(
                            'Inventory Database & Search Engine',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                            CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF06B6D4)),
                            SizedBox(height: 14),
                            Text(
                              'Connecting to Cloud Firestore database...',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
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
                              const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFF43F5E)),
                              const SizedBox(height: 12),
                              const Text(
                                'Error communicating with Firestore',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final rawItems = snapshot.data ?? [];

                  // Database empty state (GT INNOX Studio dashed box style)
                  if (rawItems.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1527),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.cloud_upload_outlined, size: 38, color: Color(0xFF06B6D4)),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Inventory Records in Firestore',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Use the stock entry form above to save your first item to Firestore.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                              ],
                            ),
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
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1527),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFF59E0B)),
                                const SizedBox(height: 14),
                                const Text(
                                  'No matching stock items found',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try adjusting your search query, category, or low-stock criteria.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _clearFilters,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Reset All Filters'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFF334155)),
                                  ),
                                ),
                              ],
                            ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${displayItems.length} of ${rawItems.length} records',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF052E16),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
                                  ),
                                  child: const Text(
                                    '\u25CF Firestore Realtime Engine',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF4ADE80), fontWeight: FontWeight.bold),
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
                child: SizedBox(height: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
