// lib/components/profiles/user/user_profile_edit_dialog.dart

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

class UserProfileEditDialog extends StatefulWidget {
  final AppUser user;
  const UserProfileEditDialog({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileEditDialogState createState() => _UserProfileEditDialogState();
}

class _UserProfileEditDialogState extends State<UserProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    await UserService().updateUser(updatedUser);
    Navigator.of(context).pop(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val != null &&
                            RegExp(r"^[\w-.]+@[\w-]+\.[a-z]{2,4}").hasMatch(val)
                        ? null
                        : 'Enter a valid email',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().length < 6
                        ? 'Enter a valid phone'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _isSaving
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
