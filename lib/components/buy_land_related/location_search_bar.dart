// lib/components/location_search_bar.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/places_service.dart';

/// A [LocationSearchBar] that lets the user type multiple places.
/// Each selected place becomes a chip, and the user can remove chips.
class LocationSearchBar extends StatefulWidget {
  final Map<String,dynamic>? initialPlace;    // ← new
  final Function(Map<String, dynamic> place) onPlaceSelected;

  const LocationSearchBar({Key? key,
    this.initialPlace,
    required this.onPlaceSelected})
      : super(key: key);

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
  Map<String, dynamic>? _currentPlace;

  @override
  void initState() {
    super.initState();
    // Initialize PlacesService with your actual API key
    _placesService =
        PlacesService(apiKey: 'AIzaSyC9TbKldN2qRj91FxHl1KC3r7KjUlBXOSk');
    if (widget.initialPlace != null) {
      // pre‐fill your text field and stash the place
      _controller.text = widget.initialPlace!['description'] ?? '';
      _currentPlace = widget.initialPlace;
    }
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
  void _removeChip(int index) async {
    setState(() {
      _chipPlaces.removeAt(index);
    });

    print("Updated _chipPlaces list: $_chipPlaces"); // Debugging log

    if (_chipPlaces.isNotEmpty) {
      // Set to the last remaining chip
      print("Setting location to last remaining chip: ${_chipPlaces.last}");
      widget
          .onPlaceSelected(_chipPlaces.last['fullDetails'] ?? _chipPlaces.last);
    } else {
      // Fetch current location when no locations are selected
      print("No locations selected, resetting to current location");

      LatLng? currentLocation = await getCurrentLocation();

      if (currentLocation != null) {
        widget.onPlaceSelected({
          'description': 'Current Location',
          'geometry': {
            // ✅ Provide correct structure
            'location': {
              'lat': currentLocation.latitude,
              'lng': currentLocation.longitude,
            }
          }
        });
      } else {
        print("⚠️ Unable to get user location.");
      }
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("⚠️ Location permission denied.");
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("❌ Error getting current location: $e");
      return null;
    }
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
                    padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () => _removeChip(i), // ✅ Correct index passed
                  ),
                ),
              // The text field for new searches
              SizedBox(
                width: 200,
                height: 36, // 👈 Add a height here to limit it
                child: TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  style: const TextStyle(fontSize: 14), // smaller font
                  decoration: const InputDecoration(
                    hintText: 'Search locations...',
                    isDense: true, // 👈 Makes the field compact
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
