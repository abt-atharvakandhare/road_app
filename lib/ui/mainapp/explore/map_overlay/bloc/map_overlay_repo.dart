import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

@injectable
class MapOverlayRepo {
  MapOverlayRepo(this._apiService);

  final ApiService _apiService;

  Future<MapLocationsResponseModel> getChargingLocationsDetails(List<String> locationIds) async {
    Map data = {'ids': locationIds, 'includeUserSpecialTariffs': true};

    final apiResponse = await _apiService.post('/1/map/locations', data: data);
    return MapLocationsResponseModel.fromJson(apiResponse.data);
  }
}
