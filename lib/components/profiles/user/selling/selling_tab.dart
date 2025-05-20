import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/property_model.dart';
import '../../../../services/user_service.dart';
import './seller_property_card.dart';

class SellingTab extends StatefulWidget {
  final String userId;
  const SellingTab({Key? key, required this.userId}) : super(key: key);

  @override
  _SellingTabState createState() => _SellingTabState();
}

class _SellingTabState extends State<SellingTab> {
  late Future<List<Property>> _propsFuture;
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _propsFuture = UserService().getSellerProperties(widget.userId);
      _lastRefresh = DateTime.now();
    });
  }

  Future<void> _refresh() async {
    _loadProperties();
    await _propsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _lastRefresh == null
        ? '—'
        : DateFormat('hh:mm a').format(_lastRefresh!);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Property>>(
        future: _propsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    'Oops, something went wrong.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            );
          }

          final props = snap.data ?? [];
          if (props.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 48),
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'No properties to show',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            );
          }

          // 1) Finding buyers
          final finding = props
              .where((p) =>
                  p.stage == 'findingAgents' || p.stage == 'findingBuyers')
              .toList();

          // 2) Sale in progress
          final inProgress =
              props.where((p) => p.stage == 'saleInProgress').toList();

          // 3) Sold (final)
          final sold = props.where((p) => p.stage == 'sold').toList();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // timestamp
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Last updated: $timeText',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),

              if (finding.isNotEmpty) ...[
                const SectionHeader('Finding Buyers'),
                for (var p in finding) SellerPropertyCard(property: p),
              ],

              if (inProgress.isNotEmpty) ...[
                const SectionHeader('Sale In Progress'),
                for (var p in inProgress) SellerPropertyCard(property: p),
              ],

              if (sold.isNotEmpty) ...[
                const SectionHeader('Sold'),
                for (var p in sold) SellerPropertyCard(property: p),
              ],
            ],
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
}
