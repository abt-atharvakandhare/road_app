import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

/// Renders a single OCPI [LocationImage] from the network.
///
/// Raster images are decoded at [logicalWidth] × device pixel ratio so the
/// multi-megapixel originals CPOs upload don't get decoded at full size; SVGs
/// (OCPI allows them) go through flutter_svg. Both show a progress indicator
/// while loading and a neutral "could not load" tile on failure.
class RMLocationPicture extends StatelessWidget {
  const RMLocationPicture({
    super.key,
    required this.image,
    required this.logicalWidth,
    this.fit = BoxFit.cover,
    this.backgroundColor = RMColors.separatorLightGrey,
  });

  final LocationImage image;
  final double logicalWidth;
  final BoxFit fit;

  /// Background of the loading/error tiles; match the surrounding surface
  /// (light grey in the drawer strip, black in the full-screen viewer).
  final Color backgroundColor;

  bool get _isSvg {
    final type = image.type?.toLowerCase() ?? '';
    return type.contains('svg') || Uri.tryParse(image.url)?.path.toLowerCase().endsWith('.svg') == true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.network(
        image.url,
        fit: fit,
        placeholderBuilder: (context) => _LoadingTile(color: backgroundColor),
        errorBuilder: (context, error, stackTrace) => _ErrorTile(color: backgroundColor),
      );
    }

    final cacheWidth = (logicalWidth * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.network(
      image.url,
      fit: fit,
      cacheWidth: cacheWidth,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _LoadingTile(color: backgroundColor);
      },
      errorBuilder: (context, error, stackTrace) => _ErrorTile(color: backgroundColor),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Pick a legible foreground for either surface.
    final foreground = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white70 : null;
    return ColoredBox(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 32, color: foreground ?? RMColors.rmDisabledGray),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.locationPictureCouldNotLoad,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
