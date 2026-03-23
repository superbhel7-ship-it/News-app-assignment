import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';

class _Channel {
  final String name;
  final String channelId;
  final String logoLetter;
  final Color color;

  const _Channel({
    required this.name,
    required this.channelId,
    required this.logoLetter,
    required this.color,
  });

  /// Direct YouTube live URL - loads channel's live stream page
  String get liveUrl => 'https://m.youtube.com/channel/$channelId/live';
}

const _channels = [
  _Channel(name: 'NDTV 24x7', channelId: 'UCZFMm1MIBBIFcYRFpOaJl6Q', logoLetter: 'N', color: Color(0xFFE53935)),
  _Channel(name: 'India Today', channelId: 'UCYPvAwZP8pZhSMW8qs7cVCw', logoLetter: 'IT', color: Color(0xFF1565C0)),
  _Channel(name: 'Republic TV', channelId: 'UCwqusr8YDwM-0gEgqUOZJVw', logoLetter: 'R', color: Color(0xFF0D47A1)),
  _Channel(name: 'Aaj Tak', channelId: 'UCt4t-jeY85JegMlZ-E5UWtA', logoLetter: 'AT', color: Color(0xFFFF6F00)),
  _Channel(name: 'Times Now', channelId: 'UCz8QaiQxApLq8sLNcszYyJw', logoLetter: 'TN', color: Color(0xFF283593)),
  _Channel(name: 'CNN-News18', channelId: 'UCef1-8eOpJgud7szVPlZQAQ', logoLetter: 'CN', color: Color(0xFFC62828)),
  _Channel(name: 'WION', channelId: 'UC_gUM8rL-Lrg6O3adPW9K1g', logoLetter: 'W', color: Color(0xFF00695C)),
  _Channel(name: 'DD News', channelId: 'UCKOiABHkPa0R5FYJ1CiCgug', logoLetter: 'DD', color: Color(0xFF4527A0)),
  _Channel(name: 'TV9 Bharatvarsh', channelId: 'UCjJxOEBSRHyimMBJp2bMFHQ', logoLetter: 'TV9', color: Color(0xFFE65100)),
  _Channel(name: 'ABP News', channelId: 'UCRWFSbif-RFpaX4HPSoufAQ', logoLetter: 'ABP', color: Color(0xFFD84315)),
  _Channel(name: 'Zee News', channelId: 'UCIvaYmXn910QMdemBG3v1pQ', logoLetter: 'Z', color: Color(0xFFAD1457)),
  _Channel(name: 'News18 India', channelId: 'UCaq267jDM2suE0G7VICfBPQ', logoLetter: 'N18', color: Color(0xFF1B5E20)),
];

class LiveTvScreen extends StatelessWidget {
  const LiveTvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
            const SizedBox(width: 8),
            Text('Live TV', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85,
          ),
          itemCount: _channels.length,
          itemBuilder: (context, index) => _ChannelTile(channel: _channels[index], c: c),
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final _Channel channel;
  final AppColors c;
  const _ChannelTile({required this.channel, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _LivePlayerScreen(channel: channel))),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.divider.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: channel.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(channel.logoLetter, style: TextStyle(color: channel.color, fontSize: channel.logoLetter.length > 2 ? 14 : 18, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(channel.name, style: TextStyle(color: c.textPrimary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                const SizedBox(width: 4),
                Text('LIVE', style: TextStyle(color: Colors.red.shade400, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePlayerScreen extends StatefulWidget {
  final _Channel channel;
  const _LivePlayerScreen({required this.channel});

  @override
  State<_LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<_LivePlayerScreen> {
  WebViewController? _mobileController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initMobileWebView();
    }
  }

  void _initMobileWebView() {
    _mobileController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) { if (mounted) setState(() => _isLoading = false); },
      ))
      ..loadRequest(Uri.parse(widget.channel.liveUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.channel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: kIsWeb ? _webPlayer() : _mobilePlayer(),
    );
  }

  Widget _webPlayer() {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as dynamic;
        iframe.src = widget.channel.liveUrl;
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.allow = 'autoplay; encrypted-media; picture-in-picture; fullscreen';
      },
    );
  }

  Widget _mobilePlayer() {
    if (_mobileController == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2));
    }
    return Stack(
      children: [
        WebViewWidget(controller: _mobileController!),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
      ],
    );
  }
}
