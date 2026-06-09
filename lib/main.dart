import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/api/token_storage.dart';
import 'core/localization/localization_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/detection/presentation/cubit/detection_cubit.dart';
import 'features/history/presentation/cubit/history_cubit.dart';
import 'features/reports/presentation/cubit/reports_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/detection/presentation/cubit/video_prediction_cubit.dart';
import 'features/detection/presentation/cubit/text_prediction_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await di.init();

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationManager.supportedLocales,
      path: LocalizationManager.translationsPath,
      fallbackLocale: LocalizationManager.fallbackLocale,
      startLocale: LocalizationManager.fallbackLocale,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = sl<TokenStorage>().isLoggedIn;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<DetectionCubit>()),
        BlocProvider(create: (_) => sl<HistoryCubit>()),
        BlocProvider(create: (_) => sl<ReportsCubit>()),
        BlocProvider(create: (_) => sl<ProfileCubit>()),
        BlocProvider(create: (_) => sl<VideoPredictionCubit>()),
        BlocProvider(create: (_) => sl<TextPredictionCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'VioGuard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: isLoggedIn ? Routes.home : Routes.login,
            onGenerateRoute: AppRouter.generateRoute,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    );
  }
}
