import 'package:flutter/material.dart';
import 'package:game_list/models/provider.dart';
import 'package:game_list/models/game_model.dart';
import 'package:game_list/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> newGamesToday = [];
  String selectedDate = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    selectedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadNewGamesToday();
  }

  // API
  Future<void> _loadNewGamesToday() async {
    setState(() {
      isLoading = true;
    });

    final String url =
        'https://api.rawg.io/api/games?dates=$selectedDate,$selectedDate&ordering=-released&key=$apiKey';
    print(url);

    try {
      final response = await http.get(Uri.parse(url));
      print('API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response Data: $data');
        setState(() {
          newGamesToday = data['results'] ?? [];
          isLoading = false;
        });
        if (newGamesToday.isEmpty) {
          print('No new games found for $selectedDate.');
        }
      } else {
        throw Exception('Failed to load games');
      }
    } catch (error) {
      print('Error loading games: $error');
      setState(() {
        newGamesToday = [];
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.parse(selectedDate)) {
      setState(() {
        selectedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _loadNewGamesToday();
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
            'HOME',
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
      body: RefreshIndicator(
        onRefresh: _loadNewGamesToday,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Game List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date: $selectedDate',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main section
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : newGamesToday.isEmpty
                    ? Center(
                        child: Text('No new games found for $selectedDate.',
                            style: const TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: newGamesToday.length,
                        itemBuilder: (context, index) {
                          final game = newGamesToday[index];
                          final gameId = game['id'].toString();

                          final gameObject = Game(
                            id: gameId,
                            name: game['name'] ?? 'Unknown Game',
                            backgroundImage: game['background_image'] ?? '',
                            releaseDate: game['released'] ?? 'N/A',
                          );

                          // Check if liked
                          final isLiked = Provider.of<GameProvider>(context)
                              .likedGames
                              .contains(gameObject);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              color: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12.0)),
                                    child: game['background_image'] != null
                                        ? Image.network(
                                            game['background_image'],
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 180,
                                            color: Colors.grey,
                                            child: const Icon(
                                              Icons.videogame_asset,
                                              color: Colors.white,
                                              size: 64,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                game['name'] ?? 'Unknown Game',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isLiked
                                                    ? Colors.red
                                                    : Colors.white,
                                              ),
                                              onPressed: () {
                                                Provider.of<GameProvider>(context,
                                                        listen: false)
                                                    .toggleLike(gameObject);
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Release Date: ${game['released'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}