import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  final String userId;
  final String pondId;

  const ExpenseTrackingScreen(
      {super.key, required this.userId, required this.pondId,
        //required String farmId
      });

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
          content: SingleChildScrollView(
            child: Column(
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

                  final pondDocRef = _firestore
                      .collection('farms')
                      .doc(widget.userId)
                      .collection('userFarms')
                      .doc(widget.pondId);

                  // Check if the pond document exists
                  final docSnapshot = await pondDocRef.get();

                  if (!docSnapshot.exists) {
                    // Document doesn't exist, create a new one with an empty 'expense' array
                    await pondDocRef.set({
                      'expense': [
                        record
                      ], // Initialize with the first expense record
                    });
                  } else {
                    // Document exists, update the expense array
                    if (existingRecord == null) {
                      await pondDocRef.update({
                        'expense': FieldValue.arrayUnion([record]),
                      });
                    } else {
                      // Edit existing record
                      await pondDocRef.update({
                        'expense': FieldValue.arrayRemove([existingRecord]),
                      });
                      await pondDocRef.update({
                        'expense': FieldValue.arrayUnion([record]),
                      });
                    }
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
          .doc(widget.pondId)
          .update({
        'expense': FieldValue.arrayRemove([record]),
      });
    }
  }

  Future<String> _getAppSpecificDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? '';
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> feedRecords) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Item'),
        TextCellValue('Cost'),
      ]);

      for (var record in feedRecords) {
        final date = record['date'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(record['date']))
            : 'N/A';
        final item = record['item']?.toString() ?? 'N/A';
        final cost = record['cost']?.toString() ?? 'N/A';

        sheet.appendRow([
          TextCellValue(date),
          TextCellValue(item),
          TextCellValue(cost),
        ]);
      }

      final directory = await _getAppSpecificDirectory();
      if (directory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get storage directory')),
        );
        return;
      }

      final fileName =
          'Expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '$directory/$fileName';
      final fileBytes = excel.save();

      if (fileBytes != null) {
        final file = File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported successfully!'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to open file: ${result.message}')),
                  );
                }
              },
            ),
          ),
        );
      } else {
        throw Exception('Failed to save Excel file.');
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to Excel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final snapshot = await _firestore
                  .collection('farms')
                  .doc(widget.userId)
                  .collection('userFarms')
                  .doc(widget.pondId)
                  .get();

              if (snapshot.exists &&
                  snapshot.data() != null &&
                  (snapshot.data() as Map<String, dynamic>)
                      .containsKey('feed')) {
                final feedRecords = List<Map<String, dynamic>>.from(
                    (snapshot.data() as Map<String, dynamic>)['expense']);
                _exportToExcel(feedRecords);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No feed records to export')),
                );
              }
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('farms')
            .doc(widget.userId)
            .collection('userFarms')
            .doc(widget.pondId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('No Expenses Found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null || !data.containsKey('expense')) {
            return const Center(child: Text('No Expenses Found'));
          }

          final expenseRecords =
              List<Map<String, dynamic>>.from(data['expense']);

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
