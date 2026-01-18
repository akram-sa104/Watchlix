import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:watchlix/models/movie.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Memakai semua provider asli Anda
    final popularMoviesAsync = ref.watch(moviesProvider);
    final topRatedMoviesAsync = ref.watch(topRatedProvider);
    final upcomingMoviesAsync = ref.watch(upcomingProvider);
    final nowPlayingMoviesAsync = ref.watch(nowPlayingProvider);
    final searchList = ref.watch(searchProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomAppBar(),
                  const SizedBox(height: 15),
                  _buildSearchBar(),
                  const SizedBox(height: 25),

                  // FUNGSI SEARCH ASLI ANDA
                  if (_searchController.text.isNotEmpty)
                    _buildMovieRowManual(searchList, 'Search Results')
                  else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text('Featured Today', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    
                    popularMoviesAsync.when(
                      data: (movies) => CarouselSlider.builder(
                        itemCount: movies.length > 10 ? 10 : movies.length,
                        itemBuilder: (context, index, realIndex) => _buildFeaturedCard(movies[index]),
                        options: CarouselOptions(
                          height: 450,
                          viewportFraction: 0.75,
                          enlargeCenterPage: true,
                          autoPlay: true,
                        ),
                      ),
                      loading: () => _buildShimmerFeatured(),
                      error: (e, _) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),
                    _buildMovieRow(nowPlayingMoviesAsync, 'Now Playing'),
                    _buildMovieRow(topRatedMoviesAsync, 'Top Rated'),
                    _buildMovieRow(upcomingMoviesAsync, 'Upcoming Movies'),
                    const SizedBox(height: 50),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FUNGSI APPBAR ASLI (Watchlist & Genre Kembali)
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Watchlix', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/watchlist'),
                icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/genre'),
                icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
        onChanged: (query) {
          setState(() {}); // Menjaga UI tetap update saat ngetik
          ref.read(searchProvider.notifier).searchMovies(query);
        },
      ),
    );
  }

  // Widget Row untuk AsyncValue (Data API)
  Widget _buildMovieRow(AsyncValue<List<Movie>> asyncValue, String title) {
    return asyncValue.when(
      data: (movies) => _buildMovieRowManual(movies, title),
      loading: () => _buildShimmerList(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  // Widget Row untuk List Murni (Search/Data yang sudah ada)
  Widget _buildMovieRowManual(List<Movie> movies, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 15),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                key: ValueKey(movie.id), // PENTING: Agar tidak salah hapus/display
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(image: NetworkImage('https://image.tmdb.org/t/p/w300${movie.posterPath}'), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(image: NetworkImage('https://image.tmdb.org/t/p/w500${movie.posterPath}'), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildShimmerFeatured() => Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(margin: const EdgeInsets.symmetric(horizontal: 40), height: 400, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25))));
  Widget _buildShimmerList() => Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 180, width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 20), color: Colors.black));
}