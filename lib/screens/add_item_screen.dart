import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';

class AddItemScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final item = InventoryItem(
                    id: '',
                    name: name,
                    quantity: quantity,
                    dateAdded: DateTime.now());
                Provider.of<InventoryProvider>(context, listen: false)
                    .addItem(item);
                Navigator.pop(context);
              },
              child: Text('Add Item'),
            )
          ],
        ),
      ),
    );
  }
}
