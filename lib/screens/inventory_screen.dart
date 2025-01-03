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
      appBar: AppBar(
        title: Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: InventorySearch(
                  Provider.of<InventoryProvider>(context, listen: false).items,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          return StreamBuilder<List<InventoryItem>>(
            stream: provider.itemsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No items'));
              } else {
                return SingleChildScrollView(
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
                      rows: snapshot.data!.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item.name)),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text(
                              '${item.dateAdded.year}-${item.dateAdded.month.toString().padLeft(2, '0')}-${item.dateAdded.day.toString().padLeft(2, '0')}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  Provider.of<InventoryProvider>(context,
                                          listen: false)
                                      .updateItemQuantity(
                                          item.id, item.quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  Provider.of<InventoryProvider>(context,
                                          listen: false)
                                      .updateItemQuantity(
                                          item.id, item.quantity - 1);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  Provider.of<InventoryProvider>(context,
                                          listen: false)
                                      .deleteItem(item.id);
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddItemScreen()));
        },
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
