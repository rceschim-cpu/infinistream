import 'package:flutter/material.dart';
import '../../core/utils/user_preferences.dart';

class TitleDetailPage extends StatelessWidget {
  final String title;

  const TitleDetailPage({super.key, required this.title});

  static const Map<String, List<String>> _streamingsByTitle = {
    'Interestelar': ['Netflix', 'Prime Video'],
    'The Last of Us': ['Prime Video'],
    'Oppenheimer': ['Netflix', 'Disney+'],
  };

  static const Map<String, String> _posterByTitle = {
    'Interestelar':
        'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    'The Last of Us':
        'https://image.tmdb.org/t/p/w500/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
    'Oppenheimer':
        'https://image.tmdb.org/t/p/w500/ptpr0kGAckfQkJeJIt8st5dglvd.jpg',
  };

  static const Map<String, String> _logoAsset = {
    'Netflix': 'assets/logos/netflix.png',
    'Prime Video': 'assets/logos/prime_video.png',
    'Disney+': 'assets/logos/disney_plus.png',
  };

  void _showStreamingsModal(BuildContext context) {
    final allStreamings = _streamingsByTitle[title] ?? [];

    // Ordena: plataformas do usuário primeiro
    final sorted = [...allStreamings]..sort((a, b) {
        final aOwned = UserPreferences.hasStreaming(a) ? 0 : 1;
        final bOwned = UserPreferences.hasStreaming(b) ? 0 : 1;
        return aOwned.compareTo(bOwned);
      });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Disponível em:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sorted.map((name) {
                final isOwned = UserPreferences.hasStreaming(name);
                final logoPath = _logoAsset[name];
                return Opacity(
                  opacity: isOwned ? 1.0 : 0.4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (logoPath != null)
                          Image.asset(logoPath, height: 32)
                        else
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        const SizedBox(width: 12),
                        if (!isOwned)
                          const Text(
                            '(não assinado)',
                            style: TextStyle(color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final posterUrl = _posterByTitle[title] ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: title,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sinopse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Uma jornada épica que desafia os limites do tempo e do espaço.',
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showStreamingsModal(context),
                      child: const Text(
                        'Assistir agora',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
