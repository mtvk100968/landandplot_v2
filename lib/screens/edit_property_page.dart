import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditPropertyPage extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic> initialData;

  const EditPropertyPage({
    Key? key,
    required this.propertyId,
    required this.initialData,
  }) : super(key: key);

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialData['name'] ?? '';
    _ownerNameController.text = widget.initialData['ownerName'] ?? '';
  }

  Future<void> _updateProperty() async {
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId)
        .update({
      'name': _nameController.text,
      'ownerName': _ownerNameController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Property details updated!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ownerNameController,
              decoration: const InputDecoration(labelText: 'Owner Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProperty,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
