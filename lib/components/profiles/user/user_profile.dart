// lib/components/profiles/user/user_profile.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'user_profile_edit_dialog.dart';
import 'buying/buying_tab.dart';
import 'selling/selling_tab.dart';

class UserProfile extends StatefulWidget {
  final AppUser initialUser;
  const UserProfile({Key? key, required this.initialUser}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
  }

  void _updateUser(AppUser updated) {
    setState(() {
      _user = updated;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _refreshProfile() async {
    // fetch fresh user data from your service
    final fresh = await UserService().getUserById(_user.uid);
    if (fresh != null) _updateUser(fresh);
    // you could also refresh the tabs by calling their internal refresh if needed
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user.name ?? 'No Name',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (_user.email?.isNotEmpty == true)
                Text(_user.email!, style: const TextStyle(fontSize: 12)),
              if (_user.phoneNumber?.isNotEmpty == true)
                Text(_user.phoneNumber!, style: const TextStyle(fontSize: 12)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final updated = await showDialog<AppUser>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => UserProfileEditDialog(user: _user),
                );
                if (updated != null) _updateUser(updated);
              },
            ),
            TextButton(
              onPressed: () => _signOut(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Buying'),
              Tab(text: 'Selling'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshProfile,
          // TabBarView’s children each contain their own scrollable + RefreshIndicator,
          // so pull-down will bubble up to trigger this too.
          child: TabBarView(
            children: [
              BuyingTab(userId: _user.uid),
              SellingTab(userId: _user.uid),
            ],
          ),
        ),
      ),
    );
  }
}
