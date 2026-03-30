import 'package:flutter/material.dart';
import '../../core/constants/streaming_constants.dart';
import '../../core/models/streaming_account_model.dart';
import '../../core/services/streaming_account_service.dart';
import '../../core/services/deep_link_service.dart';
import '../streaming/connect_streaming_page.dart';

class MyStreamingsPage extends StatefulWidget {
  const MyStreamingsPage({super.key});

  @override
  State<MyStreamingsPage> createState() => _MyStreamingsPageState();
}

class _MyStreamingsPageState extends State<MyStreamingsPage> {
  List<StreamingAccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _accounts = StreamingAccountService.getAllAccounts();
    });
  }

  Future<void> _disconnect(String providerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desconectar $providerName'),
        content: const Text(
            'Sua conta será removida do app. Você não perderá sua assinatura.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StreamingAccountService.disconnectAccount(providerName);
      _reload();
    }
  }

  Future<void> _cancelSubscription(String providerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancelar $providerName'),
        content: Text(
            'Você será redirecionado para a página de cancelamento do $providerName.\n\nDeseja continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DeepLinkService.openCancellation(providerName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Após cancelar, desconecte sua conta $providerName do app.'),
            action: SnackBarAction(
              label: 'Desconectar',
              onPressed: () => _disconnect(providerName),
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _accounts.where((a) => a.isConnected).toList();
    final disconnected = _accounts.where((a) => !a.isConnected).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Streamings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (connected.isNotEmpty) ...[
            _sectionHeader('Contas conectadas', connected.length),
            const SizedBox(height: 8),
            ...connected.map((a) => _ConnectedCard(
                  account: a,
                  onDisconnect: () => _disconnect(a.providerName),
                  onCancel: () => _cancelSubscription(a.providerName),
                )),
            const SizedBox(height: 24),
          ],
          _sectionHeader(
              'Adicionar streaming', disconnected.length),
          const SizedBox(height: 8),
          ...disconnected.map((a) => _DisconnectedCard(
                account: a,
                onConnect: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConnectStreamingPage(
                        providerName: a.providerName,
                      ),
                    ),
                  );
                  if (result == true) _reload();
                },
                onSignup: () => DeepLinkService.openSignup(a.providerName),
              )),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ),
      ],
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  final StreamingAccountModel account;
  final VoidCallback onDisconnect;
  final VoidCallback onCancel;

  const _ConnectedCard({
    required this.account,
    required this.onDisconnect,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final info = StreamingConstants.getInfo(account.providerName);
    final color = info?.primaryColor ?? Colors.grey;
    final inactive = account.isInactive;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: inactive
              ? Colors.orange.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: inactive ? Colors.orange : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  account.providerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'disconnect') onDisconnect();
                    if (v == 'cancel') onCancel();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'disconnect',
                      child: Row(children: [
                        Icon(Icons.link_off, size: 18),
                        SizedBox(width: 8),
                        Text('Desconectar do app'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(children: [
                        Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancelar assinatura',
                            style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            if (account.userEmail != null) ...[
              const SizedBox(height: 4),
              Text(
                account.userEmail!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
            if (inactive) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange,
                        size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Sem uso há ${account.daysSinceLastUse} dias',
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        foregroundColor: Colors.orange,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DisconnectedCard extends StatelessWidget {
  final StreamingAccountModel account;
  final VoidCallback onConnect;
  final VoidCallback onSignup;

  const _DisconnectedCard({
    required this.account,
    required this.onConnect,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    final info = StreamingConstants.getInfo(account.providerName);
    final color = info?.primaryColor ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 8,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          account.providerName,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          'Não conectado',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onSignup,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Criar conta', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Conectar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
