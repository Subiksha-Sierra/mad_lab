import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieApi {
  static const String _apiKey = 'd201b68c';
  static const String _baseUrl = 'https://www.omdbapi.com/';

  // Fetch a movie by IMDb ID
  static Future<Map<String, dynamic>?> fetchById(String imdbID) async {
    final response = await http.get(Uri.parse('$_baseUrl?apikey=$_apiKey&i=$imdbID'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['Response'] == 'True' ? data : null;
    } else {
      throw Exception('Failed to load movie by ID');
    }
  }

  // Fetch a list of predefined movies (Trending / Landing page)
  static Future<List<Map<String, dynamic>>> fetchPredefinedMovies() async {
    List<String> imdbIds = ['tt1375666', 'tt0110912', 'tt0137523']; // Inception, Pulp Fiction, Fight Club

    List<Map<String, dynamic>> movies = [];
    for (String id in imdbIds) {
      final movie = await fetchById(id);
      if (movie != null) {
        movies.add(movie);
      }
    }
    return movies;
  }

  // 🔍 Search for a movie by title
  static Future<Map<String, dynamic>?> fetchMovie(String title) async {
    final response = await http.get(Uri.parse('$_baseUrl?apikey=$_apiKey&t=$title'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['Response'] == 'True' ? data : null;
    } else {
      throw Exception('Failed to search movie');
    }
  }
}