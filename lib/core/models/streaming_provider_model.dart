import '../constants/app_constants.dart';

class StreamingProviderModel {
  final int providerId;
  final String providerName;
  final String logoPath;

  const StreamingProviderModel({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
  });

  String get logoUrl => '${AppConstants.tmdbLogoBaseUrl}$logoPath';

  // Normaliza o nome da plataforma para bater com o salvo em UserPreferences
  String get normalizedName {
    const map = {
      'amazon prime video': 'Prime Video',
      'disney plus': 'Disney+',
      'hbo max': 'Max',
      'max': 'Max',
      'paramount plus': 'Paramount+',
      'apple tv plus': 'Apple TV+',
      'apple tv+': 'Apple TV+',
      'globoplay': 'Globoplay',
      'netflix': 'Netflix',
      'star plus': 'Star+',
    };
    return map[providerName.toLowerCase()] ?? providerName;
  }

  factory StreamingProviderModel.fromJson(Map<String, dynamic> json) {
    return StreamingProviderModel(
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String,
      logoPath: (json['logo_path'] ?? '') as String,
    );
  }
}
