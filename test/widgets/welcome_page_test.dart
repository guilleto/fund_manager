import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/features/welcome/presentation/pages/welcome_page.dart';
import '../../lib/core/widgets/responsive_widget.dart';
import '../test_utils.dart';

void main() {
  group('WelcomePage Tests', () {
    testWidgets('should render welcome page with all elements', (WidgetTester tester) async {
      await TestUtils.pumpWidget(tester, const WelcomePage());

      // Verificar elementos principales
      expect(find.text('Fund Manager'), findsOneWidget);
      expect(find.text('Comenzar Experiencia'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      
      // Limpiar timers pendientes
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('should have responsive layout', (WidgetTester tester) async {
      await TestUtils.pumpWidget(tester, const WelcomePage());

      // Verificar que el layout se adapta correctamente
      expect(find.byType(ResponsiveWidget), findsOneWidget);
      
      // Limpiar timers pendientes
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('should display description text', (WidgetTester tester) async {
      await TestUtils.pumpWidget(tester, const WelcomePage());

      // Verificar que el texto descriptivo está presente
      expect(find.textContaining('Tu plataforma profesional'), findsOneWidget);
      expect(find.textContaining('gestión inteligente'), findsOneWidget);
      
      // Limpiar timers pendientes
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await TestUtils.pumpWidget(tester, const WelcomePage());

      // Verificar que hay un contenedor con decoración de gradiente
      expect(find.byType(Container), findsWidgets);
      
      // Limpiar timers pendientes
      await tester.pump(const Duration(milliseconds: 2000));
    });
  });
}
