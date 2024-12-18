import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:landandplot/screens/property_details_display_page.dart';
import 'package:provider/provider.dart';
import '../components/views/property_card.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // void toggleFavorite(Property property) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     AppUser? appUser = await _userService.getUserById(user.uid);
  //     if (appUser != null) {
  //       bool isAlreadyFavorited = appUser.favoritedPropertyIds.contains(property.id);
  //
  //       if (isAlreadyFavorited) {
  //         await _userService.removeFavoriteProperty(user.uid, property.id);
  //       } else {
  //         await _userService.addFavoriteProperty(user.uid, property.id);
  //       }
  //
  //       // Reload favorite properties immediately
  //       setState(() {
  //         _favoritePropertiesFuture = _loadFavoriteProperties();
  //       });
  //     }
  //   }
  // }

  Future<void> toggleFavorite(Property property) async {
    final userId = _currentUser!.uid;
    final propertyId = property.id;

    try {
      await _userService.toggleFavorite(userId, propertyId);

      // Fetch the updated user data
      AppUser? updatedUser = await _userService.getUserById(userId);
      if (updatedUser != null) {
        // Update the UserProvider
        Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
      }

      // Reload favorite properties immediately
      setState(() {
        _favoritePropertiesFuture = _loadFavoriteProperties();
      });
    } catch (e) {
      print('Error in toggleFavorite: $e');
      // Handle the error appropriately
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.data() == null) {
          return Text(
            'No favorite properties found!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          );
        } else {
          // Fetch favorited property IDs from the user's document
          List<dynamic> favoritedPropertyIds =
              snapshot.data!.get('favoritedPropertyIds') ?? [];

          if (favoritedPropertyIds.isEmpty) {
            return Text(
              'No favorite properties found!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            );
          }

          return FutureBuilder<List<Property>>(
            future: _propertyService.getPropertiesByIds(
                favoritedPropertyIds.cast<String>()),
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
                      onFavoriteToggle: toggleFavorite, // Pass the function directly
                      isFavorited: true,
                      onImageTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailsDisplayPage(
                              property: favoriteProperties[index], // Correct reference
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
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