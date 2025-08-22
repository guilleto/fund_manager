import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/app_provider.dart';
import 'core/services/theme_service.dart';
import 'core/blocs/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeService = context.read<ThemeService>();
          
          bool isDarkMode = false;
          if (state is ThemeLoaded) {
            isDarkMode = state.isDarkMode;
          }
          
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeService.getLightTheme(),
            darkTheme: themeService.getDarkTheme(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routeInformationParser: AppRouter.routeInformationParser,
            routerDelegate: AppRouter.routerDelegate,
            backButtonDispatcher: AppRouter.backButtonDispatcher,
          );
        },
      ),
    );
  }
}
