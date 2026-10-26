import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/icon_label_row.dart';

class RMTariffNotesButton extends StatelessWidget {
  const RMTariffNotesButton({super.key, required this.location, required this.evseUid, required this.displayType});

  final MapLocationV2 location;
  final String evseUid;
  final TariffDisplayType displayType;

  @override
  Widget build(BuildContext context) {
    if (!isTariffNotesNeeded) {
      return const SizedBox(height: 20);
    }

    return TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              context: context,
              builder: (context) {
                return RMTariffNotesWidget(location: location, evseUid: evseUid, displayType: displayType);
              });
        },
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/tariff_notes_info.svg',
                colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.viewTariffNotes,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: RMColors.rmPrimaryColor)),
          ],
        ));
  }

  bool get isTariffNotesNeeded {
    return (location.customNote != null && location.customNote!.isNotEmpty) ||
        !location.isEfluxLocation ||
        displayType != TariffDisplayType.fixedFee;
  }
}

class RMTariffNotesWidget extends StatelessWidget {
  const RMTariffNotesWidget({super.key, required this.location, required this.evseUid, required this.displayType});

  final MapLocationV2 location;
  final String evseUid;
  final TariffDisplayType displayType;

  @override
  Widget build(BuildContext context) {
    String fullNote = '';

    if (!location.isEfluxLocation) {
      fullNote += AppLocalizations.of(context)!.inaccurateTariffWarning(F.appBrandName);
      fullNote += '\n\n';
    }

    if (location.customNote != null && location.customNote!.isNotEmpty) {
      fullNote += location.customNote!;
      fullNote += '\n\n';
    }

    if (displayType == TariffDisplayType.dynamic) {
      fullNote += AppLocalizations.of(context)!.dynamicTariffNote;
      fullNote += '\n\n';
    } else if (displayType == TariffDisplayType.scheduled) {
      fullNote += AppLocalizations.of(context)!.scheduledTariffNote;
      fullNote += '\n\n';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 9, 0),
          child: Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.tariffNotes)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 29),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconLabelRow(
                icon: SvgPicture.asset('assets/icons/lightning_bolt_small.svg'),
                label: evseUid,
              ),
              Text(fullNote, style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        )
      ],
    );
  }
}
