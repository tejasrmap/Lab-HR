import 'package:cloud_firestore/cloud_firestore.dart';

class StockItem {
  final String id;
  final String sku;
  final String itemName;
  final String category;
  final int quantity;
  final double unitPrice;
  final int reorderLevel;
  final Timestamp? createdAt;

  StockItem({
    required this.id,
    required this.sku,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.reorderLevel,
    this.createdAt,
  });

  /// True if quantity is less than or equal to reorder level
  bool get isLowStock => quantity <= reorderLevel;

  /// Convert Firestore document snapshot to StockItem model
  factory StockItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StockItem(
      id: doc.id,
      sku: (data['sku'] ?? '').toString(),
      itemName: (data['itemName'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      reorderLevel: (data['reorderLevel'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// Convert StockItem fields to map for Firestore document writing
  Map<String, dynamic> toMap() {
    return {
      'sku': sku.trim().toUpperCase(),
      'itemName': itemName.trim(),
      'category': category.trim(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'reorderLevel': reorderLevel,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
