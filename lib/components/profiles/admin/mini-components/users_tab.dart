import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../services/admin_service.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({Key? key}) : super(key: key);

  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final _searchCtrl = TextEditingController();
  String _field = 'Name';
  List<AppUser> _list = [];
  bool _loading = true;

  final _fields = ['Name', 'Phone'];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _list = await AdminService()
        .searchUsers(query: _searchCtrl.text, field: _field);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext ctx) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search users…',
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
        ]),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _list.length,
                itemBuilder: (_, i) {
                  final u = _list[i];
                  return ListTile(
                    title: Text(u.name ?? ''),
                    subtitle: Text(u.phoneNumber ?? ''),
                  );
                },
              ),
      ),
    ]);
  }
}
