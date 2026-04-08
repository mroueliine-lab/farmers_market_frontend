import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:farmers_market/features/auth/presentation/login_screen.dart';
import 'package:farmers_market/features/auth/providers/auth_provider.dart';
import 'package:farmers_market/features/auth/data/repositories/auth_repository.dart';
import 'package:farmers_market/features/auth/data/models/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Widget buildScreen(AuthRepository repo) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.restoreSession()).thenAnswer((_) async => null);
  });

  testWidgets('renders email field, password field, and login button',
      (tester) async {
    await tester.pumpWidget(buildScreen(mockRepo));

    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('calls login with entered credentials on button tap',
      (tester) async {
    when(() => mockRepo.login(any(), any())).thenAnswer((_) async =>
        UserModel(id: 1, name: 'Alice', email: 'alice@test.com', role: 'operator'));

    await tester.pumpWidget(buildScreen(mockRepo));

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'alice@test.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    verify(() => mockRepo.login('alice@test.com', 'secret123')).called(1);
  });

  testWidgets('shows loading indicator while login is in progress',
      (tester) async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(id: 1, name: 'Alice', email: 'a@a.com', role: 'operator');
    });

    await tester.pumpWidget(buildScreen(mockRepo));

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'alice@test.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump(); // first frame — loading starts

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsNothing);

    // Advance past the delay so the timer resolves and no pending timers remain.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('shows error dialog on failed login', (tester) async {
    when(() => mockRepo.login(any(), any()))
        .thenThrow(Exception('Invalid credentials'));

    await tester.pumpWidget(buildScreen(mockRepo));

    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'alice@test.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('login button is disabled while loading', (tester) async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(id: 1, name: 'Alice', email: 'a@a.com', role: 'operator');
    });

    await tester.pumpWidget(buildScreen(mockRepo));
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'alice@test.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'secret');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump(); // loading starts

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    // Resolve the pending delayed future so the test ends cleanly.
    await tester.pump(const Duration(seconds: 2));
  });
}
