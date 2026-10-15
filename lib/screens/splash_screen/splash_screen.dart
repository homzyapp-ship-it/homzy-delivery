import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/utils/app_update/bloc/app_update_state.dart';
import 'package:hyper_local/utils/extensions.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/screens/system_settings/bloc/system_settings_bloc.dart';
import 'package:hyper_local/screens/system_settings/bloc/system_settings_event.dart';
import '../../config/colors.dart';
import '../../config/global.dart';
import '../../config/helper.dart';
import '../../utils/app_update/bloc/app_update_bloc.dart';
import '../../utils/app_update/bloc/app_update_event.dart';
import '../../utils/app_update/model/update_config.dart';
import '../../utils/app_update/widgets/app_update_dialog.dart';
import '../../utils/notification_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  bool _updateDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppUpdateBloc>().add(CheckAppUpdate());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> navigate() async {
    try {
      await NotificationManager().initialize();

      // Fetch system settings even if token is empty
      final settingsCompleter = Completer<void>();
      if (mounted) {
        context.read<SystemSettingsBloc>().add(FetchSystemSettings(completer: settingsCompleter));
      }
      await settingsCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('⚠️ SPLASH SCREEN: System Settings fetch timed out');
        },
      );

      if (!Global.isOnboardingComplete) {
        if (mounted) {
          GoRouter.of(context).pushReplacement(AppRoutes.onBoarding);
        }
        return;
      }

      final token = await Global.getUserToken();
      log('✅ SPLASH SCREEN: User Token Here $token');

      if (token != null) {
        // User is authenticated, go to dashboard

        if (mounted) {
          redirectionCondition(context);
        }
      } else {
        // User is not authenticated, go to login
        if (mounted) {
          GoRouter.of(context).pushReplacement(AppRoutes.login);
        }
      }
    } catch (e) {
      log('❌ SPLASH SCREEN: Navigation error: $e');
      // If there's an error, redirect to login as fallback
      if (mounted) {
        try {
          GoRouter.of(context).pushReplacement(AppRoutes.login);
        } catch (navigationError) {
          log('❌ SPLASH SCREEN: Navigation fallback error: $navigationError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final settings = context.read<SystemSettingsBloc>().currentSettings;
    //     final playStore = settings?.riderPlaystoreLink ?? "";
    //     final appStore = settings?.riderAppstoreLink ?? "";

    bool isDarkMode = context.isDarkMode;
    return CustomScaffold(
      wantSafeArea: false,
      backgroundColor: AppColors.primaryColor,
      body: BlocListener<AppUpdateBloc, AppUpdateState>(
        listener: (context, state) {
          log('🔍 SPLASH SCREEN: AppUpdateState listener -> status: ${state.status}');
          if (state.status == AppUpdateStatus.success) {
            if (!state.isUpdateAvailable) {
              log('🔍 SPLASH SCREEN: No update available, navigating...');
              navigate();
            } else {
              log('🔍 SPLASH SCREEN: Update available (forced: ${state.isForced})');
              final isForced = state.isForced;
              _showUpdateDialog(state.config!, isForced: isForced);
            }
          }

          if (state.status == AppUpdateStatus.failure) {
            log('🔍 SPLASH SCREEN: Update check failed, failing open...');
            navigate();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              "assets/svg/doodle.svg",
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(AppColors.primaryColor.withValues(alpha: 0.75), BlendMode.srcATop),
            ),
            Center(child: Image.asset(myLogoImage(), width: 300, height: 300, fit: BoxFit.contain)),
          ],
        ),
      ),
    );
  }

  void _onForceUpdatePressed() {
    // Dialog stays open; url_launcher opens the store.
    // Nothing to resolve here — navigation stays blocked.
  }
  void _onSoftUpdateLater() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _updateDialogShowing = false;
    navigate();
  }

  void _showUpdateDialog(UpdateConfig config, {required bool isForced}) {
    if (_updateDialogShowing || !mounted) return;
    _updateDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AppUpdateDialog(
            config: config,
            isForced: isForced,
            onLater: isForced ? _onForceUpdatePressed : _onSoftUpdateLater,
          ),
    );
  }
}
