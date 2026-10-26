import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/invoices/invoices_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

@lazySingleton
class InvoicesRepository {
  final ApiService _apiService;

  InvoicesRepository(this._apiService);

  Future<InvoicesResponseModel> listInvoices({int? skip, int? limit, int? yearFilter}) async {
    Map data = {};

    if (skip != null) {
      data['skip'] = skip;
    }

    if (limit != null) {
      data['limit'] = limit;
    }

    if (yearFilter != null) {
      data['year'] = yearFilter;
    }

    data['sort'] = {
      'field': 'createdAt',
      'order': 'desc',
    };

    data['type'] = 'msp-usage';

    final response = await _apiService.post('/1/invoices/mine', data: data);
    final invoicesResponse = InvoicesResponseModel.fromJson(response.data);
    return invoicesResponse;
  }
}
