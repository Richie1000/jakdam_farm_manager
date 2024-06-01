import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory')),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          return provider.items.isEmpty
              ? Center(child: Text('No items'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Date Added')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: provider.items.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item.name)),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text(item.dateAdded
                              .toIso8601String()
                              .substring(0, 10)
                              .split('-')
                              .reversed
                              .join('/'))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  provider.updateItemQuantity(
                                      item.id, item.quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  provider.updateItemQuantity(
                                      item.id, item.quantity - 1);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  provider.deleteItem(item.id);
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            child: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: InventorySearch(
                      Provider.of<InventoryProvider>(context, listen: false)
                          .items));
            },
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn2",
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AddItemScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class InventorySearch extends SearchDelegate<InventoryItem?> {
  final List<InventoryItem> items;

  InventorySearch(this.items);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results
          .map((item) => ListTile(
                title: Text(item.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(item: item),
                    ),
                  );
                },
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions
          .map((item) => ListTile(
                title: Text(item.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(item: item),
                    ),
                  );
                },
              ))
          .toList(),
    );
  }
}
