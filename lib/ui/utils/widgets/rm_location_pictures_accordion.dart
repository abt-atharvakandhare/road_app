import 'package:flutter/material.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_collapsible_section.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_picture.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_pictures_viewer.dart';

const double _frameHeight = 200;
const double _frameRadius = 8;
const double _tileSpacing = 8;

/// Collapsible "Photos" section for the location detail drawer showing the
/// location's OCPI pictures (at most [maxPictures]) as a horizontal strip.
/// Tapping a picture opens [RMLocationPicturesViewer].
class RMLocationPicturesAccordion extends StatelessWidget {
  const RMLocationPicturesAccordion({
    super.key,
    required this.images,
  });

  /// Cap from DRI-770: the app displays up to 4 pictures per location.
  static const int maxPictures = 4;

  final List<LocationImage> images;

  List<LocationImage> get _visibleImages => images.take(maxPictures).toList();

  @override
  Widget build(BuildContext context) {
    return RMCollapsibleSection(
      title: AppLocalizations.of(context)!.locationPictures,
      child: SizedBox(
        height: _frameHeight,
        child: LayoutBuilder(
          builder: (context, constraints) => _buildStrip(context, constraints.maxWidth),
        ),
      ),
    );
  }

  Widget _buildStrip(BuildContext context, double availableWidth) {
    final visible = _visibleImages;
    // A single picture fills the frame; with several, each tile leaves a peek
    // of the next one so the strip reads as scrollable.
    final tileWidth = visible.length == 1 ? availableWidth : availableWidth * 0.8;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(width: _tileSpacing),
      itemBuilder: (context, index) => _buildTile(context, visible, index, tileWidth),
    );
  }

  Widget _buildTile(BuildContext context, List<LocationImage> visible, int index, double tileWidth) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.locationPictureCounter(index + 1, visible.length),
      child: GestureDetector(
        onTap: () => RMLocationPicturesViewer.show(context, images: visible, initialIndex: index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_frameRadius),
          child: SizedBox(
            width: tileWidth,
            height: _frameHeight,
            child: RMLocationPicture(
              image: visible[index],
              logicalWidth: tileWidth,
            ),
          ),
        ),
      ),
    );
  }
}
