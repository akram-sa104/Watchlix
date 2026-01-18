import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Watchlist', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background konsisten merah-hitam
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.7),
                radius: 1.5,
                colors: [Color(0xFF3D0808), Colors.black],
              ),
            ),
          ),
          SafeArea(
            child: watchlist.isEmpty
                ? const Center(child: Text('Watchlist kosong', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: watchlist.length,
                    itemBuilder: (context, index) {
                      final movie = watchlist[index];
                      
                      return Container(
                        key: ValueKey(movie.id), 
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(movie.releaseDate.split('-')[0], style: const TextStyle(color: Colors.white54)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              
                              ref.read(watchlistProvider.notifier).removeFromWatchlist(movie);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${movie.title} dihapus'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}