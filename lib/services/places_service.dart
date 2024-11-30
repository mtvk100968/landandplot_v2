import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey;

  PlacesService({required this.apiKey});

  Future<List<dynamic>> getAutocomplete(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    if (json['status'] == 'OK') {
      return json['predictions'];
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component,geometry,formatted_address&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    if (json['status'] == 'OK') {
      return json['result'];
    } else {
      throw Exception('Failed to fetch place details');
    }
  }
}
