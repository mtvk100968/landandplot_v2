import 'dart:async';

import 'package:flutter/material.dart';
import '../services/places_service.dart';

class LocationSearchBar extends StatefulWidget {
  final Function(Map<String, dynamic> place) onPlaceSelected;

  const LocationSearchBar({Key? key, required this.onPlaceSelected})
      : super(key: key);

  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  late PlacesService _placesService;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _placesService =
        PlacesService(apiKey: 'AIzaSyC9TbKldN2qRj91FxHl1KC3r7KjUlBXOSk');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        try {
          final suggestions = await _placesService.getAutocomplete(value);
          setState(() {
            _suggestions = suggestions;
          });
        } catch (e) {
          print('Error fetching autocomplete suggestions: $e');
        }
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search locations...',
            prefixIcon: const Icon(Icons.search),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.grey, // Set the border color to grey
                width: 1.0, // Set the border width to a thin line
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.grey, // Grey border for the enabled state
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.grey, // Grey border for the focused state
                width: 1.0,
              ),
            ),
          ),
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            height: 200, // Adjust as needed
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion['description']),
                  onTap: () async {
                    final placeId = suggestion['place_id'];
                    final placeDetails =
                        await _placesService.getPlaceDetails(placeId);
                    widget.onPlaceSelected(placeDetails);
                    setState(() {
                      _controller.text = suggestion['description'];
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
