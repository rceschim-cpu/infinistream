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

// ─── Categoria ────────────────────────────────────────────────────────────────

class _Category {
  final String label;
  final bool isAll;
  final String? fixedMediaType; // 'movie' | 'tv' | null (ambos)
  final int? movieGenreId;
  final int? tvGenreId;

  const _Category({
    required this.label,
    this.isAll = false,
    this.fixedMediaType,
    this.movieGenreId,
    this.tvGenreId,
  });

  // Retorna lista de seções: [sectionLabel, List<TitleModel>]
  Future<List<(String, List<TitleModel>)>> load(TmdbService svc) async {
    if (fixedMediaType == 'movie') {
      final r = await svc.discover(mediaType: 'movie', genreId: movieGenreId);
      return [('Filmes', r)];
    }
    if (fixedMediaType == 'tv') {
      final r = await svc.discover(mediaType: 'tv', genreId: tvGenreId);
      return [('Séries', r)];
    }
    // Ambos
    final futures = <Future<List<TitleModel>>>[];
    if (movieGenreId != null) {
      futures.add(svc.discover(mediaType: 'movie', genreId: movieGenreId));
    }
    if (tvGenreId != null) {
      futures.add(svc.discover(mediaType: 'tv', genreId: tvGenreId));
    }
    final results = await Future.wait(futures);
    final sections = <(String, List<TitleModel>)>[];
    if (movieGenreId != null && results.isNotEmpty) {
      sections.add(('Filmes — $label', results[0]));
    }
    if (tvGenreId != null && results.length > 1) {
      sections.add(('Séries — $label', results[1]));
    } else if (tvGenreId != null && results.length == 1) {
      sections.add(('Séries — $label', results[0]));
    }
    return sections;
  }

  static const all = _Category(label: 'Todos', isAll: true);

  static const list = <_Category>[
    _Category(label: 'Todos', isAll: true),
    _Category(label: 'Filmes', fixedMediaType: 'movie'),
    _Category(label: 'Séries', fixedMediaType: 'tv'),
    _Category(label: 'Ação', movieGenreId: 28, tvGenreId: 10759),
    _Category(label: 'Comédia', movieGenreId: 35, tvGenreId: 35),
    _Category(label: 'Drama', movieGenreId: 18, tvGenreId: 18),
    _Category(label: 'Animação', movieGenreId: 16, tvGenreId: 16),
    _Category(label: 'Terror', movieGenreId: 27),
    _Category(label: 'Ficção Científica', movieGenreId: 878, tvGenreId: 10765),
    _Category(label: 'Aventura', movieGenreId: 12, tvGenreId: 10759),
    _Category(label: 'Crime', movieGenreId: 80, tvGenreId: 80),
    _Category(label: 'Documentário', movieGenreId: 99, tvGenreId: 99),
    _Category(label: 'Romance', movieGenreId: 10749),
    _Category(label: 'Família', movieGenreId: 10751, tvGenreId: 10751),
    _Category(label: 'Suspense', movieGenreId: 53),
    _Category(label: 'Guerra', movieGenreId: 10752, tvGenreId: 10768),
  ];
}

// ─── Home Page ────────────────────────────────────────────────────────────────

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

// ─── Aba Catálogo ─────────────────────────────────────────────────────────────

class _CatalogTab extends StatefulWidget {
  @override
  State<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<_CatalogTab> {
  final _service = TmdbService();
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  _Category _selected = _Category.all;
  late Future<List<List<TitleModel>>> _homeFuture;
  Future<List<(String, List<TitleModel>)>>? _categoryFuture;
  Future<List<TitleModel>>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHome();
  }

  Future<List<List<TitleModel>>> _loadHome() => Future.wait([
        _service.getTrending(),
        _service.getPopularMovies(),
        _service.getPopularTV(),
      ]);

  void _selectCategory(_Category cat) {
    setState(() {
      _selected = cat;
      _searching = false;
      _searchFuture = null;
      _searchCtrl.clear();
      if (!cat.isAll) {
        _categoryFuture = cat.load(_service);
      }
    });
  }

  void _search(String q) {
    if (q.trim().isEmpty) return;
    setState(() => _searchFuture = _service.search(q.trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
        bottom: _searching
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: _CategoryChips(
                  selected: _selected,
                  onSelect: _selectCategory,
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
          : _selected.isAll
              ? _HomeContent(
                  future: _homeFuture,
                  inactiveAccounts: inactive,
                  onReload: () => setState(() => _homeFuture = _loadHome()),
                )
              : _CategoryContent(
                  future: _categoryFuture!,
                  categoryLabel: _selected.label,
                ),
    );
  }
}

// ─── Chips de categoria ───────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final _Category selected;
  final void Function(_Category) onSelect;

  const _CategoryChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _Category.list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _Category.list[i];
          final isSelected = selected.label == cat.label;
          return FilterChip(
            label: Text(cat.label),
            selected: isSelected,
            onSelected: (_) => onSelect(cat),
            backgroundColor: Colors.grey[900],
            selectedColor: Colors.redAccent,
            checkmarkColor: Colors.white,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected
                  ? Colors.redAccent
                  : Colors.grey[700]!,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          );
        },
      ),
    );
  }
}

// ─── Conteúdo "Todos" (home padrão) ──────────────────────────────────────────

class _HomeContent extends StatelessWidget {
  final Future<List<List<TitleModel>>> future;
  final List<StreamingAccountModel> inactiveAccounts;
  final VoidCallback onReload;

  const _HomeContent({
    required this.future,
    required this.inactiveAccounts,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<TitleModel>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(onRetry: onReload);
        }
        final s = snapshot.data!;
        return ListView(
          children: [
            ...inactiveAccounts.map((a) => _InactivityBanner(account: a)),
            if (s[0].isNotEmpty) ...[
              const _SectionHeader('Em alta esta semana'),
              _HorizontalPosterList(titles: s[0]),
            ],
            if (s[1].isNotEmpty) ...[
              const _SectionHeader('Filmes populares'),
              _HorizontalPosterList(titles: s[1]),
            ],
            if (s[2].isNotEmpty) ...[
              const _SectionHeader('Séries populares'),
              _HorizontalPosterList(titles: s[2]),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

// ─── Conteúdo de categoria/gênero ────────────────────────────────────────────

class _CategoryContent extends StatelessWidget {
  final Future<List<(String, List<TitleModel>)>> future;
  final String categoryLabel;

  const _CategoryContent({
    required this.future,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<(String, List<TitleModel>)>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(onRetry: () {});
        }
        final sections = snapshot.data ?? [];
        if (sections.isEmpty || sections.every((s) => s.$2.isEmpty)) {
          return Center(
            child: Text(
              'Nenhum título encontrado em "$categoryLabel".',
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }

        return ListView(
          children: [
            for (final section in sections)
              if (section.$2.isNotEmpty) ...[
                _SectionHeader(section.$1),
                _AdaptiveGrid(titles: section.$2),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 32),
          ],
        );
      },
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
                Text('Nenhum resultado.',
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            MaterialPageRoute(
                builder: (_) => TitleDetailPage(title: title)),
          ),
        );
      },
    );
  }
}

// ─── Seção horizontal (home padrão) ──────────────────────────────────────────

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

  double _width(BuildContext context) =>
      MediaQuery.of(context).size.width >= 720 ? 130 : 100;
  double _height(BuildContext context) =>
      MediaQuery.of(context).size.width >= 720 ? 195 : 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: titles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final title = titles[i];
          return SizedBox(
            width: _width(context),
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

// ─── Banner inatividade ───────────────────────────────────────────────────────

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
            onTap: () =>
                StreamingAccountService.snoozeAlert(account.providerName),
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

// ─── Erro ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

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
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifique sua chave TMDB em\nlib/core/constants/app_constants.dart',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 13),
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
                  child:
                      Icon(Icons.person, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  Text(
                    user.displayName ?? user.email ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 14),
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
                      color: inactive.isNotEmpty
                          ? Colors.orange
                          : Colors.grey,
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLogout,
                    icon:
                        const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sair',
                        style: TextStyle(
                            color: Colors.red, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color),
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
