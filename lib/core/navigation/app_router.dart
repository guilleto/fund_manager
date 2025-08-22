import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fund_manager/features/funds/presentation/pages/fund_details_page.dart';

import '../constants/app_constants.dart';
import '../blocs/app_bloc.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/funds/presentation/pages/funds_page.dart';
import '../../features/funds/presentation/pages/my_funds_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

// Definir las rutas disponibles
enum AppRoute {
  welcome,
  dashboard,
  funds,
  myFunds,
  fundDetails,
  transactions,
  settings,
}

// Clase para manejar la información de la ruta
class RouteInfo {
  final AppRoute route;
  final Map<String, dynamic>? arguments;

  const RouteInfo({
    required this.route,
    this.arguments,
  });
}

// Parser para convertir la información de la ruta
class AppRouteInformationParser extends RouteInformationParser<RouteInfo> {
  @override
  Future<RouteInfo> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.uri.toString());

    switch (uri.path) {
      case '/':
      case '/welcome':
        return const RouteInfo(route: AppRoute.welcome);
      case '/dashboard':
        return const RouteInfo(route: AppRoute.dashboard);
      case '/funds':
        return const RouteInfo(route: AppRoute.funds);
      case '/my-funds':
        return const RouteInfo(route: AppRoute.myFunds);
      case '/fund-details':
        return const RouteInfo(route: AppRoute.fundDetails);
      case '/transactions':
        return const RouteInfo(route: AppRoute.transactions);
      case '/settings':
        return const RouteInfo(route: AppRoute.settings);
      default:
        return const RouteInfo(route: AppRoute.welcome);
    }
  }

  @override
  RouteInformation? restoreRouteInformation(RouteInfo configuration) {
    switch (configuration.route) {
      case AppRoute.welcome:
        return RouteInformation(uri: Uri.parse('/welcome'));
      case AppRoute.dashboard:
        return RouteInformation(uri: Uri.parse('/dashboard'));
      case AppRoute.funds:
        return RouteInformation(uri: Uri.parse('/funds'));
      case AppRoute.myFunds:
        return RouteInformation(uri: Uri.parse('/my-funds'));
      case AppRoute.fundDetails:
        return RouteInformation(uri: Uri.parse('/fund-details'));
      case AppRoute.transactions:
        return RouteInformation(uri: Uri.parse('/transactions'));
      case AppRoute.settings:
        return RouteInformation(uri: Uri.parse('/settings'));
    }
  }
}

// Delegate para manejar el estado de navegación
class AppRouterDelegate extends RouterDelegate<RouteInfo>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInfo> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  RouteInfo _currentConfiguration = const RouteInfo(route: AppRoute.welcome);

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  RouteInfo get currentConfiguration => _currentConfiguration;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppLoaded) {
          _setNewRoute(RouteInfo(route: state.currentRoute));
        }
      },
      child: Navigator(
        key: navigatorKey,
        pages: _buildPages(),
        onPopPage: (route, result) {
          // Manejar el botón de retroceso del navegador
          if (!route.didPop(result)) {
            return false;
          }

          // Disparar evento de navegación hacia atrás en el AppBloc
          context.read<AppBloc>().add(const AppNavigateBack());
          return true;
        },
      ),
    );
  }

  List<Page> _buildPages() {
    switch (_currentConfiguration.route) {
      case AppRoute.welcome:
        return [
          const MaterialPage(
            key: ValueKey('welcome'),
            child: WelcomePage(),
          ),
        ];
      case AppRoute.dashboard:
        return [
          const MaterialPage(
            key: ValueKey('dashboard'),
            child: DashboardPage(),
          ),
        ];
      case AppRoute.funds:
        return [
          const MaterialPage(
            key: ValueKey('funds'),
            child: FundsPage(),
          ),
        ];
      case AppRoute.myFunds:
        return [
          const MaterialPage(
            key: ValueKey('my-funds'),
            child: MyFundsPage(),
          ),
        ];
      case AppRoute.fundDetails:
        return [
          const MaterialPage(
            key: ValueKey('fund-details'),
            child: FundDetailsPage(),
          ),
        ];
      case AppRoute.transactions:
        return [
          const MaterialPage(
            key: ValueKey('transactions'),
            child: TransactionsPage(),
          ),
        ];
      case AppRoute.settings:
        return [
          const MaterialPage(
            key: ValueKey('settings'),
            child: SettingsPage(),
          ),
        ];
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInfo configuration) async {
    _setNewRoute(configuration);
  }

  void _setNewRoute(RouteInfo configuration) {
    if (_currentConfiguration != configuration) {
      _currentConfiguration = configuration;
      notifyListeners();
    }
  }
}

// Dispatcher para el botón de retroceso
class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  final AppRouterDelegate routerDelegate;

  AppBackButtonDispatcher(this.routerDelegate);

  @override
  Future<bool> didPopRoute() async {
    return true;
  }
}

// Clase principal del router
class AppRouter {
  static final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();
  static final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  static final AppBackButtonDispatcher _backButtonDispatcher =
      AppBackButtonDispatcher(_routerDelegate);

  static RouteInformationParser<RouteInfo> get routeInformationParser =>
      _routeInformationParser;

  static RouterDelegate<RouteInfo> get routerDelegate => _routerDelegate;

  static BackButtonDispatcher get backButtonDispatcher => _backButtonDispatcher;
}
