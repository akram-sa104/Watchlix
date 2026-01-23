class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final List<int>? genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
     this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: (json['overview'] == null || json['overview'].toString().isEmpty)
          ? "Sinopsis tidak tersedia dalam bahasa ini."
          : json['overview'],
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? 'N/A',
      genreIds: (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }
}