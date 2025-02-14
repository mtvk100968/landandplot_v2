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
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  late PlacesService _placesService;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showSuggestions = false;

  // GlobalKey to measure the TextField's size
  final GlobalKey _textFieldKey = GlobalKey();
  double _textFieldHeight = 0;

  @override
  void initState() {
    super.initState();
    _placesService =
        PlacesService(apiKey: 'AIzaSyC9TbKldN2qRj91FxHl1KC3r7KjUlBXOSk');
    // Wait for the first frame to get TextField size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTextField();
    });
  }

  void _measureTextField() {
    final RenderBox? renderBox =
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

  void _onChanged(String value) {
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

  void _insertOverlay() {
    _removeOverlay();
    if (!_showSuggestions) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 16, // aligns with the search bar's horizontal padding
          width: MediaQuery.of(context).size.width - 32,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            // Use the measured height of the TextField
            offset: Offset(0, _textFieldHeight),
            child: _buildSuggestionsList(),
          ),
        );
      },
    );
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

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
              final placeId = suggestion['place_id'];
              final placeDetails =
                  await _placesService.getPlaceDetails(placeId);
              widget.onPlaceSelected(placeDetails);
              setState(() {
                _controller.text = suggestion['description'];
                _suggestions = [];
                _showSuggestions = false;
              });
              _removeOverlay();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _textFieldKey,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search locations...',
            prefixIcon: const Icon(Icons.search),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          onChanged: _onChanged,
        ),
      ),
    );
  }
}
