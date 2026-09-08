import 'dart:io';

import 'package:flutter/material.dart';

import 'demo_material_classifier.dart';
import '../pricing/price_estimate_screen.dart';

class MaterialClassificationScreen extends StatefulWidget {
  final File imageFile;

  const MaterialClassificationScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<MaterialClassificationScreen> createState() =>
      _MaterialClassificationScreenState();
}

class _MaterialClassificationScreenState
    extends State<MaterialClassificationScreen> {
  final _classifier = DemoMaterialClassifier();
  ClassificationResult? _result;
  String _selectedId = 'pcb';
  String _selectedName = 'PCB';

  static const materials = <Map<String, String>>[
    {'id': 'pcb', 'name': 'PCB'},
    {'id': 'cable', 'name': 'Cable'},
    {'id': 'battery', 'name': 'Battery'},
    {'id': 'lcd', 'name': 'LCD Panel'},
    {'id': 'motor', 'name': 'Motor'},
    {'id': 'crt', 'name': 'CRT'},
    {'id': 'magnet', 'name': 'Magnet Assembly'},
    {'id': 'plastic', 'name': 'Mixed Plastic'},
  ];

  @override
  void initState() {
    super.initState();
    _runClassification();
  }

  Future<void> _runClassification() async {
    final result = await _classifier.classify(widget.imageFile);
    if (!mounted) return;

    setState(() {
      _result = result;
      _selectedId = result.materialId;
      _selectedName = result.materialName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Material Classification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              widget.imageFile,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          if (result == null)
            const Center(child: CircularProgressIndicator())
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: Text('Detected: ${result.materialName}'),
                subtitle: Text(
                  'Demo classifier confidence: ${(result.confidence * 100).round()}%',
                ),
              ),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedId,
            decoration: const InputDecoration(
              labelText: 'Confirm / change material',
              border: OutlineInputBorder(),
            ),
            items: materials
                .map(
                  (m) => DropdownMenuItem(
                    value: m['id'],
                    child: Text(m['name']!),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              final item = materials.firstWhere((m) => m['id'] == value);
              setState(() {
                _selectedId = value;
                _selectedName = item['name']!;
              });
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PriceEstimateScreen(
                    imageFile: widget.imageFile,
                    materialId: _selectedId,
                    materialName: _selectedName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Prototype ML note: classification is replaceable with a trained '
            'on-device TFLite model once a labelled field dataset is available.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
