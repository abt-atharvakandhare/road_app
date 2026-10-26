import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// "We recommend Google Authenticator, 1Password or Authy." with each app
/// name linking to its store listing.
///
/// The localized template (`weRecommendGoogleAuthenticator`) must split on
/// `--authoption--` into exactly four segments around the three app names;
/// a mistranslated template renders a visible failure marker instead.
class AuthenticatorAppLinks extends StatefulWidget {
  const AuthenticatorAppLinks({super.key, this.style});

  /// Base style for the sentence; the app-name links add the accent colour.
  final TextStyle? style;

  @override
  State<AuthenticatorAppLinks> createState() => _AuthenticatorAppLinksState();
}

class _AuthenticatorAppLinksState extends State<AuthenticatorAppLinks> {
  late final _googleAuthenticatorTap = _storeLink(
    iosUrl: 'https://apps.apple.com/app/id388497605',
    androidUrl: 'market://details?id=com.google.android.apps.authenticator2',
  );
  late final _onePasswordTap = _storeLink(
    iosUrl: 'https://apps.apple.com/app/id1511601750',
    androidUrl: 'market://details?id=com.onepassword.android',
  );
  late final _authyTap = _storeLink(
    iosUrl: 'https://apps.apple.com/app/id494168017',
    androidUrl: 'market://details?id=com.authy.authy',
  );

  final List<TapGestureRecognizer> _recognizers = [];

  TapGestureRecognizer _storeLink({required String iosUrl, required String androidUrl}) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        launchUrl(Uri.parse(Platform.isIOS ? iosUrl : androidUrl), mode: LaunchMode.externalApplication);
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final segments = l10n.weRecommendGoogleAuthenticator.split('--authoption--');
    if (segments.length != 4) {
      return Text('Translation failure', style: widget.style);
    }

    final linkStyle = TextStyle(color: RMColors.rmPrimaryColor);
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: segments[0]),
          TextSpan(text: l10n.googleAuthenticator, style: linkStyle, recognizer: _googleAuthenticatorTap),
          TextSpan(text: segments[1]),
          TextSpan(text: l10n.onePassword, style: linkStyle, recognizer: _onePasswordTap),
          TextSpan(text: segments[2]),
          TextSpan(text: l10n.authy, style: linkStyle, recognizer: _authyTap),
          TextSpan(text: segments[3]),
        ],
      ),
    );
  }
}
