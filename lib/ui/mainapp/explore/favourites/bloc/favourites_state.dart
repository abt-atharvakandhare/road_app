part of 'favourites_cubit.dart';

@freezed
sealed class FavouritesState with _$FavouritesState {
  const factory FavouritesState.favourites({
    required List<String> stationIds,
    required List<MapLocationV2> stations,
    @Default(UIFlow.established()) UIFlow flow,
  }) = Favourites;
}

extension FavouritesStateLogic on FavouritesState {
  bool isFavourite(String? locationId) {
    if (locationId == null) {
      return false;
    }
    return switch (this) {
      Favourites(:final stationIds) => stationIds.contains(locationId),
    };
  }
}
