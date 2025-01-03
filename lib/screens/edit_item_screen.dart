import 'package:flutter/material.dart';
import '../models/inventory_item.dart'; // Import your model class
import '../providers/inventory_provider.dart'; // Import your provider class
import 'package:provider/provider.dart';

class EditItemScreen extends StatefulWidget {
  final InventoryItem item;

  EditItemScreen({required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateItem(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateItem(BuildContext context) {
    final String name = _nameController.text;
    final int quantity = int.parse(_quantityController.text);

    final updatedItem = InventoryItem(
      id: widget.item.id,
      name: name,
      quantity: quantity,
      dateAdded: widget.item.dateAdded,
    );

    Provider.of<InventoryProvider>(context, listen: false)
        .updateItem(updatedItem);
    Navigator.pop(context);
  }
}
