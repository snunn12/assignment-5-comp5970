import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';


class BookCard extends StatelessWidget {
  final BookModel book;

  const BookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          book.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(book.bookAuthor),
        trailing: IconButton(onPressed: () {
          context
              .read<FavoritesProvider>()
              .toggleBookFavorite(book.id);
        },
        icon: Icon(
          book.isFavorite
              ? Icons.favorite
              : Icons.favorite_border,
        ),
        ),
      ),
    );
  }
}