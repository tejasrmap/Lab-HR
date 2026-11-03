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
        return const Color(0xFF38BDF8); // Electric Sky Blue
      case 'stationery':
        return const Color(0xFFF59E0B); // Amber
      case 'hardware':
        return const Color(0xFFA855F7); // Purple
      case 'grocery':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF94A3B8);
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1527),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLow ? const Color(0xFFF43F5E) : const Color(0xFF1E293B),
          width: isLow ? 1.5 : 1,
        ),
        boxShadow: isLow
            ? [
                BoxShadow(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getCategoryIcon(item.category), size: 16, color: catColor),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF334155)),
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
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: catColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    color: catColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (isLow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E0D1B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF43F5E)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFF43F5E)),
                      SizedBox(width: 4),
                      Text(
                        'LOW STOCK',
                        style: TextStyle(
                          color: Color(0xFFFDA4AF),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
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
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Metric Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  label: 'Quantity',
                  value: '${item.quantity}',
                  valueColor: isLow ? const Color(0xFFF43F5E) : Colors.white,
                  icon: Icons.inventory_2_outlined,
                ),
                Container(height: 28, width: 1, color: const Color(0xFF1E293B)),
                _buildMetric(
                  label: 'Unit Price',
                  value: currencyFormatter.format(item.unitPrice),
                  valueColor: const Color(0xFF10B981),
                  icon: Icons.payments_outlined,
                ),
                Container(height: 28, width: 1, color: const Color(0xFF1E293B)),
                _buildMetric(
                  label: 'Reorder Level',
                  value: '${item.reorderLevel}',
                  valueColor: const Color(0xFF94A3B8),
                  icon: Icons.flag_outlined,
                ),
              ],
            ),
          ),
        ],
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
            Icon(icon, size: 12, color: const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
