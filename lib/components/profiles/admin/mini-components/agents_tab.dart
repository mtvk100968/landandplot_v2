import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../services/admin_service.dart';
import './agent_details_screen.dart';

class AgentsTab extends StatefulWidget {
  const AgentsTab({Key? key}) : super(key: key);

  @override
  _AgentsTabState createState() => _AgentsTabState();
}

class _AgentsTabState extends State<AgentsTab> {
  final _searchCtrl = TextEditingController();
  String _field = 'Name';
  List<AppUser> _list = [];
  bool _loading = true;

  final _fields = ['Name', 'Phone', 'Areas'];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _list = await AdminService()
        .searchAgents(query: _searchCtrl.text, field: _field);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search agents…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => _reload(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _field,
                items: _fields
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  _field = v;
                  _reload();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, i) {
                    final a = _list[i];
                    return ListTile(
                      title: Text(a.name ?? ''),
                      subtitle: Text(a.phoneNumber ?? ''),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgentDetailScreen(
                              agentUid: a.uid, // ← pass the UID
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
