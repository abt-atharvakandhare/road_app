import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/street_view/street_view_availability_service.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_collapsible_section.dart';
import 'package:road_mobile/ui/utils/widgets/rm_street_view_panorama.dart';

const double _frameHeight = 200;
const double _frameRadius = 8;

enum _StreetViewStatus { idle, checking, available, unavailable }

/// Collapsible "Street View" section for the location detail drawer.
///
/// Collapsed by default. Expanding shows a press-to-view placeholder; the
/// interactive panorama (and any Street View billing) only starts on an
/// explicit press. When Google reports no imagery near the coordinate, a
/// "not available" placeholder is shown instead.
class RMStreetViewAccordion extends StatefulWidget {
  const RMStreetViewAccordion({
    super.key,
    required this.latitude,
    required this.longitude,
    this.availabilityService,
  });

  final double latitude;
  final double longitude;
  final StreetViewAvailabilityService? availabilityService;

  @override
  State<RMStreetViewAccordion> createState() => _RMStreetViewAccordionState();
}

class _RMStreetViewAccordionState extends State<RMStreetViewAccordion> {
  _StreetViewStatus _status = _StreetViewStatus.idle;
  late final StreetViewAvailabilityService _availabilityService;
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _availabilityService = widget.availabilityService ?? StreetViewAvailabilityService();
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  void _onPressToView() async {
    setState(() {
      _status = _StreetViewStatus.checking;
    });

    final isAvailable = await _availabilityService.isAvailable(
      widget.latitude,
      widget.longitude,
      cancelToken: _cancelToken,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _status = isAvailable ? _StreetViewStatus.available : _StreetViewStatus.unavailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RMCollapsibleSection(
      title: AppLocalizations.of(context)!.streetView,
      child: _buildFrame(context),
    );
  }

  Widget _buildFrame(BuildContext context) {
    return switch (_status) {
      _StreetViewStatus.idle => _buildPlaceholder(
          context,
          onTap: _onPressToView,
          child: _buildPressToViewContent(context),
        ),
      _StreetViewStatus.checking => _buildPlaceholder(
          context,
          child: const Center(child: CircularProgressIndicator()),
        ),
      _StreetViewStatus.available => _buildPanorama(),
      _StreetViewStatus.unavailable => _buildPlaceholder(
          context,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context)!.streetViewNotAvailable,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
    };
  }

  Widget _buildPlaceholder(BuildContext context, {required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_frameRadius),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: RMColors.rmDisabledGray),
        child: SizedBox(
          height: _frameHeight,
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }

  Widget _buildPressToViewContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.streetview, size: 32),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.pressToView,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RMColors.rmPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPanorama() {
    return SizedBox(
      height: _frameHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_frameRadius),
        child: RMStreetViewPanorama(
          latitude: widget.latitude,
          longitude: widget.longitude,
          radius: StreetViewAvailabilityService.searchRadius,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(_frameRadius)));

    canvas.drawPath(
      dashPath(path, dashArray: CircularIntervalList<double>([6, 4])),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
