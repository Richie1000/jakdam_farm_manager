import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/inventory_item.dart';

class InventoryProvider with ChangeNotifier {
  late String userId;

  InventoryProvider() {
    _initUserId();
  }

  void _initUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      await fetchItems();
    }
  }

  CollectionReference get inventoryCollection =>
      FirebaseFirestore.instance.collection(userId);

  Future<void> addItem(InventoryItem item) async {
    final docRef = await inventoryCollection.add(item.toMap());
    item.id = docRef.id;
    item.dateAdded = DateTime.now(); // Set the dateAdded field
    notifyListeners();
  }

  Future<void> fetchItems() async {
    if (userId.isEmpty) return;
    var snapshot = await inventoryCollection.get();
    _items = snapshot.docs
        .map((doc) =>
            InventoryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> deleteItem(String docId) async {
    await inventoryCollection.doc(docId).delete();
    await fetchItems(); // Ensure items are updated after deleting
  }

  Future<void> updateItemQuantity(String docId, int quantity) async {
    await inventoryCollection.doc(docId).update({'quantity': quantity});
    await fetchItems(); // Ensure items are updated after updating
  }

  List<InventoryItem> _items = [];
  List<InventoryItem> get items => _items;

  Future<void> updateItem(InventoryItem updatedItem) async {
    try {
      final itemRef = inventoryCollection.doc(updatedItem.id);
      await itemRef.update(updatedItem.toMap());
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (error) {
      //print('Error updating item: $error');
    }
  }
}
