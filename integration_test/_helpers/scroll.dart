import 'package:patrol/patrol.dart';

/// Brings [finder] into view WITHOUT gesture momentum, then waits for it to be
/// hit-testable.
///
/// Patrol's `scrollTo` drags with pointer velocity. Under iOS
/// BouncingScrollPhysics any non-trivial velocity becomes a momentum fling that
/// overshoots the target, bounces off the end of the list, and leaves the target
/// scrolled off the *opposite* edge — so it's never found (you get a
/// `scrollUntilVisible` timeout: "Found 0 widgets ..."). Tuning step/maxScrolls
/// can't fix it: too few steps fall short, enough steps to reach it also overshoot.
///
/// For content inside a `SingleChildScrollView` (every child is built even when
/// off-screen) Flutter's `Scrollable.ensureVisible` scrolls programmatically with
/// zero momentum and lands exactly on the target. [finder] must resolve to a
/// single built widget.
Future<void> scrollIntoView(PatrolIntegrationTester $, PatrolFinder finder) async {
  // Wait for the target to be BUILT first — ensureVisible resolves the element
  // immediately and throws "No element" if it isn't in the tree yet (e.g. a
  // screen still rendering right after navigation). This makes scrollIntoView
  // robust without each caller pre-waiting.
  await finder.waitUntilExists();
  // .first: ensureVisible needs exactly one element; tolerate a finder that
  // matches several (scroll to the first) rather than throwing "Too many
  // elements".
  await $.tester.ensureVisible(finder.finder.first);
  await finder.first.waitUntilVisible();
}
