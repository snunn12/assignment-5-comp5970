import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/city_card.dart';
import '../widgets/hobby_row.dart';
import '../widgets/book_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final favCities = provider.cities.where((city) => city.isFavorite).toList();
        final favHobbies = provider.hobbies.where((hobby) => hobby.isFavorite).toList();
        final favBooks = provider.books.where((book) => book.isFavorite).toList();

        final items = <Widget>[];

        if (favCities.isNotEmpty) {
          items.add(const SectionHeader(title: 'Cities'));
          items.addAll(favCities.map((city) => CityCard(city: city)));
        }

        if (favHobbies.isNotEmpty) {
          items.add(const SectionHeader(title: 'Hobbies'));
          items.addAll(favHobbies.map((hobby) => HobbyRow(hobby: hobby)));
        }

        if (favBooks.isNotEmpty) {
          items.add(const SectionHeader(title: 'Books'));
          items.addAll(favBooks.map((book) => BookCard(book: book)));
        }

        return Column(
          children: [
            if (items.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ClearButton(),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: items,
              ),
            ),
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 8
        ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
          ),
      ),
    );
  }
}
class ClearButton extends StatelessWidget {
  const ClearButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.read<FavoritesProvider>().clearAllFavorites(),
      icon: const Icon(Icons.clear_all),
      label: const Text('Clear All'),
    );
  }
}
