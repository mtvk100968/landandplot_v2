// lib/components/profiles/user/selling/selling_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../services/user_service.dart';
import './selling_property_card.dart';

class SellingTab extends StatefulWidget {
  final String userId;
  const SellingTab({Key? key, required this.userId}) : super(key: key);

  @override
  _SellingTabState createState() => _SellingTabState();
}

class _SellingTabState extends State<SellingTab> {
  late Future<List<Property>> _propertiesFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _userService.getSellerProperties(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
      future: _propertiesFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        final props = snapshot.data;
        if (props == null || props.isEmpty) {
          return const Center(child: Text('No properties to show'));
        }
        return ListView.builder(
          itemCount: props.length,
          itemBuilder: (ctx, i) => SellerPropertyCard(property: props[i]),
        );
      },
    );
  }
}
