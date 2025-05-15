// lib/components/profiles/admin/mini-components/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;
  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  Future<AppUser?> _fetchUser() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromDocument(doc.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: FutureBuilder<AppUser?>(
        future: _fetchUser(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          final user = snap.data;
          if (user == null) return const Center(child: Text('User not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                  title: const Text('Name'), subtitle: Text(user.name ?? '-')),
              ListTile(
                  title: const Text('Phone'),
                  subtitle: Text(user.phoneNumber ?? '-')),
              ListTile(
                  title: const Text('Email'),
                  subtitle: Text(user.email ?? '-')),
              ListTile(
                  title: const Text('User Type'),
                  subtitle: Text(user.userType)),
              // add more fields here if needed...
              if (user.postedPropertyIds.isNotEmpty) ...[
                Divider(),
                Text('Posted Properties',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...user.postedPropertyIds.map((pid) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: navigate to property detail
                        },
                        child: Text(pid,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
