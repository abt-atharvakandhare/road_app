/// Staging API base URL — all white-label flavors use `api.e-flux.dev` for
/// staging (and `api.e-flux.io` for production), so it's safe to hardcode for
/// multi-flavor runs. Handy for a test that asserts against the active backend.
///
/// The app is put on staging by seeding the debug-controls prefs before launch
/// (`seedStagingPrefs` in reset.dart, invoked by `bootApp`) — NOT by driving the
/// debug-controls UI. That UI path (`switchToStaging`) was removed once seeding
/// replaced it: it's not a real user flow, and you can't "switch" to a stage the
/// app already booted onto.
const stagingBaseUrl = 'https://api.e-flux.dev';
