import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:day40/main.dart';

void main() {
  group('Todo List Screen Tests', () {
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository();
      repository.clear();
    });

    tearDown(() {
      repository.clear();
    });

    // ============================================================
    // Test 1: List Screen States - Empty → Loading → Items
    // ============================================================
    testWidgets('List screen shows empty state when no todos exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_state_text')), findsOneWidget);
      expect(
        find.text('No todos yet. Add one to get started!'),
        findsOneWidget,
      );
    });

    testWidgets('List screen shows loading indicator during data fetch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byKey(const Key('loading_indicator')), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('loading_indicator')), findsNothing);
    });

    testWidgets('List screen displays todos when data is loaded', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      await repo.addTodo('Learn Flutter');
      await repo.addTodo('Write tests');

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Learn Flutter'), findsOneWidget);
      expect(find.text('Write tests'), findsOneWidget);
      expect(find.byKey(const Key('todos_list')), findsOneWidget);
    });

    // ============================================================
    // Test 2: Add Button Functionality
    // ============================================================
    testWidgets('Add button: input text → tap → item appears', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_state_text')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('todo_input_field')),
        'Complete Flutter course',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_todo_button')));
      await tester.pumpAndSettle();

      expect(find.text('Complete Flutter course'), findsOneWidget);
      expect(find.byKey(const Key('success_snackbar')), findsOneWidget);
    });

    testWidgets('Add button shows error for empty input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_todo_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('error_snackbar')), findsOneWidget);
      expect(
        find.text('Error: Exception: Title cannot be empty'),
        findsOneWidget,
      );
    });

    testWidgets('Multiple todos can be added sequentially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      for (final title in ['First task', 'Second task', 'Third task']) {
        await tester.enterText(
          find.byKey(const Key('todo_input_field')),
          title,
        );
        await tester.tap(find.byKey(const Key('add_todo_button')));
        await tester.pumpAndSettle();
      }

      expect(find.text('First task'), findsOneWidget);
      expect(find.text('Second task'), findsOneWidget);
      expect(find.text('Third task'), findsOneWidget);
    });

    // ============================================================
    // Test 3: Error Display
    // ============================================================
    testWidgets('Error is displayed with SnackBar when add fails', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      repo.setError(true);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('todo_input_field')),
        'Test task',
      );
      await tester.tap(find.byKey(const Key('add_todo_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('error_snackbar')), findsOneWidget);
      expect(find.text('Error: Exception: Failed to add todo'), findsOneWidget);
    });

    testWidgets('Error text is displayed in red color', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      repo.setError(true);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('todo_input_field')),
        'Test task',
      );
      await tester.tap(find.byKey(const Key('add_todo_button')));
      await tester.pumpAndSettle();

      final snackBar = find.byKey(const Key('error_snackbar'));
      expect(snackBar, findsOneWidget);
      final snackBarWidget = tester.widget<SnackBar>(snackBar);
      expect(snackBarWidget.backgroundColor, Colors.red);
    });

    // ============================================================
    // Test 4: Widget Keys Usage
    // ============================================================
    testWidgets('All important widgets have unique keys', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('todo_input_field')), findsOneWidget);
      expect(find.byKey(const Key('add_todo_button')), findsOneWidget);
      expect(find.byKey(const Key('empty_state_text')), findsOneWidget);
      expect(find.byKey(const Key('todos_list')), findsOneWidget);
    });

    // ============================================================
    // Test 5: Navigation to Detail Screen
    // ============================================================
    testWidgets('Tapping todo navigates to detail screen', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      await repo.addTodo('Learn Flutter Testing');

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Todo List'), findsOneWidget);

      await tester.tap(find.text('Learn Flutter Testing'));
      await tester.pumpAndSettle();

      expect(find.text('Todo Details'), findsOneWidget);
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
      expect(find.text('Learn Flutter Testing'), findsOneWidget);
    });

    testWidgets('Detail screen shows correct todo information', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      await repo.addTodo('Test Todo Details');

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Todo Details'));
      await tester.pumpAndSettle();

      expect(find.text('Todo Details'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('ID'), findsOneWidget);
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
      expect(find.byKey(const Key('detail_id')), findsOneWidget);
      expect(find.text('Test Todo Details'), findsOneWidget);
    });

    testWidgets('Can navigate back from detail screen', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      await repo.addTodo('Navigate back test');

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Navigate back test'));
      await tester.pumpAndSettle();

      expect(find.text('Todo Details'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Todo List'), findsOneWidget);
      expect(find.text('Navigate back test'), findsOneWidget);
    });

    testWidgets('Multiple todos can be navigated individually', (
      WidgetTester tester,
    ) async {
      final repo = TodoRepository();
      await repo.addTodo('Todo One');
      await repo.addTodo('Todo Two');

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo One'));
      await tester.pumpAndSettle();
      expect(find.text('Todo One'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todo Two'));
      await tester.pumpAndSettle();
      expect(find.text('Todo Two'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Todo One'), findsOneWidget);
      expect(find.text('Todo Two'), findsOneWidget);
    });

    // ============================================================
    // Test 6: Integration Tests
    // ============================================================
    testWidgets('Complete workflow: empty → add → navigate → back → delete', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_state_text')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('todo_input_field')),
        'Integration test todo',
      );
      await tester.tap(find.byKey(const Key('add_todo_button')));
      await tester.pumpAndSettle();

      expect(find.text('Integration test todo'), findsOneWidget);

      await tester.tap(find.text('Integration test todo'));
      await tester.pumpAndSettle();

      expect(find.text('Todo Details'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Todo List'), findsOneWidget);
      expect(find.text('Integration test todo'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Integration test todo'), findsNothing);
      expect(find.byKey(const Key('empty_state_text')), findsOneWidget);
    });
  });
}
