import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<Map<String, String>?> getLocationFromPincode(String pincode) async {
    // If your API key is in the AndroidManifest, you can store it here or retrieve from propertyProvider
    const String apiKey = 'AIzaSyA5Dqm48zEoIY_KSx1aHGCETkUXKh48OqA';

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?address=$pincode'
            '&components=country:IN'
            '&key=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Geocoding API response: ${response.body}");
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        // The first result typically has the best match
        final addressComponents = data['results'][0]['address_components'] as List;

        String city = '';
        String district = '';
        String state = '';

        // Iterate over results to find a district value.
        for (final comp in addressComponents) {
          final types = comp['types'] as List;
          if (types.contains('locality')) {
            city = comp['long_name'];
          }
          else if (types.contains('administrative_area_level_2')) {
            district = comp['long_name'];
          }
          // Fallback: if no admin_area_level_2, check for admin_area_level_3
          else if (types.contains('administrative_area_level_3') && district.isEmpty) {
            district = comp['long_name'];
          }
          else if (types.contains('administrative_area_level_1')) {
            state = comp['long_name'];
          }
        }

        return {
          'city': city,
          'district': district,
          'state': state,
        };
      }
    }

    // If the call fails or no results, return null
    return null;
  }
}
