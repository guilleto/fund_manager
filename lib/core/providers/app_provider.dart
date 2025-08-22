import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/blocs/theme_bloc.dart';
import 'package:fund_manager/core/services/user_service.dart';
import 'package:fund_manager/core/services/notification_service.dart';
import 'package:fund_manager/core/services/theme_service.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';
import 'package:fund_manager/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:fund_manager/features/settings/presentation/blocs/settings_bloc.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserService>(
          create: (context) => MockUserService(MockNotificationService()),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => MockNotificationService(),
        ),
        RepositoryProvider<ThemeService>(
          create: (context) => AppThemeService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(
            create: (context) => AppBloc(
              context.read<UserService>(),
            )..add(const AppStarted()),
          ),
          BlocProvider<FundsBloc>(
            create: (context) => FundsBloc(
              context.read<UserService>(),
            )..add(const FundsStarted()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              userService: context.read<UserService>(),
            )..add(const DashboardStarted()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              context.read<UserService>(),
              context.read<ThemeService>(),
            ),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(
              context.read<ThemeService>(),
            )..add(const ThemeLoad()),
          ),
        ],
        child: child,
      ),
    );
  }
}
