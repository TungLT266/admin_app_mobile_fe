import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../features/auth/models/auth_models.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/gradient_button.dart';
import '../home/home_screen.dart';

class SelectCompanyScreen extends StatefulWidget {
  const SelectCompanyScreen({super.key});

  @override
  State<SelectCompanyScreen> createState() => _SelectCompanyScreenState();
}

class _SelectCompanyScreenState extends State<SelectCompanyScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCode;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(CupertinoIcons.exclamationmark_circle,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(AppStrings.companyRequired),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    await auth.selectCompany(_selectedCode!);

    if (!mounted) return;

    if (auth.status == AuthStatus.authenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else if (auth.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? AppStrings.unknownError),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final companies = auth.companies;
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildHeader(context),
                        const SizedBox(height: 28),
                        _buildCompanyList(companies),
                        const SizedBox(height: 24),
                        GradientButton(
                          label: AppStrings.confirm,
                          onPressed: isLoading ? null : _confirm,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(
              CupertinoIcons.chevron_back,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            CupertinoIcons.building_2_fill,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.selectCompany,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.selectCompanySubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCompanyList(List<CompanyModel> companies) {
    if (companies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(CupertinoIcons.building_2_fill,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text(
                'Không có công ty nào',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: companies.asMap().entries.map((entry) {
            final index = entry.key;
            final company = entry.value;
            final isSelected = _selectedCode == company.companyCode;
            final isLast = index == companies.length - 1;

            return GestureDetector(
              onTap: () => setState(() => _selectedCode = company.companyCode),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.06)
                      : Colors.transparent,
                  border: !isLast
                      ? const Border(
                          bottom: BorderSide(
                            color: AppColors.inputBorder,
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          company.companyName.isNotEmpty
                              ? company.companyName[0].toUpperCase()
                              : 'C',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.companyName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            company.companyCode,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: AppColors.primary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
