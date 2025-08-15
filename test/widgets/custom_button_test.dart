import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/widgets/custom_button.dart';
import '../test_utils.dart';

void main() {
  group('CustomButton Tests', () {
    testWidgets('should render button with text', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        const CustomButton(
          text: 'Test Button',
          onPressed: null,
        ),
      );

      TestUtils.expectTextExists('Test Button');
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await TestUtils.pumpWidget(
        tester,
        CustomButton(
          text: 'Test Button',
          onPressed: () {
            wasPressed = true;
          },
        ),
      );

      await TestUtils.tap(tester, TestUtils.findText('Test Button'));
      expect(wasPressed, true);
    });

    testWidgets('should not call onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;

      await TestUtils.pumpWidget(
        tester,
        CustomButton(
          text: 'Test Button',
          onPressed: () {
            wasPressed = true;
          },
          type: ButtonType.primary,
        ),
      );

      // Simular botón deshabilitado
      await TestUtils.pumpWidget(
        tester,
        const CustomButton(
          text: 'Test Button',
          onPressed: null,
        ),
      );

      await TestUtils.tap(tester, TestUtils.findText('Test Button'));
      expect(wasPressed, false);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        const CustomButton(
          text: 'Test Button',
          onPressed: null,
          isLoading: true,
        ),
      );

      // Verificar que el indicador de carga está presente
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render with icon when provided', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        const CustomButton(
          text: 'Test Button',
          onPressed: null,
          icon: Icons.add,
        ),
      );

      // Verificar que el icono está presente
      expect(find.byIcon(Icons.add), findsOneWidget);
      TestUtils.expectTextExists('Test Button');
    });

    testWidgets('should render with different button types', (WidgetTester tester) async {
      final buttonTypes = [
        ButtonType.primary,
        ButtonType.secondary,
        ButtonType.outline,
        ButtonType.danger,
      ];

      for (final type in buttonTypes) {
        await TestUtils.pumpWidget(
          tester,
          CustomButton(
            text: 'Test Button',
            onPressed: () {},
            type: type,
          ),
        );

        TestUtils.expectTextExists('Test Button');
      }
    });

    testWidgets('should render with full width when isFullWidth is true', (WidgetTester tester) async {
      await TestUtils.pumpWidget(
        tester,
        const CustomButton(
          text: 'Test Button',
          onPressed: null,
          isFullWidth: true,
        ),
      );

      // Verificar que el botón está presente
      expect(find.byType(ElevatedButton), findsOneWidget);
      TestUtils.expectTextExists('Test Button');
    });
  });
}
