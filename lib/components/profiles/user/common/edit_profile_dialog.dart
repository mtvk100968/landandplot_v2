import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class EditProfileDialog extends StatefulWidget {
  final AppUser user;
  const EditProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  File? _pickedImage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.user.name ?? '';
    _emailCtrl.text = widget.user.email ?? '';
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final firebaseUser = FirebaseAuth.instance.currentUser!;
    String? photoUrl = widget.user.photoUrl;
    if (_pickedImage != null) {
      // upload to storage and get URL
      photoUrl = await UserService().uploadProfileImage(
        uid: firebaseUser.uid,
        file: _pickedImage!,
      );
      // also update FirebaseAuth profile
      await firebaseUser.updatePhotoURL(photoUrl);
    }

    final updated = widget.user.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      // you may need to add photoUrl field to your AppUser
    );

    await UserService().saveUser(updated);

    // Update FirebaseAuth displayName/email
    await firebaseUser.updateDisplayName(updated.name);
    if (updated.email != null) {
      await firebaseUser.updateEmail(updated.email!);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complete Your Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (widget.user.photoUrl != null
                        ? NetworkImage(widget.user.photoUrl!) as ImageProvider
                        : null),
                child: _pickedImage == null && widget.user.photoUrl == null
                    ? Icon(Icons.camera_alt, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Name *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email (optional)'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final emailRegex =
                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@"
                          r"[a-zA-Z0-9]+\.[a-zA-Z]+");
                  return emailRegex.hasMatch(v) ? null : 'Invalid email';
                }
                return null;
              },
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Save'),
        ),
      ],
    );
  }
}
