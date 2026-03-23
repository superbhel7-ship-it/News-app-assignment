import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';

/// Cross-platform network image that works on both web and mobile.
/// Uses Image.network on web (CachedNetworkImage doesn't support web caching)
/// and CachedNetworkImage on mobile for proper disk caching.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget image;

    if (kIsWeb) {
      // Web: use Image.network directly (CachedNetworkImage has issues on web)
      image = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: c.surface,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.primary,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _errorWidget(c),
      );
    } else {
      // Mobile: use CachedNetworkImage for disk caching
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: c.surface,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.primary,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _errorWidget(c),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _errorWidget(AppColors c) {
    return Container(
      width: width,
      height: height,
      color: c.surface,
      child: Icon(Icons.image_outlined, color: c.textSecondary, size: 28),
    );
  }
}
