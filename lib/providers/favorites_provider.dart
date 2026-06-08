import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';

class FavoritesProvider extends ChangeNotifier {

  bool isDarkMode = false;

  final cities = sampleCities;
  final hobbies = sampleHobbies;
  final books = sampleBooks;

  FavoritesProvider({required this.isDarkMode}) {
    loadFavorites();
  }

  void toggleHobbyFavorite(int hobbyId) {
    final hobby = hobbies.firstWhere(
      (hobby) => hobby.id == hobbyId,
    );
    hobby.isFavorite = !hobby.isFavorite;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode = value;
    notifyListeners();

    final uiPrefs = await SharedPreferences.getInstance();
    await uiPrefs.setBool('isDarkMode', value);
  }

  void toggleCityFavorite(int cityId) {
    final city = cities.firstWhere(
      (city) => city.id == cityId,
    );

    city.isFavorite = !city.isFavorite;

    saveFavorites();

    notifyListeners();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favoriteIds = cities
        .where((city) => city.isFavorite)
        .map((city) => city.id.toString())
        .toList();

    await prefs.setStringList(
      'favoriteCities',
      favoriteIds,
    );
  }

  void clearAllFavorites() {
    for (final city in cities) { 
      city.isFavorite = false; 
      }
    for (final hobby in hobbies) {
       hobby.isFavorite = false; 
      }
    for (final book in books) { 
      book.isFavorite = false; 
      }
    saveFavorites();
    notifyListeners();
  }

  void toggleBookFavorite(int bookId) {
    final book = books.firstWhere(
        (book) => book.id == bookId,
    );
    book.isFavorite = !book.isFavorite;

    saveFavorites();

    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favoriteIds = prefs.getStringList('favoriteCities') ?? [];

    for (final city in cities) {
      city.isFavorite = favoriteIds.contains(city.id.toString());
    }

    notifyListeners();
  }
}