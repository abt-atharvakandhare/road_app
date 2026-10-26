import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/widgets/required_rich_text.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/link_launcher.dart';

class CheckboxLinkFormField extends FormField<bool> {
  CheckboxLinkFormField({
    super.key,
    required String plainText,
    required String linkText,
    required Uri? linkUrl,
    required bool isRequired,
    required bool value,
    void Function(bool?)? onChanged,
    super.validator,
  }) : super(builder: (FormFieldState<bool> state) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(
                value: value,
                side: BorderSide(color: state.hasError ? RMColors.errorRed : RMColors.searchTextGrey, width: 2),
                onChanged: (newValue) {
                  state.didChange(newValue);
                  onChanged?.call(newValue);
                }),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RequiredRichText.requiredText(isRequired: isRequired, children: [
                      TextSpan(
                        text: plainText,
                        style: const TextStyle(color: RMColors.rmBlackText),
                      ),
                      TextSpan(
                        text: linkText,
                        style: TextStyle(color: RMColors.rmPrimaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchProviderUri(state.context, linkUrl);
                          },
                      ),
                    ]),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          state.errorText!,
                          style: Theme.of(state.context).inputDecorationTheme.errorStyle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ]);
        });
}
