import 'package:flutter/material.dart';

class StreamingInfo {
  final String name;
  final Color primaryColor;
  final String searchUrl;
  final String signupUrl;
  final String cancelUrl;
  final String homeUrl;

  const StreamingInfo({
    required this.name,
    required this.primaryColor,
    required this.searchUrl,
    required this.signupUrl,
    required this.cancelUrl,
    required this.homeUrl,
  });

  String searchForTitle(String titleName) {
    final encoded = Uri.encodeComponent(titleName);
    return searchUrl.replaceAll('{query}', encoded);
  }
}

class StreamingConstants {
  static const Map<String, StreamingInfo> providers = {
    'Netflix': StreamingInfo(
      name: 'Netflix',
      primaryColor: Color(0xFFE50914),
      searchUrl: 'https://www.netflix.com/search?q={query}',
      signupUrl: 'https://www.netflix.com/signup',
      cancelUrl: 'https://www.netflix.com/cancelplan',
      homeUrl: 'https://www.netflix.com',
    ),
    'Prime Video': StreamingInfo(
      name: 'Prime Video',
      primaryColor: Color(0xFF00A8E1),
      searchUrl:
          'https://www.primevideo.com/search/ref=atv_nb_sr?phrase={query}',
      signupUrl: 'https://www.primevideo.com/register',
      cancelUrl: 'https://www.amazon.com.br/prime',
      homeUrl: 'https://www.primevideo.com',
    ),
    'Disney+': StreamingInfo(
      name: 'Disney+',
      primaryColor: Color(0xFF113CCF),
      searchUrl: 'https://www.disneyplus.com/search?q={query}',
      signupUrl: 'https://www.disneyplus.com/pt-br/welcome',
      cancelUrl: 'https://www.disneyplus.com/pt-br/account',
      homeUrl: 'https://www.disneyplus.com',
    ),
    'Max': StreamingInfo(
      name: 'Max',
      primaryColor: Color(0xFF002BE7),
      searchUrl: 'https://play.max.com/search?q={query}',
      signupUrl: 'https://play.max.com/signup',
      cancelUrl: 'https://play.max.com/account',
      homeUrl: 'https://play.max.com',
    ),
    'Apple TV+': StreamingInfo(
      name: 'Apple TV+',
      primaryColor: Color(0xFF555555),
      searchUrl: 'https://tv.apple.com/search?term={query}',
      signupUrl: 'https://tv.apple.com/channel/tvs.sbd.4000',
      cancelUrl: 'https://support.apple.com/pt-br/118428',
      homeUrl: 'https://tv.apple.com',
    ),
    'Globoplay': StreamingInfo(
      name: 'Globoplay',
      primaryColor: Color(0xFFFF0028),
      searchUrl: 'https://globoplay.globo.com/busca/?q={query}',
      signupUrl: 'https://globoplay.globo.com/assine/',
      cancelUrl: 'https://minhaconta.globo.com/assinaturas',
      homeUrl: 'https://globoplay.globo.com',
    ),
    'Paramount+': StreamingInfo(
      name: 'Paramount+',
      primaryColor: Color(0xFF0064FF),
      searchUrl: 'https://www.paramountplus.com/br/search/{query}/',
      signupUrl: 'https://www.paramountplus.com/br/account/signup/',
      cancelUrl: 'https://www.paramountplus.com/br/account/',
      homeUrl: 'https://www.paramountplus.com/br/',
    ),
    'Star+': StreamingInfo(
      name: 'Star+',
      primaryColor: Color(0xFF032D62),
      searchUrl: 'https://www.starplus.com/search?q={query}',
      signupUrl: 'https://www.starplus.com/signup',
      cancelUrl: 'https://www.starplus.com/account',
      homeUrl: 'https://www.starplus.com',
    ),
  };

  static List<String> get allProviderNames => providers.keys.toList();

  static StreamingInfo? getInfo(String providerName) => providers[providerName];
}
