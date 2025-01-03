import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FeedRecordScreen extends StatefulWidget {
  final String userId;
  final String farmId;

  const FeedRecordScreen(
      {super.key, required this.userId, required this.farmId});

  @override
  State<FeedRecordScreen> createState() => _FeedRecordScreenState();
}

class _FeedRecordScreenState extends State<FeedRecordScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to export the table to an Excel file
  Future<void> _exportToExcel(List<Map<String, dynamic>> feedRecords) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Feed Records'];

      // Add header row with proper CellValue types
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Brand'),
        TextCellValue('Size'),
        TextCellValue('Bags'),
      ]);

      // Add data rows
      for (var record in feedRecords) {
        sheet.appendRow([
          TextCellValue(
              record['date'].toString()), // Assuming date is String or DateTime
          TextCellValue(record['brand'].toString()), // Assuming brand is String
          TextCellValue(record['size'].toString()), // Assuming size is String
          IntCellValue(int.tryParse(record['bags'].toString()) ??
              0), // Assuming bags is numeric
        ]);
      }

      // Directory selection
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No directory selected')),
        );
        return;
      }

      // Save file
      final fileName =
          'FeedRecords_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '$directory/$fileName';
      final fileBytes = excel.save();

      if (fileBytes != null) {
        final file = File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved at: $filePath')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting: $e')),
      );
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
                  .doc(widget.farmId)
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
            .doc(widget.farmId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              !(snapshot.data!.data() as Map<String, dynamic>)
                  .containsKey('feed')) {
            return const Center(child: Text('No Feed Records Found'));
          }

          final feedRecords = List<Map<String, dynamic>>.from(
              (snapshot.data!.data() as Map<String, dynamic>)['feed']);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Brand')),
                DataColumn(label: Text('Size')),
                DataColumn(label: Text('Bags')),
              ],
              rows: feedRecords.map((record) {
                final formattedDate = DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(record['date']));
                return DataRow(cells: [
                  DataCell(Text(formattedDate)),
                  DataCell(Text(record['brand'])),
                  DataCell(Text(record['size'])),
                  DataCell(Text(record['bags'])),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
