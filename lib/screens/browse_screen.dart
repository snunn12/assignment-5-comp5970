import 'package:favorites/data/sample_data.dart';
import 'package:flutter/material.dart';
import '../widgets/book_card.dart';
import '../widgets/city_card.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/hobby_row.dart';

enum ContentCategory {
  cities,
  hobbies,
  books,
}

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  ContentCategory selectedCategory = ContentCategory.cities;
  String searchText = "";

  String get searchHint => "Search ${selectedCategory.name}";

  @override
  Widget build(BuildContext context) {

    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton(
              segments: [
                ButtonSegment(
                  value: ContentCategory.cities,
                  label: Text("Cities")),
                ButtonSegment(
                  value: ContentCategory.hobbies,
                  label: Text("Hobbies")),
                ButtonSegment(
                  value: ContentCategory.books,
                  label: Text("Books"))
              ], 
              selected: {selectedCategory},
              onSelectionChanged: (selection) {
                setState(() {
                  selectedCategory = selection.first;
                });
              },),

            SizedBox(height: 16,),

            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: searchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              
              },
              
            ),

            SizedBox(height: 16),

            Expanded(
              child: Builder(
                builder: (context) {
                  switch (selectedCategory) {
                    case ContentCategory.cities:
                    final cities = favoritesProvider.cities.where(
                      (city) => city.cityName.toLowerCase().contains(searchText.toLowerCase())).toList();
                      return ListView.builder(
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          return CityCard(city: city);
                        },
                      );
                    case ContentCategory.hobbies:
                    final hobbies = favoritesProvider.hobbies.where(
                      (hobby) => hobby.hobbyName.toLowerCase().contains(searchText.toLowerCase())).toList();
                      return ListView.builder(
                        itemCount: hobbies.length,
                        itemBuilder: (context, index) {
                          final hobby = hobbies[index];
                          return HobbyRow(hobby: hobby);
                        },
                      );
                    case ContentCategory.books:
                    final books = favoritesProvider.books.where(
                      (book) => book.bookTitle.toLowerCase().contains(searchText.toLowerCase())).toList();
                      return ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return BookCard(book: book);
                        },
                      );
                  }
                }
              ),
            ),
          ],
        ),
        )),
    );
  }
}