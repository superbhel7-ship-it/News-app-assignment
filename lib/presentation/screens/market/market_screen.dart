import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _dio = Dio();
  List<_CoinData> _coins = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  Future<void> _fetchMarketData() async {
    setState(() => _loading = true);
    try {
      final response = await _dio.get(
        'https://api.coingecko.com/api/v3/coins/markets',
        queryParameters: {
          'vs_currency': 'inr',
          'order': 'market_cap_desc',
          'per_page': 20,
          'page': 1,
          'sparkline': true,
          'price_change_percentage': '24h,7d',
        },
      );

      if (response.statusCode == 200) {
        final list = response.data as List;
        setState(() {
          _coins = list.map((c) => _CoinData.fromJson(c)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        centerTitle: true,
        title: Text(
          'Market',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.refresh, color: c.textSecondary, size: 20),
            onPressed: _fetchMarketData,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 2))
          : _coins.isEmpty
              ? Center(
                  child: Text('Failed to load market data',
                      style: TextStyle(color: c.textSecondary)))
              : RefreshIndicator(
                  onRefresh: _fetchMarketData,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _coins.length,
                    itemBuilder: (_, i) => _buildCoinTile(_coins[i], c),
                  ),
                ),
    );
  }

  Widget _buildCoinTile(_CoinData coin, AppColors c) {
    final isPositive = coin.change24h >= 0;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _CoinDetailPage(coin: coin),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: c.divider.withValues(alpha: 0.3), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 24,
              child: Text(
                '${coin.rank}',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                coin.image,
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      coin.symbol.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + symbol
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Sparkline mini chart
            if (coin.sparkline.isNotEmpty)
              SizedBox(
                width: 60,
                height: 30,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    data: coin.sparkline,
                    color: isPositive
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF5252),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // Price + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(coin.price),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF5252))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${coin.change24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF5252),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)}L';
    }
    if (price >= 1000) {
      return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    }
    if (price >= 1) {
      return '₹${price.toStringAsFixed(2)}';
    }
    return '₹${price.toStringAsFixed(4)}';
  }
}

// ─── Coin Detail with TradingView Chart ───
class _CoinDetailPage extends StatelessWidget {
  final _CoinData coin;
  const _CoinDetailPage({required this.coin});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isPositive = coin.change24h >= 0;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(coin.image, width: 24, height: 24,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 24)),
            ),
            const SizedBox(width: 8),
            Text(
              '${coin.name} (${coin.symbol.toUpperCase()})',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price header
            Text(
              '₹${coin.price >= 1000 ? coin.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},') : coin.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF5252),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${coin.change24h.toStringAsFixed(2)}% (24h)',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF5252),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sparkline chart (large)
            if (coin.sparkline.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _SparklinePainter(
                    data: coin.sparkline,
                    color: isPositive
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF5252),
                    strokeWidth: 2.0,
                    fillGradient: true,
                  ),
                  size: Size.infinite,
                ),
              ),

            const SizedBox(height: 24),

            // Stats grid
            Text(
              'Market Stats',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _statRow('Market Cap', _formatLargeNum(coin.marketCap), c),
            _statRow('24h High', '₹${coin.high24h.toStringAsFixed(2)}', c),
            _statRow('24h Low', '₹${coin.low24h.toStringAsFixed(2)}', c),
            _statRow('Rank', '#${coin.rank}', c),
            if (coin.change7d != 0)
              _statRow(
                '7d Change',
                '${coin.change7d >= 0 ? '+' : ''}${coin.change7d.toStringAsFixed(2)}%',
                c,
                valueColor: coin.change7d >= 0
                    ? const Color(0xFF00E676)
                    : const Color(0xFFFF5252),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, AppColors c,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: c.divider.withValues(alpha: 0.3), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: c.textSecondary, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: valueColor ?? c.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  String _formatLargeNum(double n) {
    if (n >= 1e12) return '₹${(n / 1e12).toStringAsFixed(2)}T';
    if (n >= 1e9) return '₹${(n / 1e9).toStringAsFixed(2)}B';
    if (n >= 1e7) return '₹${(n / 1e7).toStringAsFixed(2)}Cr';
    if (n >= 1e5) return '₹${(n / 1e5).toStringAsFixed(2)}L';
    return '₹${n.toStringAsFixed(0)}';
  }
}

// ─── Sparkline Chart Painter ───
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;
  final bool fillGradient;

  _SparklinePainter({
    required this.data,
    required this.color,
    this.strokeWidth = 1.5,
    this.fillGradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Fill gradient below line
    if (fillGradient) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── Data Model ───
class _CoinData {
  final int rank;
  final String name;
  final String symbol;
  final String image;
  final double price;
  final double change24h;
  final double change7d;
  final double marketCap;
  final double high24h;
  final double low24h;
  final List<double> sparkline;

  _CoinData({
    required this.rank,
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
    required this.change24h,
    required this.change7d,
    required this.marketCap,
    required this.high24h,
    required this.low24h,
    required this.sparkline,
  });

  factory _CoinData.fromJson(Map<String, dynamic> json) {
    final sparklineData = json['sparkline_in_7d']?['price'] as List?;
    return _CoinData(
      rank: json['market_cap_rank'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      image: json['image'] ?? '',
      price: (json['current_price'] as num?)?.toDouble() ?? 0,
      change24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      change7d: (json['price_change_percentage_7d_in_currency'] as num?)
              ?.toDouble() ??
          0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0,
      sparkline:
          sparklineData?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }
}
