import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/funds/presentation/pages/funds_page.dart';

// Definir las rutas disponibles
enum AppRoute {
  welcome,
  dashboard,
  funds,
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
    final uri = Uri.parse(routeInformation.location ?? '/');
    
    switch (uri.path) {
      case '/':
      case '/welcome':
        return const RouteInfo(route: AppRoute.welcome);
      case '/dashboard':
        return const RouteInfo(route: AppRoute.dashboard);
      case '/funds':
        return const RouteInfo(route: AppRoute.funds);
      default:
        return const RouteInfo(route: AppRoute.welcome);
    }
  }

  @override
  RouteInformation? restoreRouteInformation(RouteInfo configuration) {
    switch (configuration.route) {
      case AppRoute.welcome:
        return const RouteInformation(location: '/welcome');
      case AppRoute.dashboard:
        return const RouteInformation(location: '/dashboard');
      case AppRoute.funds:
        return const RouteInformation(location: '/funds');
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
    return Navigator(
      key: navigatorKey,
      pages: _buildPages(),
      onDidRemovePage: (page) {
        if (page.key == const ValueKey('welcome')) {
          _handleBackNavigation();
        }
      },
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
    }
  }

  void _handleBackNavigation() {
    // Lógica para manejar la navegación hacia atrás
    switch (_currentConfiguration.route) {
      case AppRoute.dashboard:
        _setNewRoute(const RouteInfo(route: AppRoute.welcome));
        break;
      case AppRoute.funds:
        _setNewRoute(const RouteInfo(route: AppRoute.dashboard));
        break;
      case AppRoute.welcome:
        // No hacer nada, ya estamos en welcome
        break;
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

  // Métodos públicos para navegación
  void goToWelcome() {
    _setNewRoute(const RouteInfo(route: AppRoute.welcome));
  }

  void goToDashboard() {
    _setNewRoute(const RouteInfo(route: AppRoute.dashboard));
  }

  void goToFunds() {
    _setNewRoute(const RouteInfo(route: AppRoute.funds));
  }

  void goBack() {
    _handleBackNavigation();
  }
}

// Dispatcher para el botón de retroceso
class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  final AppRouterDelegate routerDelegate;

  AppBackButtonDispatcher(this.routerDelegate);

  @override
  Future<bool> didPopRoute() async {
    routerDelegate.goBack();
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

  // Métodos de conveniencia para navegación
  static void goToWelcome() {
    _routerDelegate.goToWelcome();
  }

  static void goToDashboard() {
    _routerDelegate.goToDashboard();
  }

  static void goToFunds() {
    _routerDelegate.goToFunds();
  }

  static void goBack() {
    _routerDelegate.goBack();
  }
}
