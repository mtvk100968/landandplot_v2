import 'package:flutter/material.dart';
import '../models/property_model.dart';
import 'dart:io';
import '../data/districts_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import convert for JSON decoding
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyProvider with ChangeNotifier {
  Timestamp getCurrentTimestampInIST() {
    DateTime nowUtc = DateTime.now().toUtc();
    DateTime nowIst = nowUtc.add(Duration(hours: 5, minutes: 30));
    return Timestamp.fromDate(nowIst);
  }

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
  String _pincode = '';
  String _state = '';
  String _city = '';
  String? _address;

  // Step 4: Map Location
  double _latitude = 17.385044; // Default to Hyderabad latitude
  double _longitude = 78.486671; // Default to Hyderabad longitude

  // Additional Fields
  String _roadAccess = ''; // e.g., "Yes/No"
  String _roadType = ''; // e.g., "Paved", "Gravel", "Dirt"
  double _roadWidth = 0.0; // in meters
  String _landFacing = ''; // e.g., "North", "South", etc.

  // Step 5: Media Upload
  List<File> _imageFiles = []; // List to store image files
  List<File> _videoFiles = []; // List to store video files
  List<File> _documentFiles = []; // List to store document files

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
    if (value == _district) {
      developer.log('District unchanged: $value');
      return;
    }

    developer.log('Setting new district: $value');
    _district = value;
    _mandal = null; // Reset mandal when district changes
    notifyListeners();
  }

  String? get mandal => _mandal;
  void setMandal(String value) {
    if (value == _mandal) {
      developer.log('Mandal unchanged: $value');
      return;
    }

    developer.log('Setting new mandal: $value');
    _mandal = value;
    notifyListeners();
  }

  String get city => _city;
  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  String get pincode => _pincode;
  Future<void> setPincode(String value) async {
    if (value == _pincode) {
      developer.log('Pincode unchanged: $value');
      return;
    }

    developer.log('Setting new pincode: $value');
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
    _state = value;
    notifyListeners();
  }

  // New Getter and Setter for Address
  String? get address => _address;
  void setAddress(String value) {
    _address = value;
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
  List<File> get imageFiles => _imageFiles;
  void addImageFile(File file) {
    if (!_imageFiles.contains(file)) {
      _imageFiles.add(file);
      notifyListeners();
    }
  }

  void removeImageFile(File file) {
    _imageFiles.remove(file);
    notifyListeners();
  }

  List<File> get videoFiles => _videoFiles;
  void addVideoFile(File file) {
    if (!_videoFiles.contains(file)) {
      _videoFiles.add(file);
      notifyListeners();
    }
  }

  void removeVideoFile(File file) {
    _videoFiles.remove(file);
    notifyListeners();
  }

  List<File> get documentFiles => _documentFiles;
  void addDocumentFile(File file) {
    if (!_documentFiles.contains(file)) {
      _documentFiles.add(file);
      notifyListeners();
    }
  }

  void removeDocumentFile(File file) {
    _documentFiles.remove(file);
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
    // Note: The actual upload of media files is handled separately.
    // This method should only convert the non-media fields.
    Timestamp createdAt = getCurrentTimestampInIST();

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
      pincode: _pincode,
      state: _state,
      latitude: _latitude,
      longitude: _longitude,
      roadAccess: _roadAccess,
      roadType: _roadType,
      roadWidth: _roadWidth,
      landFacing: _landFacing,
      propertyOwner: _propertyOwnerName,
      images: [], // Will be set after uploading
      videos: [], // Will be set after uploading
      documents: [], // Will be set after uploading
      address: _address,
      createdAt: createdAt, // Set the current time in IST
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
    _pincode = '';
    _state = '';
    _latitude = 17.385044;
    _longitude = 78.486671;
    _roadAccess = '';
    _roadType = '';
    _roadWidth = 0.0;
    _landFacing = '';
    _imageFiles.clear();
    _videoFiles.clear();
    _documentFiles.clear();
    _address = '';
    notifyListeners();
  }
}
