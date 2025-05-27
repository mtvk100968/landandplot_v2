// lib/components/profiles/user/user_profile.dart
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart'; // ← for signOut()
import '../../../models/user_model.dart';
import './common/edit_profile_dialog.dart';
import 'common/user_detail_card.dart';
import 'selling/selling_tab.dart';

class UserProfile extends StatefulWidget {
  final AppUser initialUser;
  const UserProfile({Key? key, required this.initialUser}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    _tabController = TabController(length: 2, vsync: this);

    // only show setup dialog for plain “user” with no name
    if (_user.userType == 'user' && (_user.name?.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => EditProfileDialog(user: _user),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              await signOut();
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1) user details always at top
          UserDetailCard(user: _user),

          // 2) then the two tabs
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Selling'),
              Tab(text: 'Buying'),
            ],
          ),

          // 3) tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SellingTab(user: _user),
                Center(child: Text('Buying tab coming soon')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
