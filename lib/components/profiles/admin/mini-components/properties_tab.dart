// lib/components/profiles/admin/mini-components/properties_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../services/admin_service.dart';
import './property_details_screen.dart';

class PropertiesTab extends StatefulWidget {
  const PropertiesTab({Key? key}) : super(key: key);

  @override
  _PropertiesTabState createState() => _PropertiesTabState();
}

class _PropertiesTabState extends State<PropertiesTab> {
  final _searchCtrl = TextEditingController();
  bool _assignedOnly = true;
  List<Property> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _list = await AdminService().searchProperties(
      query: _searchCtrl.text,
      assignedOnly: _assignedOnly,
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Search properties…',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => _reload(),
          ),
        ),

        // Assigned / Unassigned toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Assigned'),
              selected: _assignedOnly,
              onSelected: (v) {
                setState(() {
                  _assignedOnly = true;
                });
                _reload();
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unassigned'),
              selected: !_assignedOnly,
              onSelected: (v) {
                setState(() {
                  _assignedOnly = false;
                });
                _reload();
              },
            ),
          ],
        ),

        const SizedBox(height: 8),

        // List or loading spinner
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, i) {
                    final p = _list[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(p.address ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: p.isAssigned ? 'Assigned' : 'Unassigned',
                            child: Text(p.isAssigned ? 'A' : 'U'),
                          ),
                          const SizedBox(width: 6),
                          Tooltip(
                            message: p.adminApproved
                                ? 'Approved'
                                : 'Pending Approval',
                            child: Text(p.adminApproved ? '✔' : '⏳'),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_right),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PropertyDetailScreen(propertyId: p.id),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // onTap in PropertiesTab:
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailScreen(propertyId: p.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
