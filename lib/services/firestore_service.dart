import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_item.dart';

class FirestoreService {
  final CollectionReference _stockCollection =
      FirebaseFirestore.instance.collection('stockItems');

  /// Stream of all stock items from Firestore, updated in real-time
  Stream<List<StockItem>> getStockItemsStream() {
    return _stockCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StockItem.fromFirestore(doc)).toList();
    });
  }

  /// Add a new stock item to Firestore collection 'stockItems'
  Future<DocumentReference> addStockItem(StockItem item) async {
    return await _stockCollection.add(item.toMap());
  }

  /// Delete stock item (utility)
  Future<void> deleteStockItem(String id) async {
    await _stockCollection.doc(id).delete();
  }
}
