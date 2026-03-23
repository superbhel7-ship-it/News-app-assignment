import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/theme_colors.dart';

/// Full home page shimmer — stories + market + trending + world
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: c.shimmerBase,
        highlightColor: c.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // --- Stories shimmer ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _shimmerBox(80, 14, radius: 4),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Market ticker shimmer ---
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Hot News header shimmer ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(100, 22, radius: 4),
                      const SizedBox(height: 6),
                      _shimmerBox(140, 12, radius: 4),
                    ],
                  ),
                  _shimmerBox(80, 12, radius: 4),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Trending cards shimmer ---
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => Container(
                  width: 290,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Topics shimmer ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _shimmerBox(60, 18, radius: 4),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  6,
                  (_) => _shimmerBox(70, 32, radius: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- World articles shimmer ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(60, 18, radius: 4),
                  _shimmerBox(40, 14, radius: 4),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (_) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(80, 10, radius: 4),
                          const SizedBox(height: 8),
                          _shimmerBox(double.infinity, 14, radius: 4),
                          const SizedBox(height: 4),
                          _shimmerBox(160, 14, radius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerBox(double width, double height, {double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Compact list shimmer for see-all/search pages
class ShimmerCompactLoading extends StatelessWidget {
  const ShimmerCompactLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Shimmer.fromColors(
      baseColor: c.shimmerBase,
      highlightColor: c.shimmerHighlight,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 100,
        ),
      ),
    );
  }
}

/// Error view with retry
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  bool get _isNetworkError =>
      message.toLowerCase().contains('internet') ||
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection') ||
      message.toLowerCase().contains('socket');

  bool get _isEmptyError =>
      message.toLowerCase().contains('no data') ||
      message.toLowerCase().contains('no articles') ||
      message.toLowerCase().contains('empty') ||
      message.toLowerCase().contains('not found');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final IconData icon;
    final String title;
    final String subtitle;

    if (_isNetworkError) {
      icon = Icons.wifi_off_rounded;
      title = 'No Internet Connection';
      subtitle = 'Please check your connection and try again.';
    } else if (_isEmptyError) {
      icon = Icons.article_outlined;
      title = 'No Data Found';
      subtitle = 'No articles available right now. Pull to refresh.';
    } else {
      icon = Icons.error_outline_rounded;
      title = 'Something Went Wrong';
      subtitle = message;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: c.textSecondary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Try Again',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact empty state for inline sections (World, Stories, etc.)
class EmptySection extends StatelessWidget {
  final String message;
  const EmptySection({super.key, this.message = 'No articles available'});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.article_outlined, color: c.textSecondary, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
