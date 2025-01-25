import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:game_list/models/game_model.dart';

class GameProvider with ChangeNotifier {
  List<Game> _likedGames = [];

  GameProvider() {
    _loadLikedGames();
  }

  List<Game> get likedGames => _likedGames;

  void toggleLike(Game game) {
    if (_likedGames.contains(game)) {
      _likedGames.remove(game);
    } else {
      _likedGames.add(game);
    }
    _saveLikedGames();
    notifyListeners();
  }

  Future<void> _loadLikedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final String? likedGamesString = prefs.getString('likedGames');
    if (likedGamesString != null) {
      List<dynamic> jsonList = json.decode(likedGamesString);
      _likedGames = jsonList.map((json) => Game.fromJson(json)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveLikedGames() async {
    final prefs = await SharedPreferences.getInstance();
    // Save as
    List<Map<String, dynamic>> jsonList = _likedGames.map((game) => game.toJson()).toList();
    await prefs.setString('likedGames', json.encode(jsonList));
  }
}