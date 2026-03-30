import 'package:flutter/material.dart';
import '../../core/models/title_model.dart';
import '../../core/models/streaming_account_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/tmdb_service.dart';
import '../../core/services/streaming_account_service.dart';
import '../../core/services/deep_link_service.dart';
import '../settings/my_streamings_page.dart';
import '../title/title_detail_page.dart';
import 'widgets/title_poster_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const HomePage({super.key, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          _CatalogTab(),
          const MyStreamingsPage(),
          _ProfileTab(onLogout: widget.onLogout),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined),
            activeIcon: Icon(Icons.subscriptions),
            label: 'Streamings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ─── Catálogo ────────────────────────────────────────────────────────────────

class _CatalogTab extends StatefulWidget {
  @override
  State<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<_CatalogTab> {
  final _service = TmdbService();
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  late Future<List<List<TitleModel>>> _sectionsFuture;
  Future<List<TitleModel>>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  void _loadSections() {
    _sectionsFuture = Future.wait([
      _service.getTrending(),
      _service.getPopularMovies(),
      _service.getPopularTV(),
    ]);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    if (q.trim().isEmpty) return;
    setState(() {
      _searchFuture = _service.search(q.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final inactive = StreamingAccountService.getInactiveAccounts();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar filmes e séries...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: _search,
              )
            : const Text('InfiniStream'),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _searching = false;
                _searchFuture = null;
                _searchCtrl.clear();
              }),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
        ],
      ),
      body: _searching && _searchFuture != null
          ? _SearchResults(future: _searchFuture!)
          : _MainCatalog(
              sectionsFuture: _sectionsFuture,
              inactiveAccounts: inactive,
              onReload: () => setState(_loadSections),
            ),
    );
  }
}

class _MainCatalog extends StatelessWidget {
  final Future<List<List<TitleModel>>> sectionsFuture;
  final List<StreamingAccountModel> inactiveAccounts;
  final VoidCallback onReload;

  const _MainCatalog({
    required this.sectionsFuture,
    required this.inactiveAccounts,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<TitleModel>>>(
      future: sectionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Erro ao carregar.\nVerifique sua chave TMDB.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: onReload,
                    child: const Text('Tentar novamente')),
              ],
            ),
          );
        }

        final sections = snapshot.data!;

        return ListView(
          children: [
            ...inactiveAccounts.map((a) => _InactivityBanner(account: a)),
            if (sections[0].isNotEmpty) ...[
              const _SectionHeader('Em alta esta semana'),
              _HorizontalPosterList(titles: sections[0]),
            ],
            if (sections[1].isNotEmpty) ...[
              const _SectionHeader('Filmes populares'),
              _HorizontalPosterList(titles: sections[1]),
            ],
            if (sections[2].isNotEmpty) ...[
              const _SectionHeader('Séries populares'),
              _HorizontalPosterList(titles: sections[2]),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final Future<List<TitleModel>> future;

  const _SearchResults({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TitleModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Text('Nenhum resultado encontrado.',
                style: TextStyle(color: Colors.grey[500])),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: results.length,
          itemBuilder: (context, i) {
            final title = results[i];
            return TitlePosterCard(
              title: title,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TitleDetailPage(title: title)),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HorizontalPosterList extends StatelessWidget {
  final List<TitleModel> titles;

  const _HorizontalPosterList({required this.titles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: titles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final title = titles[i];
          return SizedBox(
            width: 100,
            child: TitlePosterCard(
              title: title,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TitleDetailPage(title: title)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InactivityBanner extends StatelessWidget {
  final StreamingAccountModel account;

  const _InactivityBanner({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sem uso em ${account.providerName} há ${account.daysSinceLastUse} dias',
              style: const TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => _showCancelDialog(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
          ),
          GestureDetector(
            onTap: () async {
              await StreamingAccountService.snoozeAlert(account.providerName);
            },
            child: const Icon(Icons.close, size: 16, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancelar ${account.providerName}?'),
        content: Text(
          'Você não usa ${account.providerName} há ${account.daysSinceLastUse} dias.\n\n'
          'Você será redirecionado para a página de cancelamento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Manter'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DeepLinkService.openCancellation(account.providerName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Cancelar assinatura'),
          ),
        ],
      ),
    );
  }
}

// ─── Perfil ───────────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final connected = StreamingAccountService.getConnectedAccounts();
    final inactive = StreamingAccountService.getInactiveAccounts();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              Text(
                user.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  value: '${connected.length}',
                  label: 'Streamings\nAtivos',
                  icon: Icons.subscriptions,
                  color: Colors.redAccent,
                ),
                _StatCard(
                  value: '${inactive.length}',
                  label: 'Sem uso\n+30 dias',
                  icon: Icons.warning_amber,
                  color: inactive.isNotEmpty ? Colors.orange : Colors.grey,
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sair',
                    style: TextStyle(color: Colors.red, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
