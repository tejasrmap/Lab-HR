import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_item.dart';

class StockCard extends StatelessWidget {
  final StockItem item;
  final VoidCallback? onDelete;

  const StockCard({
    super.key,
    required this.item,
    this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return const Color(0xFF2563EB); // Blue
      case 'stationery':
        return const Color(0xFFD97706); // Amber
      case 'hardware':
        return const Color(0xFF7C3AED); // Purple
      case 'grocery':
        return const Color(0xFF059669); // Emerald
      default:
        return const Color(0xFF475569);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices_rounded;
      case 'stationery':
        return Icons.edit_note_rounded;
      case 'hardware':
        return Icons.build_circle_outlined;
      case 'grocery':
        return Icons.shopping_basket_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');
    final isLow = item.isLowStock;
    final catColor = _getCategoryColor(item.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isLow ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isLow ? 1.5 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isLow ? const Color(0xFFFFFBFB) : Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category icon, SKU, Category Badge & Low Stock Warning
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getCategoryIcon(item.category), size: 18, color: catColor),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.sku,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: catColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      color: catColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isLow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                        SizedBox(width: 4),
                        Text(
                          'LOW STOCK',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Item Name
            Text(
              item.itemName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // Metric Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    label: 'Quantity',
                    value: '${item.quantity}',
                    valueColor: isLow ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                    icon: Icons.inventory_2_outlined,
                  ),
                  Container(height: 30, width: 1, color: const Color(0xFFCBD5E1)),
                  _buildMetric(
                    label: 'Unit Price',
                    value: currencyFormatter.format(item.unitPrice),
                    valueColor: const Color(0xFF059669),
                    icon: Icons.payments_outlined,
                  ),
                  Container(height: 30, width: 1, color: const Color(0xFFCBD5E1)),
                  _buildMetric(
                    label: 'Reorder Level',
                    value: '${item.reorderLevel}',
                    valueColor: const Color(0xFF64748B),
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
