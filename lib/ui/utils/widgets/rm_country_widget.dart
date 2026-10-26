import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../rm_ui_config.dart';

class RMCountryPickerWidget extends StatelessWidget {
  const RMCountryPickerWidget({
    super.key,
    required this.country,
    this.shortVersion = false,
    this.onSelect,
    this.supportedCountries,
  });

  final Country country;
  final bool shortVersion;
  final ValueChanged<Country>? onSelect;
  final List<String>? supportedCountries;
  static const _favourites = ['NL', 'BE', 'DE', 'FR', 'GB'];

  @override
  Widget build(BuildContext context) {
    List<String> favourites;
    if (_favourites.contains(country.countryCode)) {
      favourites = _favourites;
    } else {
      favourites = [country.countryCode, ..._favourites];
    }

    return GestureDetector(
      onTap: onSelect == null
          ? null
          : () {
              showCountryPicker(
                  context: context,
                  favorite: favourites,
                  showPhoneCode: shortVersion,
                  useSafeArea: true,
                  countryFilter: supportedCountries,
                  countryListTheme: CountryListThemeData(
                      searchTextStyle: Theme.of(context).textTheme.labelMedium,
                      inputDecoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
                          ),
                        ),
                      )),
                  onSelect: onSelect!.call);
            },
      child: Container(
        width: shortVersion ? null : double.infinity,
        decoration: onSelect != null ? RMBoxDecoration.rmBoxDecoration : RMBoxDecoration.rmBoxDecorationDisabled,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.5),
          child: Row(
            children: [
              if (shortVersion) ...[
                Text('${country.flagEmoji} ${country.countryCode} +${country.phoneCode}  ',
                    style: Theme.of(context).textTheme.labelMedium),
              ] else ...[
                Text('${country.flagEmoji} ${country.name}', style: Theme.of(context).textTheme.labelMedium),
                const Spacer()
              ],
              const Icon(Icons.keyboard_arrow_down)
            ],
          ),
        ),
      ),
    );
  }
}
