import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> farm;

  const FarmDetailsScreen({super.key, required this.farm});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  List<Map<String, dynamic>> expenseRecords = [];
  List<Map<String, dynamic>> feedRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchFarmDetails();
  }

  Future<void> _fetchFarmDetails() async {
    try {
      final expenseSnapshot = await _firestore
          .collection('Expense_tracking')
          .where('farmId', isEqualTo: widget.farm['id'])
          .get();

      final feedSnapshot = await _firestore
          .collection('Feed_records')
          .where('farmId', isEqualTo: widget.farm['id'])
          .get();

      setState(() {
        expenseRecords = expenseSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        feedRecords = feedSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildRecordList(List<Map<String, dynamic>> records, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        records.isEmpty
            ? const Text('No records found.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(record['title'] ?? 'No Title'),
                      subtitle: Text(record['details'] ?? 'No Details'),
                    ),
                  );
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm['name'] ?? 'Farm Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Name: ${widget.farm['name'] ?? 'Unnamed'}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${widget.farm['location'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildRecordList(expenseRecords, 'Expense Records'),
                  const SizedBox(height: 16),
                  _buildRecordList(feedRecords, 'Feed Records'),
                ],
              ),
            ),
    );
  }
}
