// lib/components/profiles/user/common/user_detail_card.dart
import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

class UserDetailCard extends StatelessWidget {
  final AppUser user;
  const UserDetailCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child:
                  user.photoUrl == null ? Icon(Icons.person, size: 36) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber ?? '',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email ?? '',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
