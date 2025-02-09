import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pond_details_screen.dart';

class SelectPondScreen extends StatefulWidget {
  final String farmId;
  final String userId;

  const SelectPondScreen({
    super.key,
    required this.farmId,
    required this.userId,
  });

  @override
  State<SelectPondScreen> createState() => _SelectPondScreenState();
}

class _SelectPondScreenState extends State<SelectPondScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _ponds = [];

  @override
  void initState() {
    super.initState();
    _fetchPonds();
  }

  Future<void> _fetchPonds() async {
    try {
      final querySnapshot = await _firestore
          .collection('farms')
          .doc(widget.userId)
          .collection('userFarms')
          .doc(widget.farmId)
          .collection('ponds')
          .get();

      setState(() {
        _ponds = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
      });

      if (_ponds.isEmpty) {
        debugPrint('No ponds found for farm: ${widget.farmId}');
      }
    } catch (e) {
      debugPrint('Error fetching ponds: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load ponds. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addNewPond() async {
    String pondName = '';
    String pondDescription = '';
    String initialStock = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Pond'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Pond Name'),
                  onChanged: (value) {
                    pondName = value;
                  },
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Pond Description'),
                  onChanged: (value) {
                    pondDescription = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Initial Stock'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    initialStock = value;
                  },
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
                if (pondName.isNotEmpty &&
                    pondDescription.isNotEmpty &&
                    initialStock.isNotEmpty) {
                  try {
                    final stockValue = int.tryParse(initialStock);
                    if (stockValue == null || stockValue < 0) {
                      throw Exception('Invalid Initial Stock value.');
                    }

                    await _firestore
                        .collection('farms')
                        .doc(widget.userId)
                        .collection('userFarms')
                        .doc(widget.farmId)
                        .collection('ponds')
                        .add({
                      'name': pondName,
                      'description': pondDescription,
                      'initialStock': stockValue,
                    });

                    Navigator.pop(context);
                    _fetchPonds();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Failed to add pond. Ensure "Initial Stock" is a valid number.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: const Text('Add Pond'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPondList() {
    return ListView.builder(
      itemCount: _ponds.length,
      itemBuilder: (context, index) {
        final pond = _ponds[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(pond['name'] ?? 'Unnamed Pond'),
            subtitle: Text(pond['description'] ?? 'No description provided'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PondDetailsScreen(
                    pondId: pond['id'],
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No ponds found for this farm.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchPonds,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_ponds.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildPondList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pond'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPond,
        child: const Icon(Icons.add),
        tooltip: 'Add New Pond',
      ),
    );
  }
}
