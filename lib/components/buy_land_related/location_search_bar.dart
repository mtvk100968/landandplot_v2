// lib/components/location_search_bar.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/places_service.dart';

/// A [LocationSearchBar] that lets the user type multiple places.
/// Each selected place becomes a chip, and the user can remove chips.
class LocationSearchBar extends StatefulWidget {
  final Function(Map<String, dynamic> place) onPlaceSelected;

  const LocationSearchBar({
    Key? key,
    required this.onPlaceSelected,
  }) : super(key: key);

  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController _controller = TextEditingController();
  // Will store suggestions coming from the Places API
  List<dynamic> _suggestions = [];

  // A list of all chips (each is a Map storing description, place_id, and more)
  List<Map<String, dynamic>> _chipPlaces = [];

  late PlacesService _placesService;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showSuggestions = false;

  // For measuring where to place the overlay
  final GlobalKey _textFieldKey = GlobalKey();
  double _textFieldHeight = 0;

  @override
  void initState() {
    super.initState();
    // Initialize PlacesService with your actual API key
    _placesService =
        PlacesService(apiKey: 'AIzaSyC9TbKldN2qRj91FxHl1KC3r7KjUlBXOSk');

    // Measure the text field after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTextField();
    });
  }

  /// Measures the text field so we know how far to offset the suggestion overlay.
  void _measureTextField() {
    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _textFieldHeight = renderBox.size.height;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  /// Called whenever the user types into the text field.
  void _onChanged(String value) {
    // Debounce to avoid firing too many requests
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        try {
          final suggestions = await _placesService.getAutocomplete(value);
          setState(() {
            _suggestions = suggestions;
            _showSuggestions = suggestions.isNotEmpty;
          });
          _insertOverlay();
        } catch (e) {
          print('Error fetching autocomplete suggestions: $e');
        }
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        _removeOverlay();
      }
    });
  }

  /// Shows the autocomplete suggestions overlay.
  void _insertOverlay() {
    _removeOverlay();
    if (!_showSuggestions) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 16, // same horizontal padding as below
          width: MediaQuery.of(context).size.width - 32,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, _textFieldHeight),
            child: _buildSuggestionsList(),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Removes the suggestions overlay (if any).
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Builds the material list of suggestions beneath the text field.
  Widget _buildSuggestionsList() {
    return Material(
      elevation: 2,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(suggestion['description']),
            onTap: () async {
              // Get detailed info from place_id
              final placeId = suggestion['place_id'];
              final placeDetails =
                  await _placesService.getPlaceDetails(placeId);

              // Split the suggestion to get just the first chunk (e.g. store name, apartment name, etc.)
              final shortLabel =
                  suggestion['description'].split(',').first.trim();

              // Construct a map to store in the chip
              final newChip = {
                'description': shortLabel, // e.g. "Apartment XYZ"
                'place_id': placeId, // useful for lat/long lookups
                'fullDetails':
                    placeDetails, // entire place details if needed later
              };

              // Add a chip for that place
              _addChip(newChip);
            },
          );
        },
      ),
    );
  }

  /// Adds a new place to our chip list, calls parent callback, clears text.
  void _addChip(Map<String, dynamic> newPlace) {
    setState(() {
      _chipPlaces.add(newPlace);
    });
    // If you want to inform the parent each time a place is selected:
    widget.onPlaceSelected(newPlace['fullDetails'] ?? newPlace);

    // Clear text and suggestions
    _controller.clear();
    _suggestions = [];
    _showSuggestions = false;
    _removeOverlay();
  }

  /// Removes a chip at the given index.
  void _removeChip(int index) {
    setState(() {
      _chipPlaces.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _textFieldKey,
        // Outline for the row of chips + text field
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Render existing chips
              for (int i = 0; i < _chipPlaces.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Chip(
                    label: Text(_chipPlaces[i]['description']),
                    onDeleted: () => _removeChip(i),
                  ),
                ),
              // The text field for new searches
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search locations...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
