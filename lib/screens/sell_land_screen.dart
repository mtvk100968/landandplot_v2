import 'package:flutter/material.dart';
import 'package:landandplot/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../components/forms/sell_land/form.dart';
import '../providers/property_provider.dart';
import '../services/property_service.dart';
import '../providers/auth_provider.dart';

class SellLandScreen extends StatelessWidget {
  const SellLandScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider(),
        ),
        Provider<PropertyService>(
          create: (_) => PropertyService(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sell Land'),
        ),
        body: const SellLandForm(),
      ),
    );
  }
}
