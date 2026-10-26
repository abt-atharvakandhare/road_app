/// Formats a rate-limit wait for display: `3:49` at a minute or more, `42s`
/// under it. Always the server's real figure — never rounded up to whole
/// minutes, which would tell the user to wait longer than they have to.
String formatWaitSeconds(int seconds) {
  if (seconds >= 60) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
  return '${seconds}s';
}
