import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../../services/places_service.dart';

class AgentProfileSetupDialog extends StatefulWidget {
  final AppUser user;
  const AgentProfileSetupDialog({Key? key, required this.user})
      : super(key: key);

  @override
  State<AgentProfileSetupDialog> createState() =>
      _AgentProfileSetupDialogState();
}

class _AgentProfileSetupDialogState extends State<AgentProfileSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _areaController = TextEditingController();
  final List<String> _areas = [];
  final PlacesService _placesService =
      PlacesService(apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!);

  List<dynamic> _suggestions = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name ?? '';
    _emailController.text = widget.user.email ?? '';
  }

  void _onAreaChanged(String input) async {
    if (input.isEmpty) return;
    try {
      final suggestions = await _placesService.getAutocomplete(input);
      setState(() => _suggestions = suggestions);
    } catch (e) {
      setState(() => _suggestions = []);
    }
  }

  void _addArea(String area) {
    final firstWord = area.split(',').first.trim();
    if (!_areas.contains(firstWord)) {
      setState(() => _areas.add(firstWord));
    }
    _areaController.clear();
    _suggestions = [];
  }

  void _removeArea(String area) {
    setState(() => _areas.remove(area));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      agentAreas: _areas,
    );

    await UserService().updateUser(updatedUser);
    Navigator.of(context).pop(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complete Your Profile',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Name required'
                      : null,
                  onChanged: (val) {
                    final capitalized = val
                        .split(' ')
                        .map((word) => word.isNotEmpty
                            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                            : '')
                        .join(' ');
                    if (capitalized != val) {
                      _nameController.value = TextEditingValue(
                        text: capitalized,
                        selection:
                            TextSelection.collapsed(offset: capitalized.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null ||
                          !RegExp(r"^[\w-.]+@[\w-]+\.[a-z]{2,4}").hasMatch(val)
                      ? 'Valid email required'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Service Areas'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _areaController,
                  decoration:
                      const InputDecoration(hintText: 'Type to search area'),
                  onChanged: _onAreaChanged,
                ),
                ..._suggestions.map((s) => ListTile(
                      title: Text(s['description']),
                      onTap: () => _addArea(s['description']),
                    )),
                Wrap(
                  spacing: 8,
                  children: _areas
                      .map((area) => Chip(
                            label: Text(area),
                            onDeleted: () => _removeArea(area),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
