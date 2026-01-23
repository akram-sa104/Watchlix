import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';

final supabaseClient = Provider((ref) => Supabase.instance.client);

final moviesProvider = FutureProvider<List<Movie>>((ref) async {
  final lang = ref.watch(languageProvider); // Monitor perubahan bahasa
  const apiKey = 'bb4d1dda0f0dc37411d1bab67b07771d'; 
  final url = 'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=$lang';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  } else { throw Exception('Failed to load movies'); }
});

final topRatedProvider = FutureProvider<List<Movie>>((ref) async {
  final lang = ref.watch(languageProvider);
  const apiKey = 'bb4d1dda0f0dc37411d1bab67b07771d';
  final url = 'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey&language=$lang';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  } else { throw Exception('Failed to load top rated'); }
});

final upcomingProvider = FutureProvider<List<Movie>>((ref) async {
  final lang = ref.watch(languageProvider);
  const apiKey = 'bb4d1dda0f0dc37411d1bab67b07771d';
  final url = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey&language=$lang';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  } else { throw Exception('Failed to load upcoming'); }
});

final nowPlayingProvider = FutureProvider<List<Movie>>((ref) async {
  final lang = ref.watch(languageProvider);
  const apiKey = 'bb4d1dda0f0dc37411d1bab67b07771d';
  final url = 'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&language=$lang';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  } else { throw Exception('Failed to load now playing'); }
});

final moviesByGenreProvider = FutureProvider.family<List<Movie>, int>((ref, genreId) async {
  final lang = ref.watch(languageProvider);
  const apiKey = 'bb4d1dda0f0dc37411d1bab67b07771d';
  final url = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=$genreId&language=$lang';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  } else { throw Exception('Failed to load movies for genre'); }
});

final searchProvider = StateNotifierProvider<SearchNotifier, List<Movie>>((ref) {
  return SearchNotifier();
});

// Provider untuk status bahasa (default: English)
final languageProvider = StateProvider<String>((ref) => 'en-US');

// Helper untuk menerjemahkan teks sederhana
class AppLocalizations {
  static Map<String, Map<String, String>> values = {
    'en-US': {
      'setting': 'Settings',
      'account': 'Account',
      'general': 'General',
      'language': 'Language',
      'logout': 'Logout',
      'watch_now': 'Watch Now',
      'about': 'About',
      'app version': 'App Version',
    },
    'id-ID': {
      'setting': 'Pengaturan',
      'account': 'Akun',
      'general': 'Umum',
      'language': 'Bahasa',
      'logout': 'Keluar',
      'watch_now': 'Tonton Sekarang',
      'about': 'Tentang',
      'app version': 'Versi Aplikasi',
    },
  };

  static String translate(String key, String lang) {
    return values[lang]?[key] ?? key;
  }
}

class SearchNotifier extends StateNotifier<List<Movie>> {
  SearchNotifier() : super([]);
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) { state = []; return; }
    const apiKey = 'bb4d1dda0f0dc37411d1bab67b07771d';
    final url = 'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      state = (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
    } else { state = []; }
  }
}


final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<Movie>>((ref) {
  return WatchlistNotifier();
});

class WatchlistNotifier extends StateNotifier<List<Movie>> {
  WatchlistNotifier() : super([]) {
    loadWatchlist();
  }

  final supabase = Supabase.instance.client;

  Future<void> loadWatchlist() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final response = await supabase
          .from('watchlist')
          .select('movies(*)')
          .eq('user_id', user.id);
      
      state = (response as List).map((e) => Movie.fromJson(e['movies'])).toList();
    } catch (e) {
      debugPrint("Error Load: $e");
    }
  }

  Future<void> addToWatchlist(Movie movie) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final upsertedMovie = await supabase.from('movies').upsert({
        'tmdb_id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'release_date': movie.releaseDate,
      }, onConflict: 'tmdb_id').select('id').single();

      final movieId = upsertedMovie['id'];
      await supabase.from('watchlist').insert({
        'user_id': user.id,
        'movie_id': movieId,
      });

      if (!state.any((m) => m.id == movie.id)) {
        state = [...state, movie];
      }
    } catch (e) {
      debugPrint("Error Add: $e");
    }
  }

  Future<void> removeFromWatchlist(Movie movie) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final movieData = await supabase
          .from('movies')
          .select('id')
          .eq('tmdb_id', movie.id)
          .maybeSingle();

      if (movieData != null) {
        final internalId = movieData['id'];
        await supabase.from('watchlist').delete().match({
          'user_id': user.id,
          'movie_id': internalId,
        });
      }

      await supabase.from('watchlist').delete().match({
        'user_id': user.id,
        'movie_id': movie.id, 
      });

    } catch (e) {
      debugPrint("Error Delete: $e");
    } finally {
      state = state.where((m) => m.id != movie.id).toList();
    }
  }
}