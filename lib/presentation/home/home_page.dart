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

  static const _destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Início'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.subscriptions_outlined),
      selectedIcon: Icon(Icons.subscriptions),
      label: Text('Streamings'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Perfil'),
    ),
  ];

  List<Widget> get _pages => [
        _CatalogTab(),
        const MyStreamingsPage(),
        _ProfileTab(onLogout: widget.onLogout),
      ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: const Color(0xFF0D0D0D),
              selectedIconTheme:
                  const IconThemeData(color: Colors.redAccent),
              selectedLabelTextStyle:
                  const TextStyle(color: Colors.redAccent),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'IS',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              destinations: _destinations,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(index: _tab, children: _pages),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: const Color(0xFF0D0D0D),
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
    setState(() => _searchFuture = _service.search(q.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final inactive = StreamingAccountService.getInactiveAccounts();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar filmes e séries...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onSubmitted: _search,
              )
            : const Text(
                'InfiniStream',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
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
          const SizedBox(width: 8),
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

// ─── Catálogo principal ───────────────────────────────────────────────────────

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
          return _ErrorView(error: snapshot.error.toString(), onRetry: onReload);
        }

        final sections = snapshot.data!;

        return ListView(
          children: [
            ...inactiveAccounts.map((a) => _InactivityBanner(account: a)),
            if (sections[0].isNotEmpty) ...[
              _SectionHeader('Em alta esta semana'),
              _HorizontalPosterList(titles: sections[0]),
            ],
            if (sections[1].isNotEmpty) ...[
              _SectionHeader('Filmes populares'),
              _HorizontalPosterList(titles: sections[1]),
            ],
            if (sections[2].isNotEmpty) ...[
              _SectionHeader('Séries populares'),
              _HorizontalPosterList(titles: sections[2]),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar o catálogo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifique sua chave da API TMDB em\nlib/core/constants/app_constants.dart',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Busca ────────────────────────────────────────────────────────────────────

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Nenhum resultado encontrado.',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return _AdaptiveGrid(titles: results);
      },
    );
  }
}

// ─── Grid adaptivo ────────────────────────────────────────────────────────────

class _AdaptiveGrid extends StatelessWidget {
  final List<TitleModel> titles;

  const _AdaptiveGrid({required this.titles});

  int _columns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 8;
    if (w >= 1100) return 6;
    if (w >= 800) return 5;
    if (w >= 600) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns(context),
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: titles.length,
      itemBuilder: (context, i) {
        final title = titles[i];
        return TitlePosterCard(
          title: title,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TitleDetailPage(title: title)),
          ),
        );
      },
    );
  }
}

// ─── Seções horizontais ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _HorizontalPosterList extends StatelessWidget {
  final List<TitleModel> titles;

  const _HorizontalPosterList({required this.titles});

  double _posterWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 720 ? 130 : 100;
  }

  double _posterHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 720 ? 195 : 150;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _posterHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: titles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final title = titles[i];
          return SizedBox(
            width: _posterWidth(context),
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

// ─── Banner de inatividade ────────────────────────────────────────────────────

class _InactivityBanner extends StatelessWidget {
  final StreamingAccountModel account;

  const _InactivityBanner({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
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
              '${account.providerName} sem uso há ${account.daysSinceLastUse} dias',
              style: const TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => _showCancelDialog(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
          ),
          GestureDetector(
            onTap: () => StreamingAccountService.snoozeAlert(account.providerName),
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.close, size: 16, color: Colors.white38),
            ),
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
          'Sem uso há ${account.daysSinceLastUse} dias.\n\n'
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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
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
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('Perfil'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 24,
              vertical: 32,
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.person, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      value: '${connected.length}',
                      label: 'Ativos',
                      icon: Icons.subscriptions,
                      color: Colors.redAccent,
                    ),
                    _StatCard(
                      value: '${inactive.length}',
                      label: 'Inativos',
                      icon: Icons.warning_amber,
                      color:
                          inactive.isNotEmpty ? Colors.orange : Colors.grey,
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
                        style:
                            TextStyle(color: Colors.red, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
