import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FeedRecordScreen extends StatefulWidget {
  final String userId;
  final String pondId;

  const FeedRecordScreen({
    super.key,
    required this.userId,
    required this.pondId,
    //required String farmId,
  });

  @override
  State<FeedRecordScreen> createState() => _FeedRecordScreenState();
}

class _FeedRecordScreenState extends State<FeedRecordScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        TextCellValue('Brand'),
        TextCellValue('Size'),
        TextCellValue('Bags'),
        TextCellValue('Weight(kg)'),
        TextCellValue('Price(GHC)'),
      ]);

      for (var record in feedRecords) {
        final date = record['date'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(record['date']))
            : 'N/A';
        final brand = record['brand']?.toString() ?? 'N/A';
        final size = record['size']?.toString() ?? 'N/A';
        final bags = int.tryParse(record['bags']?.toString() ?? '0') ?? 0;
        final weight = record['weight']?.toString() ?? '0';
        final price = record['price']?.toString() ?? '0';

        sheet.appendRow([
          TextCellValue(date),
          TextCellValue(brand),
          TextCellValue(size),
          TextCellValue('$bags'),
          TextCellValue(weight),
          TextCellValue(price),
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
          'FeedRecords_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
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

  Future<void> _addOrEditFeedRecord(
      {Map<String, dynamic>? existingRecord}) async {
    String brand = existingRecord?['brand'] ?? '';
    String size = existingRecord?['size'] ?? '';
    String bags = existingRecord?['bags'] ?? '';
    String weight = existingRecord?['weight'] ?? '';
    String price = existingRecord?['price'] ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              existingRecord == null ? 'Add Feed Record' : 'Edit Feed Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Brand'),
                  controller: TextEditingController(text: brand),
                  onChanged: (value) => brand = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Size'),
                  controller: TextEditingController(text: size),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => size = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Bags'),
                  controller: TextEditingController(text: bags),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => bags = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Weight(kg)'),
                  controller: TextEditingController(text: weight),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => weight = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Price(GHC)'),
                  controller: TextEditingController(text: price),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => price = value,
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
                if (brand.isNotEmpty &&
                    size.isNotEmpty &&
                    bags.isNotEmpty &&
                    weight.isNotEmpty &&
                    price.isNotEmpty) {
                  final record = {
                    'date': existingRecord?['date'] ??
                        DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    'brand': brand,
                    'size': size,
                    'bags': bags,
                    'weight': weight,
                    'price': price,
                  };

                  final pondDocRef = _firestore
                      .collection('farms')
                      .doc(widget.userId)
                      .collection('userFarms')
                      .doc(widget.pondId);

                  // Check if the pond document exists
                  final docSnapshot = await pondDocRef.get();

                  if (!docSnapshot.exists) {
                    // Document doesn't exist, create a new one with an empty 'feed' array
                    await pondDocRef.set({
                      'feed': [record], // Initialize with the first feed record
                    });
                  } else {
                    // Document exists, update the feed array
                    if (existingRecord == null) {
                      await pondDocRef.update({
                        'feed': FieldValue.arrayUnion([record]),
                      });
                    } else {
                      // Edit existing record
                      await pondDocRef.update({
                        'feed': FieldValue.arrayRemove([existingRecord]),
                      });
                      await pondDocRef.update({
                        'feed': FieldValue.arrayUnion([record]),
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
        'feed': FieldValue.arrayRemove([record]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Records'),
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
                    (snapshot.data() as Map<String, dynamic>)['feed']);
                _exportToExcel(feedRecords);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No feed records to export')),
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
            return const Center(child: Text('No Feed Records Found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (!data.containsKey('feed') || data['feed'] == null) {
            return const Center(child: Text('No Feed Records Found'));
          }

          final feedRecords =
              List<Map<String, dynamic>>.from(data['feed'] ?? []);

          if (feedRecords.isEmpty) {
            return const Center(child: Text('No Feed Records Found'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Brand')),
                DataColumn(label: Text('Size')),
                DataColumn(label: Text('Bags')),
                DataColumn(label: Text('Weight(kg)')),
                DataColumn(label: Text('Price(GHC)')),
                DataColumn(label: Text('Actions')),
              ],
              rows: feedRecords.map((record) {
                final formattedDate = record['date'] != null
                    ? DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(record['date']))
                    : 'N/A';

                return DataRow(cells: [
                  DataCell(Text(formattedDate)),
                  DataCell(
                    Text(
                      record['brand']?.toString().length != null &&
                              record['brand']!.toString().length > 12
                          ? '${record['brand']!.toString().substring(0, 12)}...'
                          : record['brand']?.toString() ?? 'N/A',
                    ),
                  ),
                  DataCell(Text(record['size']?.toString() ?? 'N/A')),
                  DataCell(Text(record['bags']?.toString() ?? '0')),
                  DataCell(Text(record['weight']?.toString() ?? '0')),
                  DataCell(Text(record['price']?.toString() ?? '0')),
                  DataCell(
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          _addOrEditFeedRecord(existingRecord: record);
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEditFeedRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}
