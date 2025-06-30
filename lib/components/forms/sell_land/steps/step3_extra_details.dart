// lib/components/forms/sell_land/steps/step_extra_details.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';

class Step3ExtraDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step3ExtraDetails({Key? key, required this.formKey})
      : super(key: key);

  @override
  _Step3ExtraDetailsState createState() => _Step3ExtraDetailsState();
}

class _Step3ExtraDetailsState extends State<Step3ExtraDetails> {
  late TextEditingController _lengthController;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<PropertyProvider>(context, listen: false);
    // initialize your controller from provider
    _lengthController = TextEditingController(text: p.lengthFacing);
  }

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PropertyProvider>(context);

    return SingleChildScrollView(
      // this makes the whole thing scrollable once the keyboard is up
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Zone ─────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: p.zone,
              decoration: const InputDecoration(labelText: 'Zone'),
              items: [
                "Residential Use Zone (R1)",
                "Residential Use Zone (R2)",
                "Residential Use Zone (R3)",
                "Residential Use Zone (R4)",
                "Peri-Urban Use Zone",
                "Commercial Use Zone",
                "Manufacturing Use Zone",
                "Conservation (Agriculture) Use Zone",
              ]
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
              onChanged: (nz) {
                if (nz != null) p.setZone(nz);
              },
            ),

            const SizedBox(height: 16),

            // ─── Road Access ─────────────────────────────────────
            DropdownButtonFormField<String>(
              value: p.roadAccess,
              decoration: const InputDecoration(labelText: 'Road Access'),
              items: ['Yes', 'No']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (ra) {
                if (ra != null) p.setRoadAccess(ra);
              },
            ),

            if (p.roadAccess == 'Yes') ...[
              const SizedBox(height: 16),

              // Road Type
              DropdownButtonFormField<String>(
                value: p.roadType,
                decoration: const InputDecoration(labelText: 'Road Type'),
                items: [
                  "National Highway",
                  "State Highway",
                  "District Road",
                  "Rural Blacktop Road",
                  "Expressway",
                  "Matti Road",
                  "Murram Road",
                  "Kankara Road",
                ]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (rt) {
                  if (rt != null) p.setRoadType(rt);
                },
              ),

              const SizedBox(height: 16),

              // Road Width
              DropdownButtonFormField<double>(
                value: p.roadWidth,
                decoration:
                const InputDecoration(labelText: 'Road Width (ft)'),
                items: [15, 20, 25, 33, 40, 50, 60, 80, 100]
                    .map((w) =>
                    DropdownMenuItem(value: w.toDouble(), child: Text('$w ft')))
                    .toList()
                  ..add(DropdownMenuItem(value: 1000, child: Text('100+ ft'))),
                onChanged: (rw) {
                  if (rw != null) p.setRoadWidth(rw);
                },
              ),
            ],

            const SizedBox(height: 16),

            // ─── Length Facing ─────────────────────────────────────
            TextFormField(
              controller: _lengthController,
              decoration: const InputDecoration(labelText: 'Length Facing (ft)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => p.setLengthFacing(v),
            ),

            const SizedBox(height: 16),

            // ─── Land Facing ────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: p.landFacing,
              decoration: const InputDecoration(labelText: 'Land Facing'),
              items: ['East', 'West', 'North', 'South']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (lf) {
                if (lf != null) p.setLandFacing(lf);
              },
            ),

            const SizedBox(height: 16),

            // ─── Nala Nearby ───────────────────────────────────────
            DropdownButtonFormField<String>(
              value: p.nala,
              decoration:
              const InputDecoration(labelText: 'Nala (Drain) Nearby?'),
              items: ['Yes', 'No']
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (nl) {
                if (nl != null) p.setNala(nl);
              },
            ),

            // add some bottom padding so you can scroll past the last field
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
