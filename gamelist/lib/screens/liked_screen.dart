import 'package:flutter/material.dart';
import 'package:game_list/models/provider.dart';
import 'package:provider/provider.dart';

class LikedScreen extends StatelessWidget {
  const LikedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'LIKED GAME',
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
      // G
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // G
          final likedGames = gameProvider.likedGames.toList();
          return likedGames.isEmpty
              ? const Center(child: Text('No liked games yet.', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  // C
                  itemCount: likedGames.length,
                  itemBuilder: (context, index) {
                    final game = likedGames[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              game.backgroundImage,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            game.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Release Date: ${game.releaseDate}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              gameProvider.toggleLike(game);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}