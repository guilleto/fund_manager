import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection.config.dart';
import '../../features/welcome/presentation/blocs/welcome_bloc.dart';
import '../../features/dashboard/presentation/blocs/dashboard_bloc.dart';
import '../../features/funds/presentation/blocs/funds_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

// Configuración de BLoCs
@module
abstract class BlocModule {
  @lazySingleton
  WelcomeBloc get welcomeBloc => WelcomeBloc();

  @lazySingleton
  DashboardBloc get dashboardBloc => DashboardBloc();

  @lazySingleton
  FundsBloc get fundsBloc => FundsBloc();
}
