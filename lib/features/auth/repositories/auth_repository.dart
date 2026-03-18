import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Step 1: POST /auth/login
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Step 2: POST /auth/select-company
  Future<SelectCompanyResponse> selectCompany({
    required String tempToken,
    required String companyCode,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/select-company',
        data: {'tempToken': tempToken, 'companyCode': companyCode},
      );
      return SelectCompanyResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> saveToken(String token) => _apiClient.saveToken(token);
  Future<String?> getToken() => _apiClient.getToken();
  Future<void> clearToken() => _apiClient.clearToken();
}
