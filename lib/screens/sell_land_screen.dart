import 'package:flutter/material.dart';
import 'package:landandplot/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../components/forms/sell_land/form.dart';
import '../providers/property_provider.dart';
import '../services/property_service.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider

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
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isSignedIn) {
              return _buildSignInPrompt(context);
            }
            return const SellLandForm();
          },
        ),
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'In order to post a property, you must sign in first.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Profile Screen where user can sign in
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: const Text('Click here to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
