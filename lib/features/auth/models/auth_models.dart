class CompanyModel {
  final String companyCode;
  final String companyName;

  CompanyModel({
    required this.companyCode,
    required this.companyName,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyCode: json['companyCode'] as String? ?? '',
      companyName: json['companyName'] as String? ?? json['name'] as String? ?? '',
    );
  }
}

class LoginResponse {
  /// Admin role: returns access_token directly
  final String? accessToken;

  /// Non-admin: returns temp_token + list of companies
  final String? tempToken;
  final List<CompanyModel>? companies;

  bool get isAdmin => accessToken != null;

  LoginResponse({
    this.accessToken,
    this.tempToken,
    this.companies,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    List<CompanyModel>? companies;
    if (json['companies'] != null) {
      companies = (json['companies'] as List)
          .map((c) => CompanyModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    return LoginResponse(
      accessToken: json['access_token'] as String?,
      tempToken: json['temp_token'] as String?,
      companies: companies,
    );
  }
}

class SelectCompanyResponse {
  final String accessToken;

  SelectCompanyResponse({required this.accessToken});

  factory SelectCompanyResponse.fromJson(Map<String, dynamic> json) {
    return SelectCompanyResponse(
      accessToken: json['access_token'] as String,
    );
  }
}
