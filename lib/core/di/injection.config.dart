// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:fund_manager/core/di/injection.dart' as _i991;
import 'package:fund_manager/core/network/dio_client.dart' as _i356;
import 'package:fund_manager/features/dashboard/presentation/blocs/dashboard_bloc.dart'
    as _i977;
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart'
    as _i761;
import 'package:fund_manager/features/welcome/presentation/blocs/welcome_bloc.dart'
    as _i701;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final blocModule = _$BlocModule();
    gh.factory<_i356.DioClient>(() => _i356.DioClient());
    gh.lazySingleton<_i701.WelcomeBloc>(() => blocModule.welcomeBloc);
    gh.lazySingleton<_i977.DashboardBloc>(() => blocModule.dashboardBloc);
    gh.lazySingleton<_i761.FundsBloc>(() => blocModule.fundsBloc);
    return this;
  }
}

class _$BlocModule extends _i991.BlocModule {}
