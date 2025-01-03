import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class InventoryProvider with ChangeNotifier {
  String? userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<InventoryItem>> _itemsController =
      StreamController<List<InventoryItem>>.broadcast();

  Stream<List<InventoryItem>> get itemsStream => _itemsController.stream;

  List<InventoryItem> _items = [];
  List<InventoryItem> get items => _items;

  InventoryProvider() {
    _initUserId();
  }

  Future<void> _initUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _fetchInventoryItems(); // Fetch inventory items once user ID is set
    }
  }

  void _fetchInventoryItems() {
    if (userId == null) return;

    _firestore
        .collection('inventory')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return InventoryItem(
            id: doc.id,
            name: data['name'] ?? 'Unknown',
            quantity: data['quantity'] ?? 0,
            dateAdded: _parseDateAdded(data['dateAdded']),
          );
        }).toList();

        _items = items;
        _itemsController.add(_items);
        notifyListeners();
      },
      onError: (error) {
        _itemsController.addError(error);
      },
    );
  }

  DateTime _parseDateAdded(dynamic dateAdded) {
    if (dateAdded is Timestamp) {
      return dateAdded.toDate();
    } else if (dateAdded is String) {
      // Assuming the string is in a recognizable date format
      return DateTime.tryParse(dateAdded) ?? DateTime.now();
    } else {
      // Fallback to current date if type is unrecognized
      print('Warning: Unrecognized date type. Defaulting to current date.');
      return DateTime.now();
    }
  }

  Future<void> addItem(InventoryItem item) async {
    if (userId == null) return;
    await _firestore
        .collection('inventory')
        .doc(userId)
        .collection('items')
        .add(item.toMap());
    _fetchInventoryItems(); // Refresh items after adding
  }

  Future<void> updateItemQuantity(String id, int quantity) async {
    if (userId == null) return;
    await _firestore
        .collection('inventory')
        .doc(userId)
        .collection('items')
        .doc(id)
        .update({
      'quantity': quantity,
    });
    _fetchInventoryItems(); // Refresh items after updating
  }

  Future<void> deleteItem(String id) async {
    if (userId == null) return;
    await _firestore
        .collection('inventory')
        .doc(userId)
        .collection('items')
        .doc(id)
        .delete();
    _fetchInventoryItems(); // Refresh items after deleting
  }

  Future<void> updateItem(InventoryItem updatedItem) async {
    try {
      final itemRef = _firestore
          .collection('inventory')
          .doc(userId)
          .collection('items')
          .doc(updatedItem.id);
      await itemRef.update(updatedItem.toMap());
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        _itemsController.add(_items);
        notifyListeners();
      }
    } catch (error) {
      print('Error updating item: $error');
    }
  }

  @override
  void dispose() {
    _itemsController.close();
    super.dispose();
  }
}
