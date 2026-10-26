import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';

@injectable
class TimezoneService {
  Future<String> getTimezone() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    return timezoneInfo.identifier;
  }
}
