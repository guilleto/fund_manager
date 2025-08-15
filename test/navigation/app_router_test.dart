import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/navigation/app_router.dart';
import '../test_utils.dart';

void main() {
  group('AppRouter Tests', () {
    testWidgets('should navigate to welcome page', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        MaterialApp.router(
          routeInformationParser: AppRouter.routeInformationParser,
          routerDelegate: AppRouter.routerDelegate,
          backButtonDispatcher: AppRouter.backButtonDispatcher,
        ),
      );

      // Verificar que estamos en la página de bienvenida por defecto
      expect(find.text('Fund Manager'), findsOneWidget);
    });

    testWidgets('should navigate to dashboard', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        MaterialApp.router(
          routeInformationParser: AppRouter.routeInformationParser,
          routerDelegate: AppRouter.routerDelegate,
          backButtonDispatcher: AppRouter.backButtonDispatcher,
        ),
      );

      // Navegar al dashboard
      AppRouter.goToDashboard();
      await tester.pump();

      // Verificar que estamos en el dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should navigate to funds page', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        MaterialApp.router(
          routeInformationParser: AppRouter.routeInformationParser,
          routerDelegate: AppRouter.routerDelegate,
          backButtonDispatcher: AppRouter.backButtonDispatcher,
        ),
      );

      // Navegar a la página de fondos
      AppRouter.goToFunds();
      await tester.pump();

      // Verificar que estamos en la página de fondos
      expect(find.text('Mis Fondos'), findsOneWidget);
    });

    testWidgets('should handle back navigation', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        MaterialApp.router(
          routeInformationParser: AppRouter.routeInformationParser,
          routerDelegate: AppRouter.routerDelegate,
          backButtonDispatcher: AppRouter.backButtonDispatcher,
        ),
      );

      // Navegar al dashboard
      AppRouter.goToDashboard();
      await tester.pump();
      expect(find.text('Dashboard'), findsOneWidget);

      // Navegar a fondos
      AppRouter.goToFunds();
      await tester.pump();
      expect(find.text('Mis Fondos'), findsOneWidget);

      // Regresar
      AppRouter.goBack();
      await tester.pump();
      expect(find.text('Dashboard'), findsOneWidget);
    });

    test('should parse route information correctly', () async {
      final parser = AppRouter.routeInformationParser;
      
      // Probar parsing de rutas
      final welcomeRoute = await parser.parseRouteInformation(
        const RouteInformation(location: '/welcome'),
      );
      expect(welcomeRoute.route, AppRoute.welcome);

      final dashboardRoute = await parser.parseRouteInformation(
        const RouteInformation(location: '/dashboard'),
      );
      expect(dashboardRoute.route, AppRoute.dashboard);

      final fundsRoute = await parser.parseRouteInformation(
        const RouteInformation(location: '/funds'),
      );
      expect(fundsRoute.route, AppRoute.funds);

      // Ruta por defecto
      final defaultRoute = await parser.parseRouteInformation(
        const RouteInformation(location: '/'),
      );
      expect(defaultRoute.route, AppRoute.welcome);
    });

    test('should restore route information correctly', () {
      final parser = AppRouter.routeInformationParser;
      
      // Probar restauración de rutas
      final welcomeInfo = parser.restoreRouteInformation(
        const RouteInfo(route: AppRoute.welcome),
      );
      expect(welcomeInfo?.location, '/welcome');

      final dashboardInfo = parser.restoreRouteInformation(
        const RouteInfo(route: AppRoute.dashboard),
      );
      expect(dashboardInfo?.location, '/dashboard');

      final fundsInfo = parser.restoreRouteInformation(
        const RouteInfo(route: AppRoute.funds),
      );
      expect(fundsInfo?.location, '/funds');
    });
  });
}
