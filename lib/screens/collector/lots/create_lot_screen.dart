import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../recyclers/recycler_comparison_screen.dart';

class CreateLotScreen extends StatefulWidget {
  final File imageFile;
  final String materialId;
  final String materialName;
  final double weightKg;
  final double estimatedPrice;

  const CreateLotScreen({
    super.key,
    required this.imageFile,
    required this.materialId,
    required this.materialName,
    required this.weightKg,
    required this.estimatedPrice,
  });

  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final _description = TextEditingController();
  final _location = TextEditingController(text: 'Pune');
  bool _saving = false;

  @override
  void dispose() {
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<String?> _uploadPhoto(String lotId, String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('lots')
          .child(uid)
          .child('$lotId.jpg');

      await ref.putFile(widget.imageFile);
      return await ref.getDownloadURL();
    } catch (_) {
      // Photo storage can be unavailable during a prototype demo.
      return null;
    }
  }

  Future<String> _locationText() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return _location.text.trim();

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _location.text.trim();
      }

      final p = await Geolocator.getCurrentPosition();
      return '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';
    } catch (_) {
      return _location.text.trim();
    }
  }

  Future<void> _createLot() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _message('Please log in first.');
      return;
    }

    setState(() => _saving = true);

    try {
      final ref = FirebaseFirestore.instance.collection('lots').doc();
      final location = await _locationText();
      final photoUrl = await _uploadPhoto(ref.id, uid);

      await ref.set({
        'collectorId': uid,
        'materialId': widget.materialId,
        'materialName': widget.materialName,
        'description': _description.text.trim(),
        'weightKg': widget.weightKg,
        'photoUrl': photoUrl,
        'location': location,
        'estimatedPrice': widget.estimatedPrice,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecyclerComparisonScreen(
            lotId: ref.id,
            materialId: widget.materialId,
            weightKg: widget.weightKg,
          ),
        ),
      );
    } catch (e) {
      _message('Could not create lot: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Digital Lot')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(widget.imageFile, height: 180, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text('Material: ${widget.materialName}'),
          Text('Weight: ${widget.weightKg.toStringAsFixed(2)} kg'),
          Text('Estimated value: ₹${widget.estimatedPrice.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description / condition',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _location,
            decoration: const InputDecoration(
              labelText: 'Location fallback',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _createLot,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.inventory_2),
            label: const Text('Create Lot'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lot status starts as "open". The Recycler side can then read this lot and create an offer.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
