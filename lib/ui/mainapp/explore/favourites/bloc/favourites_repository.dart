import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavouritesRepository {
  final ApiService _apiService;

  FavouritesRepository(this._apiService);

  Future<List<String>> fetchFavouriteStations() async {
    final profileResponse = await _apiService.get('/1/users/me');
    final profile = ProfileResponseModel.fromJson(profileResponse.data);
    return profile.data.favouriteLocations ?? [];
  }

  Future<MapLocationsResponseModel> getChargingLocationsDetails(List<String> locationIds) async {
    Map data = {'ids': locationIds, 'includeUserSpecialTariffs': true};

    final apiResponse = await _apiService.post('/1/map/locations', data: data);
    final locationsResponse = MapLocationsResponseModel.fromJson(apiResponse.data);
    return locationsResponse;
  }

  Future<void> addFavouriteStation(String stationId) async {
    await _apiService.post('/1/users/favourite-locations/$stationId');
  }

  Future<void> removeFavouriteStation(String stationId) async {
    await _apiService.delete('/1/users/favourite-locations/$stationId');
  }
}
