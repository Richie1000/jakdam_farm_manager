import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class StockScreen extends StatefulWidget {
  final String userId;
  final String pondId;

  const StockScreen({
    super.key,
    required this.userId,
    required this.pondId,
  });

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int? initialStock;
  int currentStock = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialAndCurrentStock();
  }

  Future<void> _fetchInitialAndCurrentStock() async {
    final pondDoc = await _firestore
        .collection('farms')
        .doc(widget.userId)
        .collection('userFarms')
        .doc(widget.pondId)
        .get();

    if (pondDoc.exists) {
      final data = pondDoc.data() as Map<String, dynamic>;
      setState(() {
        initialStock = data['initialStock'] ?? 0;
        currentStock = data['currentStock'] ?? initialStock!;
      });
    }
  }

  Future<void> _editRecord(Map<String, dynamic> record) async {
    // Initialize controllers for the text fields
    TextEditingController mortalityController =
    TextEditingController(text: record['mortality'].toString());
    TextEditingController rootCauseController =
    TextEditingController(text: record['rootCause']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Mortality Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: mortalityController,
                  decoration:
                  const InputDecoration(labelText: 'Updated Mortality'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rootCauseController,
                  decoration:
                  const InputDecoration(labelText: 'Updated Root Cause'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Parse and validate inputs
                String updatedMortality = mortalityController.text;
                String updatedRootCause = rootCauseController.text;

                final updatedMortalityInt = int.tryParse(updatedMortality) ?? 0;
                final difference = updatedMortalityInt - record['mortality'];

                if (difference.abs() > currentStock) {
                  // Alert the user if the difference exceeds the current stock
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Difference exceeds current stock. Update aborted.'),
                    ),
                  );
                  return;
                }

                if (updatedMortalityInt > 0 && updatedRootCause.isNotEmpty) {
                  final updatedRecord = {
                    'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    'mortality': updatedMortalityInt,
                    'rootCause': updatedRootCause,
                  };

                  final pondDocRef = _firestore
                      .collection('farms')
                      .doc(widget.userId)
                      .collection('userFarms')
                      .doc(widget.pondId);

                  // Remove the old record and update stock
                  await pondDocRef.update({
                    'stockRecords': FieldValue.arrayRemove([record]),
                  });

                  await pondDocRef.update({
                    'stockRecords': FieldValue.arrayUnion([updatedRecord]),
                    'currentStock': FieldValue.increment(-difference),
                  });

                  setState(() {
                    currentStock -= difference.toInt(); // Update the UI
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Alert the user about invalid inputs
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid inputs.'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord(Map<String, dynamic> record) async {
    final pondDocRef = _firestore
        .collection('farms')
        .doc(widget.userId)
        .collection('userFarms')
        .doc(widget.pondId);

    try {
      await pondDocRef.update({
        'stockRecords': FieldValue.arrayRemove([record]),
        'currentStock': FieldValue.increment(record['mortality']),
      });

      setState(() {
        currentStock += (record['mortality'] as int);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting record: $e')),
      );
    }
  }

  Future<void> _addMortalityRecord() async {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String mortality = '';
    String rootCause = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Mortality Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Mortality'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => mortality = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Root Cause'),
                  onChanged: (value) => rootCause = value,
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
              onPressed: (mortality.isNotEmpty && rootCause.isNotEmpty)
                  ? () async {
                final mortalityInt = int.tryParse(mortality) ?? 0;

                if (mortalityInt > currentStock) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                    content:
                    Text('Mortality cannot exceed current stock'),
                  ));
                  return;
                }

                if (mortalityInt > 0 && rootCause.isNotEmpty) {
                  final record = {
                    'date': date,
                    'mortality': mortalityInt,
                    'rootCause': rootCause,
                  };

                  final pondDocRef = _firestore
                      .collection('farms')
                      .doc(widget.userId)
                      .collection('userFarms')
                      .doc(widget.pondId);

                  try {
                    await pondDocRef.update({
                      'stockRecords': FieldValue.arrayUnion([record]),
                      'currentStock': FieldValue.increment(-mortalityInt),
                    });

                    setState(() {
                      currentStock -= mortalityInt;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Record added successfully')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding record: $e')),
                    );
                  }
                }
              }
                  : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<String> _getAppSpecificDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? '';
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> stockRecords) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Stock Records'];

      // Add headers to the Excel sheet
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Mortality'),
        TextCellValue('Root Cause'),
      ]);

      // Add rows of data
      for (var record in stockRecords) {
        final date = record['date'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(record['date']))
            : 'N/A';
        final mortality = record['mortality']?.toString() ?? 'N/A';
        final rootCause = record['rootCause']?.toString() ?? 'N/A';

        sheet.appendRow([
          TextCellValue(date),
          TextCellValue(mortality),
          TextCellValue(rootCause),
        ]);
      }

      // Save the file
      final directory = await _getAppSpecificDirectory();
      if (directory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get storage directory')),
        );
        return;
      }

      final fileName =
          'StockRecords_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '$directory/$fileName';
      final fileBytes = excel.save();

      if (fileBytes != null) {
        final file = File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported successfully: $fileName'),
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

  Future<List<Map<String, dynamic>>> _fetchStockRecords() async {
    final pondDoc = await _firestore
        .collection('farms')
        .doc(widget.userId)
        .collection('userFarms')
        .doc(widget.pondId)
        .get();

    if (pondDoc.exists) {
      final data = pondDoc.data() as Map<String, dynamic>;
      final stockRecords =
      List<Map<String, dynamic>>.from(data['stockRecords'] ?? []);
      return stockRecords;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final stockRecords =
              await _fetchStockRecords(); // Fetch stock records
              if (stockRecords.isNotEmpty) {
                _exportToExcel(stockRecords);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No records to export')),
                );
              }
            },
          ),
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

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('No Stock Records Found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final stockRecords = List<Map<String, dynamic>>.from(
              data['stockRecords'] ?? [])
            ..sort((a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Initial Stock: ${initialStock ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current Stock: $currentStock',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Mortality')),
                      DataColumn(label: Text('Root Cause')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: stockRecords.map((record) {
                      final formattedDate = DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(record['date']));

                      return DataRow(cells: [
                        DataCell(Text(formattedDate)),
                        DataCell(Text(
                            record['mortality']?.toInt().toString() ?? '0')),
                        DataCell(Text(record['rootCause'])),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Edit') {
                                _editRecord(record);
                              } else if (value == 'Delete') {
                                _deleteRecord(record);
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
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMortalityRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}
