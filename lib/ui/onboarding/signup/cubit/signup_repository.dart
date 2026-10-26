import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/signup/signup_countries_model.dart';
import 'package:road_mobile/data/model/signup/signup_individual_model.dart';
import 'package:road_mobile/data/model/signup/signup_response_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

@injectable
class SignupRepository {
  SignupRepository(this._apiService);

  final ApiService _apiService;

  Future<SignupCountriesResponseModel> getSupportedCountries() async {
    final response = await _apiService.get('/1/signup/countries');
    return SignupCountriesResponseModel.fromJson(response.data);
  }

  Future<SignupDataResponseModel> signup(SignupIndividualModel data) async {
    final dataJson = data.toJson();
    final response = await _apiService.post('/1/signup', data: dataJson);
    return SignupDataResponseModel.fromJson(response.data);
  }
}
