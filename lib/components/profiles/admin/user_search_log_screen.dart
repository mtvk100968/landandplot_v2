import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSearchLogScreen extends StatelessWidget {
  const UserSearchLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Search Logs')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_search_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No search logs yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final log = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('${log['area']} - ${log['propertyType']}'),
                subtitle: Text('User: ${log['phone']}'),
                trailing: Text(
                  log['timestamp'] != null
                      ? (log['timestamp'] as Timestamp).toDate().toString()
                      : '—',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
