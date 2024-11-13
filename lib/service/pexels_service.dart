import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsService {
  final String apiKey =
      '1UpPxgbDI4ROEj07w9R0KxJvlCZGY9tK7EoidL7sVDNaPPDZPQ5zj3MW'; // Ganti dengan API Key Pexels yang valid
  final String baseUrl = 'https://api.pexels.com/v1/';

  Future<List<String>> fetchImages(String query, int page) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}search?query=$query&per_page=10&page=$page'),
        headers: {
          'Authorization': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> imageUrls = [];
        for (var photo in data['photos']) {
          imageUrls.add(photo['src']['medium']);
        }
        return imageUrls;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Failed to load images: $e');
    }
  }
}
