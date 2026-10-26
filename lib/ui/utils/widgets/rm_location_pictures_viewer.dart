import 'package:flutter/material.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_picture.dart';

/// Full-screen, swipeable, pinch-to-zoom viewer for a location's OCPI pictures.
class RMLocationPicturesViewer extends StatefulWidget {
  const RMLocationPicturesViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<LocationImage> images;
  final int initialIndex;

  static Future<void> show(BuildContext context, {required List<LocationImage> images, int initialIndex = 0}) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RMLocationPicturesViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<RMLocationPicturesViewer> createState() => _RMLocationPicturesViewerState();
}

class _RMLocationPicturesViewerState extends State<RMLocationPicturesViewer> {
  late final PageController _pageController;
  // One controller is enough: pages can only change while un-zoomed (see
  // _isZoomed), and the transform is reset on every page change.
  final TransformationController _transformationController = TransformationController();
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // While zoomed in, horizontal drags must pan the picture rather than swipe
  // the PageView, so page scrolling is disabled until the user zooms back out.
  void _onTransformationChanged() {
    final isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.0;
    if (isZoomed != _isZoomed) {
      setState(() => _isZoomed = isZoomed);
    }
  }

  void _onPageChanged(int index) {
    _transformationController.value = Matrix4.identity();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
            itemCount: widget.images.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: RMLocationPicture(
                    image: widget.images[index],
                    // Decode at 2× the screen width so pinch-zoom stays sharp
                    // without decoding the multi-megapixel originals.
                    logicalWidth: screenWidth * 2,
                    fit: BoxFit.contain,
                    backgroundColor: Colors.black,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 29),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                  const Spacer(),
                  if (widget.images.length > 1)
                    Text(
                      l10n.locationPictureCounter(_currentIndex + 1, widget.images.length),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  const Spacer(),
                  // Balances the close button so the counter stays centred.
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
