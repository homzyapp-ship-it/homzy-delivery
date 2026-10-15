import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/screens/system_settings/bloc/system_settings_bloc.dart';
import 'package:hyper_local/screens/system_settings/bloc/system_settings_state.dart';
import 'package:hyper_local/utils/extensions.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/custom_card.dart';
import '../../../config/colors.dart';
import '../../../config/helper.dart';
import '../../../utils/widgets/toast_message.dart';
import '../../../utils/widgets/custom_textfield.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/auth_bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _applyDemoCredentialsIfNeeded() {
    final isDemo = context.read<SystemSettingsBloc>().isDemo;
    log('IS Demo on : $isDemo');

    if (!(isDemo || kDebugMode)) return;

    if (_emailController.text.isEmpty) {
      _emailController.text = 'rider@gmail.com';
    }

    if (_passwordController.text.isEmpty) {
      _passwordController.text = '12345678';
    }
  }

  @override
  void initState() {
    super.initState();
    _applyDemoCredentialsIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bool isLoggedinOnce = Global.isLoggedinOnce;
    final scaffoldBg = AppColors.primaryColor.withValues(alpha: .1);
    final double height = MediaQuery.of(context).size.height * 0.35;
    return CustomScaffold(
      resizeToAvoidBottomInset: true,
      wantSafeArea: false,
      backgroundColor: isDark ? null : Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<SystemSettingsBloc, SystemSettingsState>(
            listener: (context, state) {
              _applyDemoCredentialsIfNeeded();
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (BuildContext context, AuthState state) {
              log('State $state');

              if (state.status == ApiStatus.success) {
                // Persist that the user has logged in at least once
                Global.setLoggedinOnce(true);

                redirectionCondition(context);

                ToastManager.show(context: context, message: state.message);
              } else if (state.status == ApiStatus.failed) {
                ToastManager.show(context: context, message: state.message);
              }
            },
          ),
        ],
        child: Container(
          height: double.infinity,
          color: scaffoldBg,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: kToolbarHeight),
                    height: height,
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(30)),
                    child: Center(child: Image.asset(myLogoImage(), width: 250, height: 250, fit: BoxFit.contain)),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                            children: [
                              TextSpan(
                                text: isLoggedinOnce ? 'Welcome ' : 'Log ',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                              TextSpan(
                                text: isLoggedinOnce ? 'Back!' : 'In',
                                style: const TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomText(
                          text: AppLocalizations.of(context)!.loginToContinueDeliveringHappiness,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Form Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: CustomCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: 24.r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            email(),
                            const SizedBox(height: 16),
                            password(),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  context.push(AppRoutes.forgotPassword);
                                },
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.forgotPassword,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state.status == ApiStatus.loading;
                                return CustomButton(
                                  isLoading: isLoading,
                                  text: AppLocalizations.of(context)!.login,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        LoginRequest(email: _emailController.text, password: _passwordController.text),
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Expanded(child: Divider(thickness: .3)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.or,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Expanded(child: Divider(thickness: .3)),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: '${AppLocalizations.of(context)!.continueWith} ',
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () {
                                    context.push(AppRoutes.phoneLogin);
                                  },
                                  child: Center(
                                    child: CustomText(
                                      text: AppLocalizations.of(context)!.phoneNumber,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.dontHaveAccount,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () {
                                    context.push(AppRoutes.register);
                                  },
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.register,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Create Account section
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget email() {
    return CustomTextFormField(
      controller: _emailController,
      hintText: AppLocalizations.of(context)!.enterYourEmail,
      prefixIcon: TablerIcons.mail,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterYourEmail;
        }
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return AppLocalizations.of(context)!.pleaseEnterAValidEmail;
        }
        return null;
      },
    );
  }

  Widget password() {
    return CustomTextFormField(
      controller: _passwordController,
      hintText: AppLocalizations.of(context)!.enterYourPassword,
      prefixIcon: TablerIcons.lock,
      suffixIcon: _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
      onSuffixIconTap: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterYourPassword;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)!.passwordMustBeAtLeast6Characters;
        }
        return null;
      },
    );
  }
}
