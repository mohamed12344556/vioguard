import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_info.dart';
import '../api/api_consumer.dart';
import '../api/api_interceptors.dart';
import '../api/dio_consumer.dart';
import '../api/token_storage.dart';
import '../config/app_config.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

import '../../features/detection/data/datasources/detection_remote_datasource.dart';
import '../../features/detection/data/datasources/video_prediction_datasource.dart';
import '../../features/detection/data/repositories/detection_repository.dart';
import '../../features/detection/presentation/cubit/detection_cubit.dart';
import '../../features/detection/presentation/cubit/video_prediction_cubit.dart';

import '../../features/history/data/datasources/history_remote_datasource.dart';
import '../../features/history/data/repositories/history_repository.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';

import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/reports/data/repositories/reports_repository.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! Core
  sl.registerLazySingleton(() => TokenStorage(sl()));

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(getToken: () async => sl<TokenStorage>().getToken()),
    );
    dio.interceptors.add(ApiInterceptor());

    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  });

  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl()));

  //! Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => AuthCubit(repository: sl(), tokenStorage: sl()),
  );

  //! Detection
  sl.registerLazySingleton<DetectionRemoteDataSource>(
    () => DetectionRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<DetectionRepository>(
    () => DetectionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => DetectionCubit(repository: sl()),
  );

  //! Video Prediction (AI Model)
  sl.registerLazySingleton<VideoPredictionDataSource>(
    () => VideoPredictionDataSourceImpl(dio: Dio()),
  );
  sl.registerFactory(
    () => VideoPredictionCubit(dataSource: sl()),
  );

  //! History
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => HistoryCubit(repository: sl()),
  );
  sl.registerFactory(
    () => HistoryDetailsCubit(repository: sl()),
  );

  //! Reports
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => ReportsCubit(repository: sl()),
  );

  //! Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => ProfileCubit(repository: sl(), tokenStorage: sl()),
  );
}
