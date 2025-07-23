// lib/components/profiles/user/common/edit_profile_dialog.dart
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
  State<EditProfileDialog> createState() => _EditProfileDialogState();
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
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

    try {
      // 1. Upload photo if picked
      if (_pickedImage != null) {
        photoUrl = await UserService().uploadProfileImage(
          uid: firebaseUser.uid,
          file: _pickedImage!,
        );
        // optional mirror to Auth
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      // 2. Build updated model (email only in Firestore)
      final updated = widget.user.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        photoUrl: photoUrl,
      );

      // 3. Save to Firestore
      await UserService().saveUser(updated);

      // 4. Update displayName in Auth (safe)
      if (updated.name?.isNotEmpty == true) {
        try {
          await firebaseUser.updateDisplayName(updated.name);
        } catch (_) {}
      }

      if (!mounted) return;
      debugPrint('✅ Closing dialog');
      Navigator.of(context, rootNavigator: true).pop<AppUser>(updated);
    } catch (e, st) {
      debugPrint('⚠️ submit error: $e');
      debugPrintStack(stackTrace: st);
      _showSnack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Your Profile'),
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
                    ? const Icon(Icons.camera_alt, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              enabled: widget.user.name == null || widget.user.name!.isEmpty,
              decoration: const InputDecoration(labelText: 'Name *'),
              style: TextStyle(
                color: (widget.user.name == null || widget.user.name!.isEmpty)
                    ? Colors.black
                    : Colors.grey,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+$");
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
