import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/article.dart';
import '../../providers/favorites_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final favState = ref.watch(favoritesProvider);
    final isFav = favState.favoriteKeys.contains(article.uniqueKey);

    // Build full article content from available data
    final fullContent = _buildFullContent();

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          // --- Hero Image with overlay controls ---
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: c.background,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            actions: [
              _AppBarAction(
                icon: Icons.share_outlined,
                onTap: () {
                  if (article.url != null) {
                    SharePlus.instance.share(
                      ShareParams(
                        text: '${article.title}\n${article.url}',
                      ),
                    );
                  }
                },
              ),
              _AppBarAction(
                icon: isFav ? Icons.bookmark : Icons.bookmark_border,
                onTap: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(article);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? 'Removed from bookmarks'
                            : 'Saved to bookmarks',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: c.surface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _AppBarAction(
                icon: Icons.more_horiz,
                onTap: () => _showMoreSheet(context),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.urlToImage != null)
                    CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: c.surface,
                        child: Icon(Icons.image,
                            color: c.textSecondary, size: 64),
                      ),
                    )
                  else
                    Container(
                      color: c.surface,
                      child: Icon(Icons.article,
                          color: c.textSecondary, size: 64),
                    ),
                  // Bottom gradient for smooth transition
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            c.background,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Article Content (full in-app, no redirect) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Source Row ---
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Text(
                            (article.sourceName ?? 'N')[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.sourceName ?? 'News',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  DateFormatter.timeAgo(article.publishedAt),
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                if (article.author != null) ...[
                                  Text(' \u2022 ',
                                      style: TextStyle(
                                          color: c.textSecondary,
                                          fontSize: 12)),
                                  Flexible(
                                    child: Text(
                                      article.author!,
                                      style: TextStyle(
                                        color: c.textSecondary,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Title ---
                  Text(
                    article.title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Reading info (inline, clean single row) ---
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${(fullContent.length / 1000).ceil()} min read',
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('\u2022',
                            style: TextStyle(color: c.textSecondary, fontSize: 13)),
                      ),
                      Text(
                        DateFormatter.formatDate(article.publishedAt),
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                      if (article.sourceName != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('\u2022',
                              style: TextStyle(color: c.textSecondary, fontSize: 13)),
                        ),
                        Flexible(
                          child: Text(
                            article.sourceName!,
                            style: TextStyle(color: c.textSecondary, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Full Article Content (in-app) ---
                  ...fullContent.split('\n\n').map((paragraph) {
                    if (paragraph.trim().isEmpty) {
                      return const SizedBox(height: 8);
                    }
                    // Check if it's a quote
                    if (paragraph.startsWith('"') ||
                        paragraph.startsWith('\u201C')) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppTheme.primary.withValues(alpha: 0.6),
                                width: 3,
                              ),
                            ),
                            color: c.surface.withValues(alpha: 0.5),
                          ),
                          child: Text(
                            paragraph,
                            style: TextStyle(
                              color:
                                  c.textPrimary.withValues(alpha: 0.9),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              height: 1.7,
                            ),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        paragraph.trim(),
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 15,
                          height: 1.7,
                          letterSpacing: 0.1,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // --- Read Full Article Button (opens in-app) ---
                  if (article.url != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _InAppArticleView(
                                url: article.url!,
                                title: article.sourceName ?? 'Article',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.article_outlined, size: 18),
                        label: Text(
                          'Read Full Article on ${article.sourceName ?? "Source"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // --- Tags ---
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _generateTags()
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // (Action bar and source attribution removed — read full article button is enough)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Strip all HTML tags from text
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Build full article content from available fields
  String _buildFullContent() {
    final buffer = StringBuffer();

    if (article.description != null && article.description!.isNotEmpty) {
      buffer.writeln(_stripHtml(article.description!));
      buffer.writeln();
    }

    if (article.content != null && article.content!.isNotEmpty) {
      // Remove the "[+XXX chars]" truncation marker and strip HTML
      var cleanContent = article.content!
          .replaceAll(RegExp(r'\[\+\d+ chars\]'), '')
          .trim();
      cleanContent = _stripHtml(cleanContent);

      // Only add if different from description
      final cleanDesc = article.description != null
          ? _stripHtml(article.description!)
          : '';
      if (cleanContent != cleanDesc && cleanContent.isNotEmpty) {
        buffer.writeln(cleanContent);
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }

  List<String> _generateTags() {
    final words = article.title.split(' ');
    final tags = <String>[];
    for (final w in words) {
      final clean = w.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (clean.length > 4 && tags.length < 5) {
        tags.add(clean);
      }
    }
    return tags;
  }

  void _showMoreSheet(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _sheetItem(Icons.text_increase, 'Increase Font Size', c),
            _sheetItem(Icons.text_decrease, 'Decrease Font Size', c),
            _sheetItem(Icons.report_outlined, 'Report Article', c),
            _sheetItem(Icons.block, 'Block Source', c),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sheetItem(IconData icon, String label, AppColors c) {
    return ListTile(
      leading: Icon(icon, color: c.textSecondary),
      title: Text(label,
          style: TextStyle(color: c.textPrimary, fontSize: 15)),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

/// In-app WebView to read full article without leaving the app.
/// Uses webview_flutter on mobile; on web falls back to url_launcher.
class _InAppArticleView extends StatefulWidget {
  final String url;
  final String title;

  const _InAppArticleView({required this.url, required this.title});

  @override
  State<_InAppArticleView> createState() => _InAppArticleViewState();
}

class _InAppArticleViewState extends State<_InAppArticleView> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } else {
      // On web, open externally and pop back
      Future.microtask(() async {
        final uri = Uri.parse(widget.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Web platform: show brief loading then pops (handled in initState)
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: c.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.title,
          style: TextStyle(color: c.textPrimary, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser, color: c.textSecondary),
            onPressed: () async {
              final uri = Uri.parse(widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}
