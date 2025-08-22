import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/services/user_service.dart';
import 'package:fund_manager/core/services/notification_service.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';

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
        ],
        child: child,
      ),
    );
  }
}
