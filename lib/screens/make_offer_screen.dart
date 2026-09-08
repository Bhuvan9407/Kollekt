import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/models/lot_model.dart';
import '../data/repositories/recycler_repository.dart';

class MakeOfferScreen extends StatefulWidget {
  final LotModel lot;

  const MakeOfferScreen({
    super.key,
    required this.lot,
  });

  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  final RecyclerRepository _repository = RecyclerRepository();

  bool _pickupAvailable = true;
  bool _submitting = false;

  double get _totalOffer {
    final price = double.tryParse(_priceController.text) ?? 0;
    return price * widget.lot.weightKg;
  }

  @override
  void initState() {
    super.initState();

    _priceController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get the currently authenticated Firebase user.
    final user = FirebaseAuth.instance.currentUser;

    // Do not use a hard-coded demo Recycler ID.
    if (user == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in as a recycler before submitting an offer.',
          ),
        ),
      );

      return;
    }

    final pricePerKg = double.parse(_priceController.text);

    setState(() {
      _submitting = true;
    });

    try {
      await _repository.createOffer(
        lotId: widget.lot.lotId,
        recyclerId: user.uid,
        offeredPricePerKg: pricePerKg,
        totalOffer: _totalOffer,
        pickupAvailable: _pickupAvailable,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer submitted successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit offer: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Offer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lot.materialName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.lot.weightKg.toStringAsFixed(1)} kg • '
                          '${widget.lot.location}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lot ID: ${widget.lot.lotId}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your Offer',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price per kg',
                hintText: 'Example: 440',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a price per kg';
                }

                final price = double.tryParse(value);

                if (price == null || price <= 0) {
                  return 'Enter a valid positive price';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Weight'),
                        ),
                        Text(
                          '${widget.lot.weightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Price per kg'),
                        ),
                        Text(
                          '₹${double.tryParse(_priceController.text)?.toStringAsFixed(0) ?? '0'}',
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Offer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '₹${_totalOffer.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: SwitchListTile(
                title: const Text(
                  'Pickup available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Can the recycler collect this lot?',
                ),
                value: _pickupAvailable,
                onChanged: _submitting
                    ? null
                    : (value) {
                  setState(() {
                    _pickupAvailable = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submitOffer,
                icon: _submitting
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send),
                label: Text(
                  _submitting ? 'Submitting...' : 'Submit Offer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}