import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../components/cards/property_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  User? _currentUser;
  final UserService _userService = UserService();
  final PropertyService _propertyService = PropertyService();
  Future<List<Property>>? _favoritePropertiesFuture;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _favoritePropertiesFuture = _loadFavoriteProperties();
    }
  }

  Future<List<Property>> _loadFavoriteProperties() async {
    AppUser? appUser = await _userService.getUserById(_currentUser!.uid);
    if (appUser != null && appUser.favoritedPropertyIds.isNotEmpty) {
      List<Property> favoriteProperties = await _propertyService
          .getPropertiesByIds(appUser.favoritedPropertyIds);
      return favoriteProperties;
    } else {
      return [];
    }
  }

  void toggleFavorite(Property property) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      AppUser? appUser = await _userService.getUserById(user.uid);
      if (appUser != null) {
        bool isAlreadyFavorited = appUser.favoritedPropertyIds.contains(property.id);

        if (isAlreadyFavorited) {
          await _userService.removeFavoriteProperty(user.uid, property.id);
        } else {
          await _userService.addFavoriteProperty(user.uid, property.id);
        }

        setState(() {
          _favoritePropertiesFuture = _loadFavoriteProperties();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Center(
        child: _currentUser == null
            ? _buildSignInPrompt()
            : _buildFavoritesContent(),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return FutureBuilder<List<Property>>(
      future: _favoritePropertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'No favorite properties found!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          );
        } else {
          List<Property> favoriteProperties = snapshot.data!;
          return ListView.builder(
            itemCount: favoriteProperties.length,
            itemBuilder: (context, index) {
              return PropertyCard(
                property: favoriteProperties[index],
                onFavoriteToggle: toggleFavorite,
                isFavorited: true,
              );
            },
          );
        }
      },
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
            Navigator.pushNamed(context, '/profile');
          },
          child: const Text('Sign in now'),
        ),
      ],
    );
  }
}