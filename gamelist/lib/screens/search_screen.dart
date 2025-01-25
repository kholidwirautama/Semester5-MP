import 'package:flutter/material.dart';
import 'package:game_list/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:game_list/models/provider.dart';
import 'package:game_list/models/game_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  // Hasil
  Future<void> searchGames(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final url = 'https://api.rawg.io/api/games?search=$query&key=$apiKey';

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          final decodedData = jsonDecode(response.body);
          searchResults = decodedData[
              'results'];
        });
      } else {
        throw Exception('Failed to search games');
      }
    } catch (error) {
      print('Error searching games: $error');
      setState(() {
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'SEARCH',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search for games...',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => searchGames(_searchController.text),
                ),
              ),
              onSubmitted: (value) => searchGames(value),
            ),
          ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final game = searchResults[index];
                        final gameId = game['id'].toString();
                        final gameObject = Game(
                          id: gameId,
                          name: game['name'] ?? 'Unknown Game',
                          backgroundImage: game['background_image'] ?? '',
                          releaseDate: game['released'] ?? 'N/A',
                        );

                        // Cek
                        final isLiked = Provider.of<GameProvider>(context)
                            .likedGames
                            .contains(gameObject);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12.0),
                              leading: game['background_image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        game['background_image'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.videogame_asset,
                                      color: Colors.white,
                                    ),
                              title: Text(
                                game['name'] ?? 'Unknown Game',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Release Date: ${game['released'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.white,
                                ),
                                onPressed: () {
                                  Provider.of<GameProvider>(context,
                                          listen: false)
                                      .toggleLike(gameObject);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
