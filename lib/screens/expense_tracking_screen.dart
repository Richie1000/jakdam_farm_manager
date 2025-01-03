import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  final String userId;
  final String farmId;

  const ExpenseTrackingScreen(
      {super.key, required this.userId, required this.farmId});

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addOrEditExpense({Map<String, dynamic>? existingRecord}) async {
    String item = existingRecord?['item'] ?? '';
    String cost = existingRecord?['cost'] ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingRecord == null ? 'Add Expense' : 'Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Item'),
                controller: TextEditingController(text: item),
                onChanged: (value) => item = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Cost'),
                controller: TextEditingController(text: cost),
                onChanged: (value) => cost = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (item.isNotEmpty && cost.isNotEmpty) {
                  final record = {
                    'date': existingRecord?['date'] ??
                        DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    'item': item,
                    'cost': cost,
                  };

                  // Update or add the record
                  if (existingRecord == null) {
                    await _firestore
                        .collection('farms')
                        .doc(widget.userId)
                        .collection('userFarms')
                        .doc(widget.farmId)
                        .update({
                      'expense': FieldValue.arrayUnion([record]),
                    });
                  } else {
                    await _firestore
                        .collection('farms')
                        .doc(widget.userId)
                        .collection('userFarms')
                        .doc(widget.farmId)
                        .update({
                      'expense': FieldValue.arrayRemove([existingRecord]),
                    });
                    await _firestore
                        .collection('farms')
                        .doc(widget.userId)
                        .collection('userFarms')
                        .doc(widget.farmId)
                        .update({
                      'expense': FieldValue.arrayUnion([record]),
                    });
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(existingRecord == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExpense(Map<String, dynamic> record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firestore
          .collection('farms')
          .doc(widget.userId)
          .collection('userFarms')
          .doc(widget.farmId)
          .update({
        'expense': FieldValue.arrayRemove([record]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracking')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('farms')
            .doc(widget.userId)
            .collection('userFarms')
            .doc(widget.farmId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              !(snapshot.data!.data() as Map<String, dynamic>)
                  .containsKey('expense')) {
            return const Center(child: Text('No Expenses Found'));
          }

          final expenseRecords = List<Map<String, dynamic>>.from(
              (snapshot.data!.data() as Map<String, dynamic>)['expense']);

          // Calculate total cost
          final totalCost = expenseRecords.fold<double>(
            0.0,
            (sum, record) => sum + double.tryParse(record['cost'] ?? '0')!,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Cost')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: expenseRecords.map((record) {
                      final formattedDate = DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(record['date']));
                      return DataRow(cells: [
                        DataCell(Text(formattedDate)),
                        DataCell(Text(record['item'])),
                        DataCell(Text(record['cost'])),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Edit') {
                                _addOrEditExpense(existingRecord: record);
                              } else if (value == 'Delete') {
                                _deleteExpense(record);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                            ],
                            child: const Icon(Icons.more_vert),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total: ${totalCost.toStringAsFixed(2)} GHC',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditExpense(),
        child: const Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }
}
