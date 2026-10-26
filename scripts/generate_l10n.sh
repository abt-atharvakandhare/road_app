#!/bin/bash

# The Phrase package needs to be updated, as both synthetic-package and flutter_gen 
# are now deprecated. Until this is done, we need to copy the phrase_localizations.dart
# file from the .dart_tool/flutter_gen/gen_l10n directory to the lib/l10n directory.

# Generate translations from Phrase
echo "Generating Phrase translations..."
dart run phrase

# Generate Flutter localizations
echo "Generating Flutter localizations..."
flutter gen-l10n

echo "Localization generation complete!"