import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';
import './common/edit_profile_dialog.dart';
import 'common/user_detail_card.dart';
import 'selling/selling_tab.dart';
import 'buying/buying_tab.dart';

class UserProfile extends StatefulWidget {
  final AppUser initialUser;
  const UserProfile({Key? key, required this.initialUser}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late AppUser _user;
  late TabController _tabController;
  final _authService = AuthService();

  bool get _needsProfile => !_user.profileComplete;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;

    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    // Show dialog once if profile incomplete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_needsProfile) {
        final updated = await showDialog<AppUser>(
          context: context,
          barrierDismissible: false,
          builder: (_) => EditProfileDialog(user: _user),
        );
        if (updated != null && mounted) setState(() => _user = updated);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buyerId = _user.phoneNumber ?? _user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: () async => _authService.signOut(),
            child: const Text(
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
          UserDetailCard(user: _user),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Selling'),
              Tab(text: 'Buying'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SellingTab(user: _user),
                BuyingTab(userId: buyerId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
