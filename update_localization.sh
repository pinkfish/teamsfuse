#!/bin/bash

cd `git rev-parse --show-toplevel`
cd flutter_fuse
flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/services/messages.dart
cat lib/l10n/intl_messages.arb | awk '{ if (NR == 2) { print "  \"@@locale\": \"en\"," } print $0 }' > lib/l10n/intl_en.arb
flutter pub run intl_translation:generate_from_arb  --output-dir=lib/l10n --no-use-deferred-loading lib/services/messages.dart lib/l10n/intl_??.arb

cd `git rev-parse --show-toplevel`
cd public_ux
flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/services/messagespublic.dart
 cat lib/l10n/intl_messages.arb | awk '{ if (NR == 2) { print "  \"@@locale\": \"en\"," } print $0 }' > lib/l10n/intl_en.arb
flutter pub run intl_translation:generate_from_arb  --output-dir=lib/l10n --no-use-deferred-loading lib/services/messagespublic.dart lib/l10n/intl_??.arb
