import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/property_service.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../components/views/property_list_view.dart';
import 'property_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  AppUser? currentUser;

  // Handle toggling favorites from FavoritesScreen
  void _onFavoriteToggle(String propertyId, bool nowFavorited) async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to manage favorites.')),
      );
      return;
    }

    try {
      if (nowFavorited) {
        await UserService().addFavoriteProperty(firebaseUser.uid, propertyId);
      } else {
        await UserService()
            .removeFavoriteProperty(firebaseUser.uid, propertyId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
    }
  }

  Future<List<Property>> _fetchFavoriteProperties(
      List<String> propertyIds) async {
    if (propertyIds.isEmpty) {
      return [];
    }
    return await PropertyService().getPropertiesByIds(propertyIds);
  }

  Future<void> _refreshFavorites() async {
    setState(() {});
  }

  // ADDED: Method to handle property taps
  void _onTapProperty(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsScreen(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: const Center(
          child: Text('You need to be logged in to view favorites.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: StreamBuilder<AppUser?>(
          stream: UserService().getUserStream(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            currentUser = userSnapshot.data;
            if (currentUser == null) {
              return const Center(child: Text('No user data available.'));
            }

            return FutureBuilder<List<Property>>(
              future:
                  _fetchFavoriteProperties(currentUser!.favoritedPropertyIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No favorites yet.'));
                } else {
                  final properties = snapshot.data!;
                  return PropertyListView(
                    properties: properties,
                    favoritedPropertyIds:
                        currentUser?.favoritedPropertyIds ?? [],
                    onFavoriteToggle: _onFavoriteToggle,
                    onTapProperty: _onTapProperty, // Pass the new callback
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
