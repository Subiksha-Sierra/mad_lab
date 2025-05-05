import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// --- Dog Model ---
class Dog {
  final String imageUrl;

  Dog({required this.imageUrl});

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(imageUrl: json['message']);
  }
}

// --- Provider ---
class DogProvider with ChangeNotifier {
  List<Dog> dogs = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchDogs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final url = Uri.parse('https://dog.ceo/api/breeds/image/random/5');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final results = jsonResponse['message'] as List;
        dogs = results.map((dogUrl) => Dog(imageUrl: dogUrl)).toList();
      } else {
        error = 'Failed to load dogs (Status: ${response.statusCode})';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// --- Main ---
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DogProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Dog Images',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const DogListPage(),
    );
  }
}

// --- UI ---
class DogListPage extends StatefulWidget {
  const DogListPage({super.key});

  @override
  State<DogListPage> createState() => _DogListPageState();
}

class _DogListPageState extends State<DogListPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DogProvider>(context, listen: false);
    provider.fetchDogs();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DogProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Dog Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              provider.fetchDogs();
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.error ?? "Unknown error",
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          provider.fetchDogs();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.dogs.length,
                  itemBuilder: (context, index) {
                    final dog = provider.dogs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Image.network(dog.imageUrl),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
