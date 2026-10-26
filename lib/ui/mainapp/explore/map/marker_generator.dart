import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/model/locations/map_api_gen2_response_model.dart';
import 'package:road_mobile/ui/mainapp/explore/map/map_location_item.dart';
import 'package:image/image.dart' as img;

import 'bloc/map_selection.dart';
import 'cluster_cache.dart';

class ComputeMessage {
  final MarkerGenerator markerGenerator;
  final LatLngBounds visibleBounds;
  final MapApiGen2ResponseModel mapResponse;
  final MapSelection selection;

  ComputeMessage(this.markerGenerator, this.visibleBounds, this.mapResponse, this.selection);
}

class MarkerGenerator {
  Future<List<MapLocationItem>> computeGenerateClusterMetadata(
      LatLngBounds visibleBounds, MapApiGen2ResponseModel mapResponse, MapSelection selection) async {
    final message = ComputeMessage(this, visibleBounds, mapResponse, selection);
    final res = await compute(processCompute, message);
    return res;
  }

  @pragma('vm:entry-point')
  static Future<List<MapLocationItem>> processCompute(ComputeMessage computeMessage) async {
    final response = await computeMessage.markerGenerator
        .generateClusterMetadata(computeMessage.visibleBounds, computeMessage.mapResponse, computeMessage.selection);
    return response;
  }

  BitmapDescriptor? _selectedMarkerBitmap;
  BitmapDescriptor? _availableMarkerBitmap;
  BitmapDescriptor? _unavailableMarkerBitmap;
  BitmapDescriptor? _unknownMarkerBitmap;

  img.Image? _availableClusterImage;
  img.Image? _unavailableClusterImage;
  img.Image? _unknownClusterImage;
  img.Image? _selectedClusterImage;

  img.BitmapFont? _clusterFont;

  Future<BitmapDescriptor> _loadMarkerFromAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return BitmapDescriptor.bytes(data.buffer.asUint8List(), width: 22, height: 28);
  }

  void loadMarkerBitmaps() async {
    _selectedMarkerBitmap = await _loadMarkerFromAsset('assets/icons/map_marker_selected@2x.png');
    _availableMarkerBitmap = await _loadMarkerFromAsset('assets/icons/map_marker_available@2x.png');
    _unavailableMarkerBitmap = await _loadMarkerFromAsset('assets/icons/map_marker_unavailable@2x.png');
    _unknownMarkerBitmap = await _loadMarkerFromAsset('assets/icons/map_marker_unknown@2x.png');

    final availableClusterData = await rootBundle.load('assets/icons/map_cluster_available@2x.png');
    final unavailableClusterData = await rootBundle.load('assets/icons/map_cluster_unavailable@2x.png');
    final unknownClusterData = await rootBundle.load('assets/icons/map_cluster_unknown@2x.png');
    final selectedClusterData = await rootBundle.load('assets/icons/map_cluster_selected@2x.png');

    _availableClusterImage = img.decodePng(availableClusterData.buffer.asUint8List());
    _unavailableClusterImage = img.decodePng(unavailableClusterData.buffer.asUint8List());
    _unknownClusterImage = img.decodePng(unknownClusterData.buffer.asUint8List());
    _selectedClusterImage = img.decodePng(selectedClusterData.buffer.asUint8List());

    final fontZipFile = await rootBundle.load('assets/icons/roboto_regular_12@2x.ttf.zip');
    _clusterFont = img.BitmapFont.fromZip(fontZipFile.buffer.asUint8List());
  }

  Future<List<MapLocationItem>> generateClusterMetadata(
      LatLngBounds visibleBounds, MapApiGen2ResponseModel mapResponse, MapSelection selection) async {
    List<Future<MapLocationItem>> clusterFutures = [];

    ClusterCache clusterCache = ClusterCache();

    for (final mapResponseItem in mapResponse.data) {
      final latLng = LatLng(mapResponseItem.centroid.lat, mapResponseItem.centroid.lon);
      if (!visibleBounds.contains(latLng)) {
        continue;
      }

      clusterFutures.add(clusterMetadataBuilder(mapResponseItem, selection, clusterCache));
    }

    final clusters = await Future.wait(clusterFutures);

    return clusters;
  }

  Future<MapLocationItem> clusterMetadataBuilder(
    MapItemModel mapItem,
    MapSelection selection,
    ClusterCache clusterCache,
  ) async {
    int availableCount = 0;
    int chargingCount = 0;
    int unknownCount = 0;

    for (final s in mapItem.statuses) {
      if (s.name == 'AVAILABLE') {
        availableCount++;
      } else if (s.name == 'CHARGING') {
        chargingCount++;
      } else {
        unknownCount++;
      }
    }

    MapLocationItemStatus status = MapLocationItemStatus.unknown;
    if (availableCount > 0) {
      status = MapLocationItemStatus.available;
    } else if (chargingCount > 0) {
      status = MapLocationItemStatus.charging;
    }

    bool isSelected = switch (selection) {
      MapSelectionNone() => false,
      MapSelectionById(:final locationId) => mapItem.ids.contains(locationId),
      MapSelectionByLocation(:final location) => location == LatLng(mapItem.centroid.lat, mapItem.centroid.lon),
    };

    final stateString = isSelected ? 'selected' : status.statusString;
    final cacheDescriptor = '$stateString-${mapItem.count}';

    final Future<BitmapDescriptor> clusterFuture;
    final cachedBitmap = clusterCache.getCluster(cacheDescriptor);
    if (cachedBitmap != null) {
      clusterFuture = cachedBitmap;
    } else {
      clusterFuture = mapItem.count < 2
          ? _getSingleItemBitmap(status, isSelected)
          : _getBasicClusterBitmap(status, mapItem.count.toString(), isSelected);

      clusterCache.addCluster(cacheDescriptor, clusterFuture);
    }

    return MapLocationItem(
      mapItem.count,
      LatLng(mapItem.centroid.lat, mapItem.centroid.lon),
      await clusterFuture,
      mapItem.ids,
      status,
      availableCount,
      chargingCount,
      unknownCount,
      isSelected,
    );
  }

  Future<BitmapDescriptor> _getSingleItemBitmap(MapLocationItemStatus status, bool isSelected) async {
    if (isSelected) {
      return _selectedMarkerBitmap ?? BitmapDescriptor.defaultMarker;
    }
    switch (status) {
      case MapLocationItemStatus.available:
        return _availableMarkerBitmap ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

      case MapLocationItemStatus.charging:
        return _unavailableMarkerBitmap ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

      case MapLocationItemStatus.unknown:
        return _unknownMarkerBitmap ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  Future<BitmapDescriptor> _getBasicClusterBitmap(MapLocationItemStatus status, String text, bool isSelected) async {
    img.Image? baseImage = switch (status) {
      MapLocationItemStatus.available => _availableClusterImage,
      MapLocationItemStatus.charging => _unavailableClusterImage,
      MapLocationItemStatus.unknown => _unknownClusterImage,
    };

    if (isSelected) {
      baseImage = _selectedClusterImage;
    }

    if (baseImage == null) {
      return BitmapDescriptor.defaultMarker;
    }

    if (_clusterFont == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final clonedBaseImage = baseImage.clone();
    final drawn = img.drawString(clonedBaseImage, text, font: _clusterFont!);
    final drawnBytes = img.encodePng(drawn);

    final descriptor = BitmapDescriptor.bytes(drawnBytes.buffer.asUint8List(), width: 42, height: 42);
    return descriptor;
  }

  Future<MapLocationItem> selectedMapLocationItemCopy(MapLocationItem original, bool isSelected) async {
    return MapLocationItem(
        original.count,
        original.position,
        original.count < 2
            ? await _getSingleItemBitmap(original.status, isSelected)
            : await _getBasicClusterBitmap(original.status, original.count.toString(), isSelected),
        original.locationIds,
        original.status,
        original.availableCount,
        original.chargingCount,
        original.unknownCount,
        isSelected);
  }

  Future<List<MapLocationItem>> selectedMapLocationItemsCopy(
    List<MapLocationItem> original,
    MapSelection selection,
  ) async {
    final newMap = original.map((e) {
      bool shouldBeSelected = switch (selection) {
        MapSelectionNone() => false,
        MapSelectionById(:final locationId) => e.locationIds.contains(locationId),
        MapSelectionByLocation(:final location) => e.position == location,
      };

      if (e.isSelected == shouldBeSelected) {
        return Future.sync(() => e);
      }
      return selectedMapLocationItemCopy(e, shouldBeSelected);
    }).toList();

    return Future.wait(newMap);
  }
}
