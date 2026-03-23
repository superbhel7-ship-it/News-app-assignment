import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import '../screens/market/market_screen.dart';

class MarketTicker extends StatefulWidget {
  const MarketTicker({super.key});

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker> {
  late Timer _timer;
  final _dio = Dio();
  List<_MarketItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Refresh every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final response = await _dio.get(
        'https://api.coingecko.com/api/v3/simple/price',
        queryParameters: {
          'ids': 'bitcoin,ethereum,solana,ripple,dogecoin,cardano',
          'vs_currencies': 'inr',
          'include_24hr_change': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final items = <_MarketItem>[];

        final Map<String, String> nameMap = {
          'bitcoin': 'BTC',
          'ethereum': 'ETH',
          'solana': 'SOL',
          'ripple': 'XRP',
          'dogecoin': 'DOGE',
          'cardano': 'ADA',
        };

        for (final entry in nameMap.entries) {
          final coin = data[entry.key];
          if (coin != null) {
            final price = (coin['inr'] as num).toDouble();
            final change = (coin['inr_24h_change'] as num?)?.toDouble() ?? 0;
            items.add(_MarketItem(entry.value, price, change));
          }
        }

        if (mounted) {
          setState(() {
            _items = items;
            _loading = false;
          });
        }
      }
    } catch (_) {
      // Silently fail — ticker is supplementary
      if (mounted && _items.isEmpty) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MarketScreen()),
          ),
          child: _buildTile(_items[i]),
        ),
      ),
    );
  }

  Widget _buildTile(_MarketItem item) {
    final c = context.colors;
    final isPositive = item.change >= 0;
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPositive
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF5252),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatPrice(item.price),
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${isPositive ? '+' : ''}${item.change.toStringAsFixed(2)}%',
            style: TextStyle(
              color: isPositive
                  ? const Color(0xFF00E676)
                  : const Color(0xFFFF5252),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

class _MarketItem {
  final String name;
  final double price;
  final double change;

  _MarketItem(this.name, this.price, this.change);
}
