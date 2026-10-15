import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/system_settings/bloc/system_settings_bloc.dart';
import 'package:hyper_local/utils/extensions.dart';
import 'config/theme/theme.dart';
import 'config/theme/theme_bloc/theme_bloc.dart';
import 'config/theme/theme_bloc/theme_event.dart';
import 'config/theme/theme_bloc/theme_state.dart';
import 'config/localization_bloc/localization_bloc.dart';
import 'config/localization_bloc/localization_event.dart';
import 'config/localization_bloc/localization_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hyper_local/utils/location_monitor_widget.dart';
import 'package:hyper_local/config/app_initializer.dart';
import 'package:hyper_local/config/injection_container.dart';
import 'package:hyper_local/utils/background_location_service.dart';
import 'package:hyper_local/config/app_bloc_observer.dart';
import 'package:hyper_local/screens/dashboard/bloc/notification/notification_bloc.dart';
import 'package:hyper_local/utils/widgets/connectivity_wrapper.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:hyper_local/config/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  await BackgroundLocationService.initializeService();
  await BackgroundLocationService.restartServicesIfNeeded();

  Bloc.observer = AppBlocObserver();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final QuickActions _quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    _setupQuickActions();
  }

  void _setupQuickActions() {
    _quickActions.initialize((String type) {
      final token = Global.userToken;
      if (token != null && token.isNotEmpty) {
        if (type == 'earnings') {
          MyAppRoute.router.push(AppRoutes.earnings);
        } else if (type == 'new_orders') {
          MyAppRoute.router.push(AppRoutes.feed);
        } else if (type == 'pickups') {
          MyAppRoute.router.push('${AppRoutes.feed}?tab=1');
        }
      }
    });

    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'earnings', localizedTitle: 'Earnings', icon: 'shortcut_earnings'),
      const ShortcutItem(type: 'new_orders', localizedTitle: 'New Orders', icon: 'shortcut_new_orders'),
      const ShortcutItem(type: 'pickups', localizedTitle: 'Pickups', icon: 'shortcut_pickups'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()..add(LoadTheme())),
        BlocProvider(create: (_) => sl<NotificationBloc>()..add(FetchNotifications())),
        BlocProvider(create: (_) => sl<SystemSettingsBloc>()),
        BlocProvider(create: (_) => sl<LocalizationBloc>()..add(LoadSavedLocale())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = context.isDarkMode;
          return BlocBuilder<LocalizationBloc, LocalizationState>(
            builder: (context, locState) {
              return SafeArea(
                top: false,
                bottom: Platform.isIOS ? false : true,
                left: false,
                right: false,
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  theme: AppColor.getLightTheme(),
                  darkTheme: AppColor.getDarkTheme(),
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  locale: locState.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: LocalizationBloc.supportedLocales,
                  builder: (context, child) {
                    return FToastBuilder()(context, LocationMonitor(child: ConnectivityWrapper(child: child!)));
                  },
                  routerConfig: MyAppRoute.router,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
