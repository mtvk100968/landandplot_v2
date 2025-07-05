import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchAlertsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Alerts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('search_alerts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No alerts yet"));
          }
          
          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final area = data['area'] ?? 'Unknown Area';
              final type = data['propertyType'] ?? 'Unknown Type';
              final phone = data['phone'] ?? '—';
              final timestamp = data['timestamp'] as Timestamp?;

              return ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('$area - $type'),
                subtitle: Text('User: $phone'),
                trailing: Text(
                  timestamp != null
                      ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                      : '—',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
