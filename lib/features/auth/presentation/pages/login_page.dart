import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.isAuthenticated) {
            context.go('/dashboard');
          }
        },
        child: Row(
          children: [
            // Left Panel - Branding
            Expanded(
              flex: 5,
              child: Container(
                color: AppColors.primary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.appTagline,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureItem(Icons.gavel, 'Vehicle Auctions'),
                            const SizedBox(height: 12),
                            _buildFeatureItem(Icons.home_work, 'Property Auctions'),
                            const SizedBox(height: 12),
                            _buildFeatureItem(Icons.storefront, 'Car Bazaar'),
                            const SizedBox(height: 12),
                            _buildFeatureItem(Icons.people, 'User Management'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Right Panel - Login Form
            Expanded(
              flex: 4,
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.loginTitle,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.loginSubtitle,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 48),

                            // Email Field
                            CustomTextField(
                              label: AppStrings.email,
                              hint: 'admin@vehicleduniya.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.invalidEmail;
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return AppStrings.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            CustomTextField(
                              label: AppStrings.password,
                              hint: 'Enter your password',
                              controller: _passwordController,
                              obscureText: true,
                              prefixIcon: Icons.lock_outlined,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _onLogin(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.invalidPassword;
                                }
                                if (value.length < 6) {
                                  return AppStrings.invalidPassword;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: const Text(AppStrings.forgotPassword),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return CustomButton(
                                  text: AppStrings.login,
                                  isFullWidth: true,
                                  isLoading: state.isLoading,
                                  onPressed: _onLogin,
                                  height: 52,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
