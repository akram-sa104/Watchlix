import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchlix/screens/genre_movies_screen.dart';
import 'package:watchlix/screens/setting_screen.dart';
import 'package:watchlix/screens/splash_screen.dart';
import 'screens/home_screen.dart'; 
import 'screens/watchlist_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/genre_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ostzbijcuqqbgmmhcggp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zdHpiaWpjdXFxYmdtbWhjZ2dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTk1MzMsImV4cCI6MjA4NDEzNTUzM30.OfBSaiTSiwMptVOBjZphQQFSfppshPKCCIuRWgdfktQ',
  );
  runApp(ProviderScope(child: WatchlixApp()));
}

class WatchlixApp extends StatelessWidget {
  const WatchlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Watchlix',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: SplashScreen(), 
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(), 
        '/watchlist': (context) => WatchlistScreen(), 
        '/genre': (context) => GenreScreen(),
        '/setting': (context) => const SettingScreen(),
        '/genre_movies': (context) => GenreMoviesScreen(),
      },
    );
  }
}