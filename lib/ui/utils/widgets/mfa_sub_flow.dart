import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

/// Shared scaffold for an MFA sub-flow step: optional back link to the hub,
/// optional title, then the step's content. Callback-based so any host cubit
/// can own the back transition; hosts whose app bar already provides the back
/// affordance omit [onBack].
class MfaSubFlow extends StatelessWidget {
  const MfaSubFlow({super.key, this.onBack, this.title, required this.child});

  final VoidCallback? onBack;
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l10n.mfaSetupBack),
          ),
          const SizedBox(height: 8),
        ],
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
        ],
        child,
      ],
    );
  }
}
