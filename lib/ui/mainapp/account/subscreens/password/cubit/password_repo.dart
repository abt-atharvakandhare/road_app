import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/network/api_service.dart';

@injectable
class PasswordRepo {
  PasswordRepo(this._apiService);
  final ApiService _apiService;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiService.post('/1/users/me/set-credentials', data: {
      'currentPassword': oldPassword,
      'newPassword': newPassword,
    });
  }
}
