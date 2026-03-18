import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, selectingCompany, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _tempToken;
  List<CompanyModel> _companies = [];
  bool _isAuthenticated = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<CompanyModel> get companies => _companies;
  bool get isAuthenticated => _isAuthenticated;

  // ─── Step 1: Login ────────────────────────────────────────────────────────

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      final response = await _repository.login(
        username: username,
        password: password,
      );

      if (response.isAdmin) {
        // Admin: token ready, go directly to home
        await _repository.saveToken(response.accessToken!);
        _isAuthenticated = true;
        _setStatus(AuthStatus.authenticated);
      } else {
        // Non-admin: need to select company
        _tempToken = response.tempToken;
        _companies = response.companies ?? [];
        _setStatus(AuthStatus.selectingCompany);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(AuthStatus.error);
    }
  }

  // ─── Step 2: Select company ───────────────────────────────────────────────

  Future<void> selectCompany(String companyCode) async {
    if (_tempToken == null) return;
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      final response = await _repository.selectCompany(
        tempToken: _tempToken!,
        companyCode: companyCode,
      );
      await _repository.saveToken(response.accessToken);
      _isAuthenticated = true;
      _tempToken = null;
      _companies = [];
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(AuthStatus.error);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _repository.clearToken();
    _isAuthenticated = false;
    _tempToken = null;
    _companies = [];
    _setStatus(AuthStatus.initial);
  }

  // ─── Check session ────────────────────────────────────────────────────────

  Future<bool> checkSession() async {
    final token = await _repository.getToken();
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      _setStatus(AuthStatus.authenticated);
      return true;
    }
    return false;
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _setStatus(_companies.isNotEmpty
          ? AuthStatus.selectingCompany
          : AuthStatus.initial);
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}
