import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/property_service.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../components/buy_land_related/views/property_list_view.dart';
import 'property_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {

  Future<void> onFavoriteToggle(String propertyId, bool nowFavorited) async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage favorites.')),
      );
      return;
    }
    try {
      if (nowFavorited) {
        await UserService().addFavoriteProperty(fbUser.uid, propertyId);
      } else {
        await UserService().removeFavoriteProperty(fbUser.uid, propertyId);
      }
      // rebuild after change:
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t update favorite: $e')),
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

  // Handle property taps
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final firebaseUser = authSnapshot.data;
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
                final appUser = userSnapshot.data;
                if (appUser == null) {
                  return const Center(child: Text('No user data available.'));
                }
                return FutureBuilder<List<Property>>(
                  future: _fetchFavoriteProperties(
                      appUser.favoritedPropertyIds),
                  builder: (context, propertySnapshot) {
                    if (propertySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (propertySnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${propertySnapshot.error}'));
                    } else if (!propertySnapshot.hasData ||
                        propertySnapshot.data!.isEmpty) {
                      return const Center(child: Text('No favorites yet.'));
                    }

                      final properties = propertySnapshot.data!;
                      if (properties.isEmpty) {
                        return const Center(child: Text('No favorites yet.'));
                      }
                      return PropertyListView(
                          properties: properties,
                          favoritedPropertyIds: appUser.favoritedPropertyIds,
                          onFavoriteToggle: onFavoriteToggle,
                          onTapProperty: _onTapProperty,
                        );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
