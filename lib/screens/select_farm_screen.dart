import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'farm_details_screen.dart';

class SelectFarmScreen extends StatefulWidget {
  const SelectFarmScreen({super.key});

  @override
  State<SelectFarmScreen> createState() => _SelectFarmScreenState();
}

class _SelectFarmScreenState extends State<SelectFarmScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _farms = [];

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  Future<void> _fetchFarms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in.');
      _userId = user.uid;

      final querySnapshot = await _firestore
          .collection('farms')
          .doc(_userId)
          .collection('userFarms')
          .get();

      setState(() {
        _farms = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
      });

      if (_farms.isEmpty) {
        debugPrint('No farms found for user: $_userId');
      }
    } catch (e) {
      debugPrint('Error fetching farms: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load farms. Please try again.');
    }
  }

  Future<void> _deleteFarm(String farmId) async {
    try {
      await _firestore
          .collection('farms')
          .doc(_userId)
          .collection('userFarms')
          .doc(farmId)
          .delete();

      setState(() {
        _farms.removeWhere((farm) => farm['id'] == farmId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm deleted successfully.')),
      );
    } catch (e) {
      debugPrint('Error deleting farm: $e');
      _showError('Failed to delete farm. Please try again.');
    }
  }

  void _confirmDelete(String farmId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: const Text(
          'Are you sure you want to delete this farm? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFarm(farmId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildFarmList() {
    return ListView.builder(
      itemCount: _farms.length,
      itemBuilder: (context, index) {
        final farm = _farms[index];
        return Dismissible(
          key: Key(farm['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            _confirmDelete(farm['id']);
            return false; // Prevent auto-dismiss, we handle deletion manually
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(farm['name'] ?? 'Unnamed Farm'),
              subtitle: Text(farm['location'] ?? 'No location provided'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmDetailsScreen(
                      farmId: farm['id'],
                      userId: _userId!,
                    ),
                  ),
                ).then((_) => _fetchFarms());
              },
            ),
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
            'No farms found. Please create a new farm.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _createNewFarm();
              _fetchFarms();
            },
            child: const Text('Create New Farm'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_farms.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildFarmList();
    }
  }

  Future<void> _createNewFarm() async {
    String name = '';
    String location = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Farm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Farm Name'),
              onChanged: (value) => name = value.trim(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Farm Location'),
              onChanged: (value) => location = value.trim(),
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
              if (name.isEmpty || location.isEmpty) {
                _showError('Both name and location are required.');
                return;
              }

              try {
                final newFarm = {
                  'name': name,
                  'location': location,
                  'createdAt': FieldValue.serverTimestamp(),
                };

                await _firestore
                    .collection('farms')
                    .doc(_userId)
                    .collection('userFarms')
                    .add(newFarm);

                Navigator.pop(context);
                _fetchFarms();
              } catch (e) {
                debugPrint('Error creating farm: $e');
                _showError('Failed to create farm. Please try again.');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Farm'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFarm,
        child: const Icon(Icons.add),
        tooltip: 'Create Farm',
      ),
    );
  }
}
