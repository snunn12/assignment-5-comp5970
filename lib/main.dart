import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/content_view.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';

//Note I found the way to save UI on google pretty neet
//I thought it was somehow going to need to use something with caching
//but dart allows you to save data asynchronously with boolean values
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final uiPrefs = await SharedPreferences.getInstance();
  final isDarkMode = uiPrefs.getBool("isDarkMode") ?? false;
   return runApp(FavoritesApp(isDarkMode: isDarkMode));
}

class FavoritesApp extends StatelessWidget {
  final bool isDarkMode;
  const FavoritesApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(isDarkMode: isDarkMode),
      child: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black
            ),
            themeMode: favoritesProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: ContentView(),
          );
        })
      );
    
  }
}