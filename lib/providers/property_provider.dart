import 'package:flutter/material.dart';
import '../models/property_model.dart';
import 'dart:io';
import '../data/districts_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import convert for JSON decoding
import 'dart:developer' as developer;

class PropertyProvider with ChangeNotifier {
  // Step 1: Basic Details
  String _phoneNumber = '';
  String _name = '';
  String _propertyOwnerName = '';
  String _propertyType = 'plot'; // Default value

  // Step 2: Property Details
  double _area = 0.0;
  double _pricePerUnit = 0.0;
  double _totalPrice = 0.0;
  String _surveyNumber = '';
  List<String> _plotNumbers = [];

  // Step 3: Address Details
  String? _district;
  String? _mandal;
  String _village = '';
  String _pincode = '';
  String _state = '';
  String _city = '';

  // Step 4: Map Location
  double _latitude = 17.385044; // Default to Hyderabad latitude
  double _longitude = 78.486671; // Default to Hyderabad longitude

  // Additional Fields
  String _roadAccess = ''; // e.g., "Yes/No"
  String _roadType = ''; // e.g., "Paved", "Gravel", "Dirt"
  double _roadWidth = 0.0; // in meters
  String _landFacing = ''; // e.g., "North", "South", etc.

  // Step 5: Media Upload
  List<String> _imageUrls = []; // Separate list for images
  List<String> _videoUrls = []; // Separate list for videos
  List<String> _documentUrls = []; // Separate list for documents

  bool _isGeocoding = false;
  bool get isGeocoding => _isGeocoding;

  // API Key for Google Maps Geocoding API
  final String _apiKey =
      "AIzaSyC9TbKldN2qRj91FxHl1KC3r7KjUlBXOSk"; // Replace with your actual API key

// Getters and Setters for Step 1
  String get phoneNumber => _phoneNumber;
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  String get name => _name;
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  String get propertyOwnerName => _propertyOwnerName;
  void setPropertyOwnerName(String value) {
    _propertyOwnerName = value;
    notifyListeners();
  }

  String get propertyType => _propertyType;
  void setPropertyType(String value) {
    _propertyType = value;
    notifyListeners();
  }

  // Getters and Setters for Step 2
  double get area => _area;
  void setArea(double value) {
    // Removed the constraint to allow 0.0
    _area = value;
    calculateTotalPrice();
    notifyListeners();
  }

  double get pricePerUnit => _pricePerUnit;
  void setPricePerUnit(double value) {
    // Removed the constraint to allow 0.0
    _pricePerUnit = value;
    calculateTotalPrice();
    notifyListeners();
  }

  double get totalPrice => _totalPrice;

  void calculateTotalPrice() {
    _totalPrice = _area * _pricePerUnit;
    notifyListeners();
  }

  String get surveyNumber => _surveyNumber;
  void setSurveyNumber(String value) {
    _surveyNumber = value;
    notifyListeners();
  }

  List<String> get plotNumbers => _plotNumbers;
  void addPlotNumber(String plotNumber) {
    if (!_plotNumbers.contains(plotNumber)) {
      _plotNumbers.add(plotNumber);
      notifyListeners();
    }
  }

  void removePlotNumber(String plotNumber) {
    _plotNumbers.remove(plotNumber);
    notifyListeners();
  }

  // Getters and Setters for Step 3
  String? get district => _district;
  void setDistrict(String value) {
    _district = value;
    _mandal = null; // Reset mandal when district changes
    notifyListeners();
  }

  String? get mandal => _mandal;
  void setMandal(String value) {
    _mandal = value;
    notifyListeners();
  }

  String get city => _city;
  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  String get village => _village;
  void setVillage(String value) {
    _village = value;
    notifyListeners();
  }

  String get pincode => _pincode;
  Future<void> setPincode(String value) async {
    _pincode = value;
    notifyListeners();

    if (_pincode.length == 6) {
      try {
        await geocodePincode(_pincode);
      } catch (e) {
        developer.log('Geocoding failed: $e');
      }
    }
  }

  String get state => _state;
  void setStateField(String value) {
    // Renamed to avoid conflict with setState
    _state = value;
    notifyListeners();
  }

  // Getters and Setters for Step 4
  double get latitude => _latitude;
  void setLatitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  double get longitude => _longitude;
  void setLongitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  // Getters and Setters for Additional Fields
  String get roadAccess => _roadAccess;
  void setRoadAccess(String value) {
    _roadAccess = value;
    notifyListeners();
  }

  String get roadType => _roadType;
  void setRoadType(String value) {
    _roadType = value;
    notifyListeners();
  }

  double get roadWidth => _roadWidth;
  void setRoadWidth(double value) {
    if (value < 0) throw ArgumentError('Road width cannot be negative');
    _roadWidth = value;
    notifyListeners();
  }

  String get landFacing => _landFacing;
  void setLandFacing(String value) {
    _landFacing = value;
    notifyListeners();
  }

  // Getters and Setters for Step 5
  List<String> get imageUrls => _imageUrls;
  void addImageUrl(String url) {
    if (!_imageUrls.contains(url)) {
      _imageUrls.add(url);
      notifyListeners();
    }
  }

  void removeImageUrl(String url) {
    // Changed from removeImageUrls to removeImageUrl
    _imageUrls.remove(url);
    notifyListeners();
  }

  List<String> get videoUrls => _videoUrls;
  void addVideoUrl(String url) {
    if (!_videoUrls.contains(url)) {
      _videoUrls.add(url);
      notifyListeners();
    }
  }

  void removeVideoUrl(String url) {
    // Changed from removeVideoUrls to removeVideoUrl
    _videoUrls.remove(url);
    notifyListeners();
  }

  List<String> get documentUrls => _documentUrls;
  void addDocumentUrl(String url) {
    if (!_documentUrls.contains(url)) {
      _documentUrls.add(url);
      notifyListeners();
    }
  }

  void removeDocumentUrl(String url) {
    _documentUrls.remove(url);
    notifyListeners();
  }

  // Getter for districtList
  List<String> get districtList => districtData.keys.toList();

  // Getter for Mandal List based on District
  List<String> get mandalList {
    if (_district != null && districtData.containsKey(_district!)) {
      return districtData[_district!]!.toSet().toList();
    }
    return [];
  }

  /// Geocode the current pincode to obtain city, district, and state

  Future<void> geocodePincode(String pincode) async {
    _isGeocoding = true;
    notifyListeners();

    try {
      final Uri uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$pincode&components=country:IN&key=$_apiKey');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          String city = '';
          String district = '';
          String state = '';

          List<dynamic> results = data['results'];
          if (results.isNotEmpty) {
            List<dynamic> addressComponents = results[0]['address_components'];
            for (var component in addressComponents) {
              List<dynamic> types = component['types'];
              if (types.contains('locality')) {
                city = component['long_name'];
              } else if (types.contains('administrative_area_level_2') ||
                  types.contains('administrative_area_level_3')) {
                district = component['long_name'];
              } else if (types.contains('administrative_area_level_1')) {
                state = component['long_name'];
              }
            }

            // Update the provider fields
            setCity(city);
            setDistrict(district);
            setStateField(state);

            // Optionally, update latitude and longitude
            if (results[0]['geometry'] != null &&
                results[0]['geometry']['location'] != null) {
              double lat = results[0]['geometry']['location']['lat'];
              double lng = results[0]['geometry']['location']['lng'];
              setLatitude(lat);
              setLongitude(lng);
            }
          } else {
            throw Exception('No results found for the provided pincode.');
          }
        } else {
          throw Exception('Geocoding API error: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch location details.');
      }
    } finally {
      _isGeocoding = false;
      notifyListeners();
    }
  }

  // Convert provider data to Property model
  Property toProperty() {
    // Process each image and video URL if needed
    _imageUrls.forEach((url) {
      developer.log("Adding image URL to property: $url");
      // Replace this log with any processing you need
    });

    _videoUrls.forEach((url) {
      developer.log("Adding video URL to property: $url");
      // Replace this log with any processing you need
    });

    return Property(
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
      name: _name,
      mobileNumber: _phoneNumber,
      propertyType: _propertyType,
      landArea: _area,
      pricePerUnit: _pricePerUnit,
      totalPrice: _totalPrice,
      surveyNumber: _surveyNumber,
      plotNumbers: _propertyType == 'plot' ? _plotNumbers : [],
      district: _district,
      mandal: _mandal,
      city: _city,
      village: _village,
      pincode: _pincode,
      state: _state,
      latitude: _latitude,
      longitude: _longitude,
      roadAccess: _roadAccess,
      roadType: _roadType,
      roadWidth: _roadWidth,
      landFacing: _landFacing,
      propertyOwner: _propertyOwnerName,
      images: _imageUrls, // Pass the image URLs to the model
      videos: _videoUrls, // Pass the video URLs to the model
      documents: _documentUrls, // Pass the document URLs to the model
    );
  }

  // Reset the form after submission
  void resetForm() {
    _phoneNumber = '';
    _name = '';
    _propertyOwnerName = '';
    _propertyType = 'plot';
    _area = 0.0;
    _pricePerUnit = 0.0;
    _totalPrice = 0.0;
    _surveyNumber = '';
    _plotNumbers = [];
    _district = null;
    _mandal = null;
    _city = '';
    _village = '';
    _pincode = '';
    _state = '';
    _latitude = 17.385044;
    _longitude = 78.486671;
    _roadAccess = '';
    _roadType = '';
    _roadWidth = 0.0;
    _landFacing = '';
    _imageUrls.clear();
    _videoUrls.clear();
    _documentUrls.clear();
    notifyListeners();
  }
}
