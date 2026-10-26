import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

@lazySingleton
class SessionsRepository {
  final ApiService apiService;

  SessionsRepository(this.apiService);

  Future<SessionsResponseModel> listActiveSessions() async {
    final activeResponse = await apiService.post(
      '/1/active-sessions/mine',
      data: {
        'ownership': 'user',
        'statuses': ['ACTIVE'],
      },
    );
    final parsed = SessionsResponseModel.fromJson(activeResponse.data);
    for (final session in parsed.data) {
      session.isActiveListEntry = true;
    }
    return parsed;
  }

  Future<SessionsResponseModel> listSessions({
    int? skip,
    int? limit,
    int? year,
    int? month,
    String? tokenId,
    String? paymentMethod,
  }) async {
    Map<String, dynamic> data = {'ownership': 'user'};

    if (skip != null) {
      data['skip'] = skip;
    }

    if (limit != null) {
      data['limit'] = limit;
    }

    // Build date range filter from year/month
    if (year != null) {
      final fromMonth = month ?? 1;
      final toMonth = month ?? 12;
      final fromDate = DateTime(year, fromMonth, 1);
      final toDate = month != null
          ? DateTime(year, toMonth + 1, 1) // End of selected month
          : DateTime(year + 1, 1, 1); // End of year

      data['from'] = fromDate.toIso8601String();
      data['to'] = toDate.toIso8601String();
    }

    // Token ID filter for charge card (when backend supports it)
    if (tokenId != null) {
      data['tokenId'] = tokenId;
    }

    // Payment method filter (when backend supports it)
    if (paymentMethod != null) {
      data['paymentMethod'] = paymentMethod;
    }

    final response = await apiService.post('/1/sessions/mine', data: data);
    return SessionsResponseModel.fromJson(response.data);
  }

  Future<SessionModel> getSessionDetail(String sessionId) async {
    final response = await apiService.get('/1/sessions/$sessionId');
    return SessionModel.fromJson(response.data['data']);
  }
}
