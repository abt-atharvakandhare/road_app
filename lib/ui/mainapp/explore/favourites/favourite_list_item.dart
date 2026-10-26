import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/ui/mainapp/explore/widgets/charging_station_list_item.dart';

class FavouriteListItem extends StatelessWidget {
  final MapLocationV2 location;
  final bool isFavourite;
  final VoidCallback? onTap;
  final VoidCallback? onFavouriteToggle;

  const FavouriteListItem({
    super.key,
    required this.location,
    required this.isFavourite,
    this.onTap,
    this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ChargingStationListItem(
      location: location,
      onTap: onTap,
      leadingWidget: IconButton(
        icon: SvgPicture.asset(
          isFavourite ? 'assets/icons/favourite_on_small.svg' : 'assets/icons/favourite_off_small.svg',
          colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn),
        ),
        onPressed: onFavouriteToggle,
        splashRadius: 40,
      ),
    );
  }
}
