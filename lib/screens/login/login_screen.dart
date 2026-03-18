import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/gradient_button.dart';
import '../select_company/select_company_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocusNode = FocusNode();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    switch (auth.status) {
      case AuthStatus.authenticated:
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const HomeScreen()),
        );
      case AuthStatus.selectingCompany:
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => const SelectCompanyScreen()),
        );
      case AuthStatus.error:
        _showErrorSnackBar(auth.errorMessage ?? AppStrings.loginFailed);
        auth.clearError();
      default:
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select<AuthProvider, bool>((p) => p.status == AuthStatus.loading);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      _buildHeader(),
                      const SizedBox(height: 48),
                      _buildForm(isLoading),
                      const SizedBox(height: 32),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo container
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          AppStrings.welcomeBack,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.loginSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
              ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Card wrapper
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                AppTextField(
                  controller: _usernameCtrl,
                  label: AppStrings.username,
                  hint: AppStrings.usernamePlaceholder,
                  prefixIcon: CupertinoIcons.person,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.usernameRequired
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordCtrl,
                  label: AppStrings.password,
                  hint: AppStrings.passwordPlaceholder,
                  prefixIcon: CupertinoIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _submit,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.passwordRequired;
                    if (v.length < 6) return AppStrings.passwordMinLength;
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: AppStrings.login,
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2024 Admin App. All rights reserved.',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textHint,
              fontSize: 12,
            ),
      ),
    );
  }
}
