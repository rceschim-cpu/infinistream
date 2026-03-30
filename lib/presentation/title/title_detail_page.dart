import 'package:flutter/material.dart';
import '../../core/models/title_model.dart';
import '../../core/models/streaming_provider_model.dart';
import '../../core/services/tmdb_service.dart';
import '../../core/services/streaming_account_service.dart';
import '../../core/services/deep_link_service.dart';
import '../streaming/connect_streaming_page.dart';
import 'widgets/trailer_player.dart';

class TitleDetailPage extends StatefulWidget {
  final TitleModel title;

  const TitleDetailPage({super.key, required this.title});

  @override
  State<TitleDetailPage> createState() => _TitleDetailPageState();
}

class _TitleDetailPageState extends State<TitleDetailPage> {
  final _service = TmdbService();
  late Future<(List<StreamingProviderModel>, String?)> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = Future.wait([
      _service.getWatchProviders(widget.title.id, widget.title.mediaType),
      _service.getTrailerKey(widget.title.id, widget.title.mediaType),
    ]).then((results) => (
          results[0] as List<StreamingProviderModel>,
          results[1] as String?,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    return isWide ? _WideLayout(title: widget.title, dataFuture: _dataFuture)
                  : _NarrowLayout(title: widget.title, dataFuture: _dataFuture);
  }
}

// ─── Layout Desktop ───────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final TitleModel title;
  final Future<(List<StreamingProviderModel>, String?)> dataFuture;

  const _WideLayout({required this.title, required this.dataFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.name, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF0D0D0D),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna esquerda: poster
          SizedBox(
            width: 240,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    title.posterUrl,
                    fit: BoxFit.cover,
                    width: 240,
                    errorBuilder: (_, __, ___) => Container(
                      height: 360,
                      width: 240,
                      color: Colors.grey[850],
                      child: const Icon(Icons.broken_image,
                          color: Colors.white38, size: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FutureBuilder<(List<StreamingProviderModel>, String?)>(
                    future: dataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                            height: 40,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      final providers = snapshot.data?.$1 ?? [];
                      if (providers.isEmpty) return const SizedBox.shrink();
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Assistir agora'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _showWatchSheet(context, providers),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Coluna direita: conteúdo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              child: FutureBuilder<(List<StreamingProviderModel>, String?)>(
                future: dataFuture,
                builder: (context, snapshot) {
                  final trailerKey = snapshot.data?.$2;
                  final providers = snapshot.data?.$1 ?? [];
                  return _ContentColumn(
                    title: title,
                    trailerKey: trailerKey,
                    providers: providers,
                    isWide: true,
                    onWatch: () => _showWatchSheet(context, providers),
                    loading: snapshot.connectionState == ConnectionState.waiting,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWatchSheet(BuildContext context, List<StreamingProviderModel> providers) {
    final sorted = [...providers]..sort((a, b) {
        final aConn = StreamingAccountService.isConnected(a.normalizedName) ? 0 : 1;
        final bConn = StreamingAccountService.isConnected(b.normalizedName) ? 0 : 1;
        return aConn.compareTo(bConn);
      });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WatchModal(title: title, providers: sorted),
    );
  }
}

// ─── Layout Mobile ────────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final TitleModel title;
  final Future<(List<StreamingProviderModel>, String?)> dataFuture;

  const _NarrowLayout({required this.title, required this.dataFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'poster-${title.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(title.posterUrl, fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<(List<StreamingProviderModel>, String?)>(
              future: dataFuture,
              builder: (context, snapshot) {
                final trailerKey = snapshot.data?.$2;
                final providers = snapshot.data?.$1 ?? [];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: _ContentColumn(
                    title: title,
                    trailerKey: trailerKey,
                    providers: providers,
                    isWide: false,
                    loading: snapshot.connectionState == ConnectionState.waiting,
                    onWatch: () {
                      final sorted = [...providers]..sort((a, b) {
                          final aConn = StreamingAccountService.isConnected(a.normalizedName) ? 0 : 1;
                          final bConn = StreamingAccountService.isConnected(b.normalizedName) ? 0 : 1;
                          return aConn.compareTo(bConn);
                        });
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.grey[900],
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => _WatchModal(title: title, providers: sorted),
                      );
                    },
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

// ─── Conteúdo compartilhado ───────────────────────────────────────────────────

class _ContentColumn extends StatelessWidget {
  final TitleModel title;
  final String? trailerKey;
  final List<StreamingProviderModel> providers;
  final bool isWide;
  final bool loading;
  final VoidCallback onWatch;

  const _ContentColumn({
    required this.title,
    required this.trailerKey,
    required this.providers,
    required this.isWide,
    required this.loading,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWide) ...[
          Text(
            title.name,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title.mediaType == 'tv' ? 'Série' : 'Filme',
          style: TextStyle(
              fontSize: 12, color: Colors.grey[500], letterSpacing: 1),
        ),
        // Trailer
        if (trailerKey != null) ...[
          const SizedBox(height: 20),
          const Text('Trailer',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
          const SizedBox(height: 10),
          TrailerPlayer(videoKey: trailerKey!),
        ] else if (loading) ...[
          const SizedBox(height: 20),
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
        // Sinopse
        if (title.overview.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Sinopse',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            title.overview,
            style: TextStyle(
                color: Colors.grey[400], fontSize: 13, height: 1.6),
          ),
        ],
        // Providers inline (desktop) ou botão (mobile)
        const SizedBox(height: 24),
        if (isWide && providers.isNotEmpty) ...[
          const Text('Disponível em:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
          const SizedBox(height: 12),
          _InlineProviders(providers: providers, titleName: title.name),
        ] else if (!isWide) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Assistir agora',
                  style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: loading ? null : onWatch,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Providers inline (desktop) ───────────────────────────────────────────────

class _InlineProviders extends StatelessWidget {
  final List<StreamingProviderModel> providers;
  final String titleName;

  const _InlineProviders(
      {required this.providers, required this.titleName});

  @override
  Widget build(BuildContext context) {
    final sorted = [...providers]..sort((a, b) {
        final aConn = StreamingAccountService.isConnected(a.normalizedName) ? 0 : 1;
        final bConn = StreamingAccountService.isConnected(b.normalizedName) ? 0 : 1;
        return aConn.compareTo(bConn);
      });

    return Column(
      children: sorted.map((p) => _ProviderRow(
            provider: p,
            titleName: titleName,
            context: context,
          )).toList(),
    );
  }
}

// ─── Modal Assistir (mobile) ──────────────────────────────────────────────────

class _WatchModal extends StatelessWidget {
  final TitleModel title;
  final List<StreamingProviderModel> providers;

  const _WatchModal({required this.title, required this.providers});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Disponível em:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (providers.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tv_off, color: Colors.grey[600], size: 40),
                      const SizedBox(height: 12),
                      Text('Não disponível em streaming no Brasil',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: providers.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (ctx, i) => _ProviderRow(
                    provider: providers[i],
                    titleName: title.name,
                    context: ctx,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Provider Row (compartilhado) ─────────────────────────────────────────────

class _ProviderRow extends StatelessWidget {
  final StreamingProviderModel provider;
  final String titleName;
  final BuildContext context;

  const _ProviderRow({
    required this.provider,
    required this.titleName,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final isConnected =
        StreamingAccountService.isConnected(provider.normalizedName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              provider.logoUrl,
              height: 40,
              width: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 40,
                width: 40,
                color: Colors.grey[800],
                child: const Icon(Icons.play_circle,
                    color: Colors.white38, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.providerName,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                if (!isConnected)
                  Text('Conta não conectada',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isConnected)
            ElevatedButton(
              onPressed: () async {
                await StreamingAccountService.recordUsage(
                    provider.normalizedName);
                await DeepLinkService.watchTitle(
                    provider.normalizedName, titleName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Assistir', style: TextStyle(fontSize: 13)),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectStreamingPage(
                          providerName: provider.normalizedName,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Conectar',
                      style:
                          TextStyle(fontSize: 12, color: Colors.white70)),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: () => DeepLinkService.openSignup(
                      provider.normalizedName),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                        color: Colors.blueAccent.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Criar conta',
                      style: TextStyle(
                          fontSize: 12, color: Colors.blueAccent)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
