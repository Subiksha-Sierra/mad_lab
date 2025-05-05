import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/movie_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _movieList = [];
  Map<String, double> _ratings = {};
  Map<String, dynamic>? _searchResult;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() async {
    final movies = await MovieApi.fetchPredefinedMovies();
    setState(() => _movieList = movies);
  }

  void _searchMovie() async {
    final title = _searchController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResult = null;
    });

    final result = await MovieApi.fetchMovie(title);
    setState(() {
      _searchResult = result;
      _isSearching = false;
    });
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    final String title = movie['Title'];
    final String poster = movie['Poster'];
    final String imdbID = movie['imdbID'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Image.network(poster, height: 100, width: 70, fit: BoxFit.cover),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IMDb: ${movie['imdbRating']}"),
            const SizedBox(height: 5),
            RatingBar.builder(
              initialRating: _ratings[imdbID] ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemSize: 24,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _ratings[imdbID] = rating;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search for a movie',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchMovie,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        if (_isSearching) const CircularProgressIndicator(),
        if (_searchResult != null) _buildMovieCard(_searchResult!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎬 Movie Rater')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSearchSection(),
            const SizedBox(height: 20),
            const Text('🔥 Trending Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._movieList.map(_buildMovieCard).toList(),
          ],
        ),
      ),
    );
  }
}
