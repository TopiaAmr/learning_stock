import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/auth/auth_state.dart';
import 'presentation/cubits/stock/stock_cubit.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StockCubit>(
          create: (_) => di.sl<StockCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        title: 'Learning Stock',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const HomePage();
            }
            return const LoginPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
