import 'package:flutter/material.dart';

/// Optimized image widgets for common use cases in the FosterSquirrel app.
/// These widgets implement Flutter performance best practices including:
/// - Const constructors for rebuild short-circuiting
/// - Proper sizing to avoid layout recalculations
/// - Cached asset images for memory efficiency
class OptimizedImages {
  OptimizedImages._();

  /// Error squirrel icon with optimized rendering
  static const Widget errorSquirrel = _ErrorSquirrelImage();

  /// Foster squirrel icon with optimized rendering
  static const Widget fosterSquirrel = _FosterSquirrelImage();
}

/// Optimized error squirrel image widget
class _ErrorSquirrelImage extends StatelessWidget {
  const _ErrorSquirrelImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/error_squirrel.png',
      width: 64,
      height: 64,
      // Use cacheWidth and cacheHeight for memory optimization
      cacheWidth: 64 * MediaQuery.of(context).devicePixelRatio.round(),
      cacheHeight: 64 * MediaQuery.of(context).devicePixelRatio.round(),
      // Optimize for memory usage
      isAntiAlias: true,
      filterQuality: FilterQuality.medium,
      // Add error handling
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        );
      },
    );
  }
}

/// Optimized foster squirrel image widget
class _FosterSquirrelImage extends StatelessWidget {
  const _FosterSquirrelImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/foster_squirrel.png',
      width: 64,
      height: 64,
      // Use cacheWidth and cacheHeight for memory optimization
      cacheWidth: 64 * MediaQuery.of(context).devicePixelRatio.round(),
      cacheHeight: 64 * MediaQuery.of(context).devicePixelRatio.round(),
      // Optimize for memory usage
      isAntiAlias: true,
      filterQuality: FilterQuality.medium,
      // Add error handling
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_not_supported_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}

/// Custom optimized image widget for flexible use cases
class OptimizedAssetImage extends StatelessWidget {
  const OptimizedAssetImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.medium,
    this.fallbackIcon,
  });

  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Image.asset(
      path,
      width: width,
      height: height,
      // Cache dimensions optimized for device pixel ratio
      cacheWidth: width != null ? (width! * devicePixelRatio).round() : null,
      cacheHeight: height != null ? (height! * devicePixelRatio).round() : null,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      isAntiAlias: true,
      filterQuality: filterQuality,
      errorBuilder: (context, error, stackTrace) {
        final iconData = fallbackIcon ?? Icons.image_not_supported_outlined;
        final iconColor = color ?? Theme.of(context).colorScheme.onSurface;
        final iconSize = width ?? height ?? 24.0;

        return Icon(iconData, size: iconSize, color: iconColor);
      },
    );
  }
}
