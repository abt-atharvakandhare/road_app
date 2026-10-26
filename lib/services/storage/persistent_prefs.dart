import 'package:shared_preferences/shared_preferences.dart';

/// Convention for SharedPreferences keys whose values are *device-scoped* and must
/// survive logout. Any key starting with this prefix is preserved by
/// [PersistentPrefs.clearUserScoped]; everything else is wiped.
///
/// Use this for things like one-time migration markers, install-level flags, or
/// debug-only toggles that aren't tied to the signed-in user. User-scoped data
/// (auth tokens, profile, cached settings, etc.) should use unprefixed keys so it
/// gets cleared on logout.
const String persistKeyPrefix = 'persist:';

extension PersistentPrefs on SharedPreferences {
  /// Wipes every SharedPreferences key that doesn't start with [persistKeyPrefix].
  /// Used during logout in place of `clear()` so device-scoped state (e.g. one-time
  /// migration flags) survives sign-out.
  Future<void> clearUserScoped() async {
    final allKeys = getKeys();
    for (final key in allKeys) {
      if (key.startsWith(persistKeyPrefix)) continue;
      await remove(key);
    }
  }
}
