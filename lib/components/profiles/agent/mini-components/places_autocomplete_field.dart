import 'package:flutter/material.dart';
import '../../../../services/places_service.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final PlacesService placesService;
  final void Function(String description) onSelected;

  const PlaceAutocompleteField({
    Key? key,
    required this.placesService,
    required this.onSelected,
  }) : super(key: key);

  @override
  _PlaceAutocompleteFieldState createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  final _controller = TextEditingController();
  List<dynamic> _suggestions = [];

  void _onChanged(String input) async {
    if (input.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    try {
      final results = await widget.placesService.getAutocomplete(input);
      setState(() => _suggestions = results);
    } catch (e) {
      // handle or ignore
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Add service area',
          ),
          onChanged: _onChanged,
        ),
        ..._suggestions.map((pred) {
          final desc = pred['description'] as String;
          return ListTile(
            title: Text(desc),
            onTap: () {
              widget.onSelected(desc);
              _controller.clear();
              setState(() => _suggestions = []);
            },
          );
        }).toList(),
      ],
    );
  }
}
