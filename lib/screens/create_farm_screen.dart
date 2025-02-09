import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateFarmScreen extends StatefulWidget {
  const CreateFarmScreen({super.key});

  @override
  State<CreateFarmScreen> createState() => _CreateFarmScreenState();
}

class _CreateFarmScreenState extends State<CreateFarmScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveFarm() async {
    try {
      setState(() {
        _isSaving = true;
      });

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in.');

      final userId = user.uid;
      final farmId = _firestore.collection('farms').doc().id;
      final createdAt = DateTime.now().toIso8601String();

      final farmData = {
        'farmId': farmId,
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'createdAt': createdAt,
        'expenses': [],
        'feedTracking': [],
      };

      await _firestore
          .collection('farms')
          .doc(userId)
          .collection('userFarms')
          .doc(farmId)
          .set(farmData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm created successfully!')),
      );

      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Farm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Farm Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Farm Location'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveFarm,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Farm'),
            ),
          ],
        ),
      ),
    );
  }
}
