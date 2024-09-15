import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Center(
        child: _currentUser == null
            ? _buildSignInPrompt() // Show sign-in prompt if not logged in
            : _buildFavoritesContent(), // Show favorite properties if logged in
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Sign in to add your favorite properties here!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Navigate to the ProfileScreen using named route
            Navigator.pushNamed(context, '/profile');
          },
          child: const Text('Sign in now'),
        ),
      ],
    );
  }

  Widget _buildFavoritesContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Find all your saved properties here!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        // Add more widgets here that represent the user's favorite properties
      ],
    );
  }
}
