import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/title_model.dart';
import '../models/streaming_provider_model.dart';

class TmdbService {
  static const _base = AppConstants.tmdbBaseUrl;
  static const _key = AppConstants.tmdbApiKey;
  static const _lang = AppConstants.language;
  static const _region = AppConstants.region;

  Future<List<TitleModel>> getTrending() => _fetchList(
        '$_base/trending/all/week?api_key=$_key&language=$_lang',
      );

  Future<List<TitleModel>> getPopularMovies() => _fetchList(
        '$_base/movie/popular?api_key=$_key&language=$_lang&region=$_region',
      );

  Future<List<TitleModel>> getPopularTV() => _fetchList(
        '$_base/tv/popular?api_key=$_key&language=$_lang',
      );

  Future<List<TitleModel>> search(String query) => _fetchList(
        '$_base/search/multi?api_key=$_key&language=$_lang&query=${Uri.encodeComponent(query)}',
      );

  Future<List<TitleModel>> _fetchList(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Erro HTTP: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((item) => TitleModel.fromJson(item as Map<String, dynamic>))
        .where((t) => t.posterPath.isNotEmpty)
        .toList();
  }

  /// Retorna a key do YouTube do primeiro trailer encontrado, ou null.
  Future<String?> getTrailerKey(int id, String mediaType) async {
    final uri = Uri.parse(
      '$_base/$mediaType/$id/videos?api_key=$_key&language=$_lang',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    // Prefere trailer oficial no YouTube; fallback para qualquer vídeo
    final videos = results
        .map((v) => v as Map<String, dynamic>)
        .where((v) => v['site'] == 'YouTube')
        .toList();

    final trailer = videos.firstWhere(
      (v) => v['type'] == 'Trailer',
      orElse: () => videos.isNotEmpty ? videos.first : {},
    );

    return trailer['key'] as String?;
  }

  Future<List<StreamingProviderModel>> getWatchProviders(
    int id,
    String mediaType,
  ) async {
    final uri = Uri.parse(
      '$_base/$mediaType/$id/watch/providers?api_key=$_key',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as Map<String, dynamic>?;
    if (results == null || !results.containsKey(_region)) return [];

    final regionData = results[_region] as Map<String, dynamic>;
    final flatrate = regionData['flatrate'] as List<dynamic>?;
    if (flatrate == null) return [];

    return flatrate
        .map((p) =>
            StreamingProviderModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
