import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/stock_local_data_source.dart';
import '../../data/datasources/stock_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/usecases/get_stock_details.dart';
import '../../domain/usecases/get_trending_stocks.dart';
import '../../domain/usecases/search_stocks.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/sign_in_user.dart';
import '../../domain/usecases/sign_out_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/is_signed_in.dart';
import '../../domain/usecases/update_balance.dart';
import '../../domain/usecases/get_alpaca_stock_history.dart';
import '../../presentation/cubits/stock/stock_cubit.dart';
import '../../presentation/cubits/auth/auth_cubit.dart';
import '../network/api_client.dart';
import '../network/alpaca_api_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Uuid());

  // Core
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => AlpacaApiClient(dio: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Cubits
  sl.registerFactory(
    () => AuthCubit(
      registerUser: sl(),
      signInUser: sl(),
      signOutUser: sl(),
      getCurrentUser: sl(),
      isSignedIn: sl(),
      updateBalance: sl(),
    ),
  );

  sl.registerFactory(
    () => StockCubit(
      getTrendingStocks: sl(),
      getStockDetails: sl(),
      searchStocks: sl(),
      getAlpacaStockHistory: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => IsSignedIn(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SignInUser(sl()));
  sl.registerLazySingleton(() => SignOutUser(sl()));
  sl.registerLazySingleton(() => UpdateBalance(sl()));
  sl.registerLazySingleton(() => GetTrendingStocks(sl()));
  sl.registerLazySingleton(() => GetStockDetails(sl()));
  sl.registerLazySingleton(() => SearchStocks(sl()));
  sl.registerLazySingleton(() => GetAlpacaStockHistory(sl()));

  // Repository
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(
      apiClient: sl(),
      alpacaApiClient: sl(),
    ),
  );
  
  sl.registerLazySingleton<StockLocalDataSource>(
    () => StockLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
      uuid: sl(),
    ),
  );
}
