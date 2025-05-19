// lib/components/profiles/user/buying/buying_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/property_service.dart';
import './buyer_proof_upload_dialog.dart';
import '../selling/selling_timeline_view.dart';

class BuyingDetailScreen extends StatefulWidget {
  final Property property;
  final Buyer buyer;
  const BuyingDetailScreen({
    Key? key,
    required this.property,
    required this.buyer,
  }) : super(key: key);

  @override
  _BuyingDetailScreenState createState() => _BuyingDetailScreenState();
}

class _BuyingDetailScreenState extends State<BuyingDetailScreen> {
  late Buyer _buyer;
  final _propService = PropertyService();
  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _buyer = widget.buyer;
  }

  Future<void> _pickVisitDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _buyer.date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (newDate != null) {
      await _propService.updateBuyerStatus(
        propertyId: widget.property.id,
        buyerPhone: _buyer.phone,
        visitDate: newDate,
      );
      setState(() => _buyer.date = newDate);
    }
  }

  Future<void> _uploadProof() async {
    final updated = await showDialog<Buyer>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BuyerProofUploadDialog(
        propertyId: widget.property.id,
        buyer: _buyer,
      ),
    );
    if (updated != null) {
      // persist the change
      await _propService.updateBuyerByBuyer(
        widget.property.id,
        widget.buyer, // old
        updated, // new
      );
      setState(() => _buyer = updated);
    }
  }

  void _openNegotiationSheet() {
    final priceCtrl =
        TextEditingController(text: _buyer.priceOffered?.toString());
    final noteCtrl = TextEditingController();
    String status =
        _buyer.status == 'visitPending' ? 'negotiating' : _buyer.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Make an Offer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Your Offer (₹)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: status,
              items: ['negotiating', 'accepted', 'rejected']
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.capitalize())))
                  .toList(),
              onChanged: (v) {
                if (v != null) status = v;
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final price = double.tryParse(priceCtrl.text);
                if (price == null) return;
                final note = noteCtrl.text.trim();
                final newNotes = [..._buyer.notes];
                if (note.isNotEmpty) newNotes.add(note);

                await _propService.updateBuyerStatus(
                  propertyId: widget.property.id,
                  buyerPhone: _buyer.phone,
                  status: status,
                  visitDate: _buyer.date,
                  priceOffered: price,
                  notes: newNotes,
                );

                setState(() {
                  _buyer.priceOffered = price;
                  _buyer.status = status;
                  _buyer.notes = newNotes;
                  _buyer.lastUpdated = DateTime.now();
                });
                Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;
    final buyer = _buyer;

    return Scaffold(
      appBar: AppBar(title: Text(prop.propertyOwner)),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Image carousel ──
          SizedBox(
            height: 200,
            child: prop.images.isNotEmpty
                ? PageView(
                    children: prop.images
                        .map((u) => Image.network(u, fit: BoxFit.cover))
                        .toList())
                : const Center(child: Text('No Images')),
          ),

          // ── Summary ──
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prop.propertyType,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Price: ₹${prop.totalPrice.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              Text('Area: ${prop.landArea}'),
              if (prop.address != null) ...[
                const SizedBox(height: 4),
                Text(prop.address!),
              ],
            ]),
          ),

          const Divider(),

          // ── Current-step UI ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Builder(builder: (_) {
              // 1) Interest step
              if (buyer.currentStep == 'Interest') {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Next: Set Visit Date',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickVisitDate,
                        child: Text(buyer.date != null
                            ? 'Change Date (${_dateFmt.format(buyer.date!)})'
                            : 'Pick a Visit Date'),
                      ),
                    ]);
              }

              // 2) Document steps
              const docSteps = [
                'DocVerify',
                'LegalCheck',
                'Agreement',
                'Registration',
                'Mutation',
                'Possession'
              ];
              if (docSteps.contains(buyer.currentStep)) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next: Upload Proof (${buyer.currentStep})',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: _uploadProof,
                          child: const Text('Upload Proof')),
                    ]);
              }

              // 3) Negotiation
              if (buyer.status == 'negotiating') {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Negotiation',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          'Your last offer: ₹${buyer.priceOffered?.toStringAsFixed(0) ?? "-"}'),
                      const SizedBox(height: 4),
                      ElevatedButton(
                          onPressed: _openNegotiationSheet,
                          child: const Text('Counter Offer')),
                    ]);
              }

              // 4) Accepted / Rejected
              if (buyer.status == 'accepted') {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('🎉 Purchase Completed',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              }
              if (buyer.status == 'rejected') {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('❌ Offer Rejected',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              }

              return const SizedBox.shrink();
            }),
          ),

          const Divider(),

          // ── History & docs ──
          ExpansionTile(
            title: const Text('History & Documents'),
            children: [SellerTimelineView(buyer: buyer)],
          ),

          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// String extension for capitalize()
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
