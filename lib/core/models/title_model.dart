import '../constants/app_constants.dart';

class TitleModel {
  final int id;
  final String name;
  final String posterPath;
  final String overview;
  final String mediaType; // 'movie' ou 'tv'

  const TitleModel({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.overview,
    required this.mediaType,
  });

  String get posterUrl => '${AppConstants.tmdbImageBaseUrl}$posterPath';

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['id'] as int,
      name: (json['title'] ?? json['name'] ?? '') as String,
      posterPath: (json['poster_path'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      mediaType: (json['media_type'] ?? 'movie') as String,
    );
  }
}
