import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/report_problem/report_problem_screen.dart';
import 'package:road_mobile/ui/mainapp/report_problem/widgets/report_problem_entry_link.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/session_details_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/session_item_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/scroll.dart';
import '_helpers/session_period.dart';

// Shape: sub-flow / form-submit.
//   Boot onto staging → log in → Wallet → Sessions → tap a session row →
//   Session Details → scroll to ReportProblemEntryLink → tap CTA →
//   ReportProblemScreen → pick "Charging session interrupted" category → Submit
//   → assert success snackbar text and pop back to Session Details.
//
// The ReportProblemEntryLink only renders when `session.mspLocation?.id != null`
// (session_details_screen.dart:124). The sessions LIST endpoint returns
// mspLocation: null even for ray+uk3, but the session DETAIL fetch (the cubit
// behind SessionDetailsScreen, state.detailSession) populates it — so the link
// does appear once the detail loads. Hence the test waits for the link to EXIST
// before scrolling. (If a future account's detail also lacks mspLocation, that
// wait would time out — pick a session on the provider's own network.)
//
// Submitting creates a real issue report in the staging backend — acceptable for
// QA purposes. Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'report a problem from session details: pick category and submit',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Wallet → Sessions (default wallet tab), then filter to the seeded
      // period — the default (current-month) view is empty in any month nobody
      // charged on the test account, and the seeded period's sessions are all
      // verified to carry the detail-level mspLocation this flow requires
      // (see _helpers/session_period.dart).
      await tapTab($, AppTab.wallet);
      await filterSessionsToTestPeriod($);

      // Wait for the sessions list to appear (renders behind a shimmer during
      // the fetch — pumpAndSettle would hang).
      await $(SessionItemWidget).waitUntilVisible();
      expect(
        $(SessionItemWidget),
        findsWidgets,
        reason: '$testSessionPeriodSubtitle should have at least one session for this account',
      );

      // Open the first session row.
      await $(SessionItemWidget).at(0).tap();
      await $(SessionDetailsScreen).waitUntilVisible();

      // The ReportProblemEntryLink renders only after the session DETAIL fetch
      // populates mspLocation (the list item has it null — the detail endpoint
      // adds it), and it sits below the stats grid. Wait for it to EXIST (detail
      // loaded), then scroll it into view programmatically — scrollTo's gesture
      // drag flings/overshoots under iOS BouncingScrollPhysics (see scroll.dart).
      await $(ReportProblemEntryLink).waitUntilExists();
      await scrollIntoView($, $(ReportProblemEntryLink));

      // Tap the "Report it here →" CTA (a TextButton inside the entry link).
      // The CTA text is unique on the screen so we scope it within the link widget.
      await $(ReportProblemEntryLink).$(TextButton).tap();
      await $(ReportProblemScreen).waitUntilVisible();

      // The category selector (_SelectorField) renders an InkWell with an
      // Icons.keyboard_arrow_down chevron. Wait for the screen's initialize()
      // fetch to complete before tapping. "Problem Type" renders during the
      // fetch, so it is NOT the readiness signal; the submit RMTextButton is:
      // it spins (isLoading, onPressed null) for the whole initialize flow and
      // only goes idle once the location/EVSE data is in. Tapping the category
      // before that is fine, but tapping Submit during it is swallowed by the
      // disabled button and the test then waits for a pop that never comes.
      await $('Problem Type').waitUntilVisible();
      await submitButton($, enabled: false).waitUntilExists();

      // Tap the category selector's chevron. The category field is always the
      // last _SelectorField in the column (connector, if present, comes first;
      // the description field only appears after "Other" is picked). Use the
      // last keyboard_arrow_down icon in the screen to land on category regardless
      // of whether a connector row is shown.
      await $(ReportProblemScreen).$(Icons.keyboard_arrow_down).waitUntilVisible();
      final chevrons = $(ReportProblemScreen).$(Icons.keyboard_arrow_down);
      await chevrons.at(chevrons.evaluate().length - 1).tap();

      // The OptionsBottomSheet renders entries as ListTiles. Pick a non-"Other"
      // category so no description field is required: "Charging session interrupted".
      await $('Charging session interrupted').waitUntilVisible();
      await $('Charging session interrupted').tap();

      // The bottom sheet pops; wait for ReportProblemScreen to be visible again
      // and the Submit Report button to be enabled (category set, not loading).
      await $(ReportProblemScreen).waitUntilVisible();
      await submitButton($, enabled: true).waitUntilVisible();
      expect(
        submitButton($, enabled: true),
        findsOneWidget,
        reason: 'submit button should be enabled after category selection',
      );

      // Submit. On success the cubit emits submitted:true → the screen pops
      // (Navigator.pop(true)) and flashes a success snackbar. We assert the POP,
      // not the snackbar: the snackbar is shown then immediately cancelled by the
      // pop (its ScaffoldMessenger is torn down) so it can't be reliably caught,
      // and its text is a Phrase string. The pop back to SessionDetailsScreen is
      // the robust success signal.
      await submitButton($, enabled: true).tap();

      await waitUntilGone($, $(ReportProblemScreen));
      expect(
        $(ReportProblemScreen),
        findsNothing,
        reason: 'a successful submit pops the ReportProblemScreen',
      );
      await $(SessionDetailsScreen).waitUntilVisible();
      expect(
        $(SessionDetailsScreen),
        findsOneWidget,
        reason: 'report screen should pop back to session details on success',
      );
    },
  );
}

/// The Submit Report button when it is not spinning (the screen's initialize()
/// and the submit itself both drive isLoading). With [enabled] it must also be
/// tappable, i.e. canSubmit holds because a category is selected; without it
/// the button may still be disabled (nothing selected yet).
PatrolFinder submitButton(PatrolIntegrationTester $, {required bool enabled}) => $(ReportProblemScreen).$(
      find.byWidgetPredicate(
        (widget) => widget is RMTextButton && !widget.isLoading && (!enabled || widget.onPressed != null),
      ),
    );
