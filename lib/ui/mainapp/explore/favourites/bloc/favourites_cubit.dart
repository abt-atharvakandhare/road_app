import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

import 'favourites_repository.dart';

part 'favourites_state.dart';
part 'favourites_cubit.freezed.dart';

@injectable
class FavouritesCubit extends Cubit<FavouritesState> {
  final FavouritesRepository repository;

  FavouritesCubit(
    this.repository, {
    @factoryParam required bool isInitiallyLoggedIn,
  }) : super(const FavouritesState.favourites(stationIds: [], stations: [])) {
    if (isInitiallyLoggedIn) {
      loadFavourites();
    }
  }

  Future<void> loadFavourites() async {
    emit(state.copyWith(flow: UIFlow.loading()));
    try {
      final stationsIds = await repository.fetchFavouriteStations();
      final stations =
          stationsIds.isEmpty ? <MapLocationV2>[] : (await repository.getChargingLocationsDetails(stationsIds)).data;
      emit(FavouritesState.favourites(stationIds: stationsIds, stations: stations));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<bool> addFavourite(String? stationId) async {
    if (stationId == null) {
      return false;
    }

    if (state.stationIds.contains(stationId)) {
      return false;
    }

    final newStationIds = [stationId, ...state.stationIds];
    emit(state.copyWith(stationIds: newStationIds));

    try {
      await repository.addFavouriteStation(stationId);
      return true;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> toggleFavourite(String? stationId) async {
    if (stationId == null) {
      return false;
    }

    if (state.stationIds.contains(stationId)) {
      return await removeFavourite(stationId);
    } else {
      return await addFavourite(stationId);
    }
  }

  void clearFavourites() {
    emit(const FavouritesState.favourites(stationIds: [], stations: []));
  }

  Future<bool> removeFavourite(String? stationId) async {
    if (stationId == null) {
      return false;
    }

    final newStationIds = state.stationIds.where((id) => id != stationId).toList();

    emit(state.copyWith(stationIds: newStationIds));

    try {
      await repository.removeFavouriteStation(stationId);
      return true;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }
}
