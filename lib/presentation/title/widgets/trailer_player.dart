import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/services/deep_link_service.dart';

/// Player de trailer.
/// - Mobile (Android/iOS) e Web: player embutido do YouTube.
/// - Desktop (Windows/Linux/macOS): thumbnail clicável que abre o YouTube.
class TrailerPlayer extends StatefulWidget {
  final String videoKey;

  const TrailerPlayer({super.key, required this.videoKey});

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  YoutubePlayerController? _controller;
  bool _showPlayer = false; // desktop: exibe thumbnail até clicar

  bool get _canEmbed {
    if (kIsWeb) return true;
    try {
      // ignore: do_not_use_environment
      final platform = defaultTargetPlatform;
      return platform == TargetPlatform.android ||
          platform == TargetPlatform.iOS;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_canEmbed) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoKey,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          loop: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  String get _thumbnailUrl =>
      'https://img.youtube.com/vi/${widget.videoKey}/hqdefault.jpg';

  String get _youtubeUrl =>
      'https://www.youtube.com/watch?v=${widget.videoKey}';

  @override
  Widget build(BuildContext context) {
    if (_canEmbed && _controller != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
        ),
      );
    }

    // Desktop: thumbnail com overlay de play
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _showPlayer
            ? _buildDesktopWebPlayer()
            : _buildThumbnail(),
      ),
    );
  }

  Widget _buildThumbnail() {
    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          setState(() => _showPlayer = true);
        } else {
          DeepLinkService.openUrl(_youtubeUrl);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[900],
              child: const Icon(Icons.movie_outlined,
                  color: Colors.white38, size: 48),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Assistir no YouTube',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWebPlayer() {
    // No desktop web podemos usar um iframe via HtmlElementView,
    // mas para simplificar abrimos no YouTube diretamente.
    DeepLinkService.openUrl(_youtubeUrl);
    return _buildThumbnail();
  }
}
