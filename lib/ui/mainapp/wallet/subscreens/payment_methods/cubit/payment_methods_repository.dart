import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/network/api_service.dart';

@lazySingleton
class PaymentMethodsRepository {
  final ApiService apiService;

  PaymentMethodsRepository(this.apiService);

  /// Deletes a payment instrument via the PayBridge-backed endpoint.
  /// Returns 202 with no body on success, so we treat a successful HTTP status as success.
  Future<bool> deleteCard(String paymentInstrumentId) async {
    await apiService.delete('/1/accounts/self/payment-instruments/$paymentInstrumentId');
    return true;
  }

  Future<bool> blockCard(String tokenId) async {
    await apiService.post('/1/cards/$tokenId/disable');
    return true;
  }

  Future<bool> unblockCard(String tokenId) async {
    await apiService.post('/1/cards/$tokenId/enable');
    return true;
  }
}
