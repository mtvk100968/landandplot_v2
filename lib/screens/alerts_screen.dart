// lib/components/profiles/user/alerts_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  final _notifService = NotificationService();
  final _dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

  Future<void> _refreshAlerts() async {
    // No-op: notifications are delivered via stream.
    setState(() {});
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: StreamBuilder<List<AppNotification>>(
          stream: _notifService.streamForUser(_userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'Failed to load alerts.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: _refreshAlerts,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              );
            }
            final notes = snapshot.data ?? [];
            if (notes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.notifications_off,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No alerts',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (ctx, i) {
                final n = notes[i];
                return ListTile(
                  title: Text(n.message),
                  subtitle: Text(_dateFmt.format(n.timestamp)),
                  trailing: n.read
                      ? null
                      : const Icon(Icons.circle, size: 12, color: Colors.blue),
                  onTap: () {
                    if (!n.read) {
                      _notifService.markAsRead(n.id);
                    }
                    // Optionally navigate based on n.type
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
