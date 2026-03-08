// test/widget/watchlist/watchlist_page_test.dart

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/watchlist/domain/entities/watchlist_entity.dart';
import 'package:stockex/features/watchlist/domain/usecase/watchlist_usecase.dart';
import 'package:stockex/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:stockex/core/services/storage/user_session_service.dart';

class MockGetWatchlistUsecase extends Mock implements GetWatchlistUsecase {}
class MockAddToWatchlistUsecase extends Mock implements AddToWatchlistUsecase {}
class MockRemoveFromWatchlistUsecase extends Mock implements RemoveFromWatchlistUsecase {}
class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockGetWatchlistUsecase mockGetWatchlistUsecase;
  late MockAddToWatchlistUsecase mockAddToWatchlistUsecase;
  late MockRemoveFromWatchlistUsecase mockRemoveFromWatchlistUsecase;
  late MockUserSessionService mockUserSessionService;

  setUpAll(() {
    registerFallbackValue(
      const AddToWatchlistParams(
        userId: 'fallback',
        entity: WatchlistEntity(
          userId: 'fallback', symbol: 'FALLBACK', name: 'Fallback',
          ltp: 0.0, high: 0.0, low: 0.0, pointChange: 0.0,
          percentChange: 0.0, previousClose: 0.0, open: 0.0,
        ),
      ),
    );
    registerFallbackValue(
      const RemoveFromWatchlistParams(symbol: 'FALLBACK'),
    );
  });

  setUp(() {
    mockGetWatchlistUsecase = MockGetWatchlistUsecase();
    mockAddToWatchlistUsecase = MockAddToWatchlistUsecase();
    mockRemoveFromWatchlistUsecase = MockRemoveFromWatchlistUsecase();
    mockUserSessionService = MockUserSessionService();

    // Default stub for getUserId used in addToWatchlist
    when(() => mockUserSessionService.getUserId())
        .thenReturn('user_123');
  });

  const tEntity = WatchlistEntity(
    id: 'w1', userId: 'user_123', symbol: 'NABIL', name: 'Nabil Bank Ltd.',
    ltp: 452.5, high: 460.0, low: 445.0, pointChange: 5.0,
    percentChange: 1.11, previousClose: 447.5, open: 448.0,
  );

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        getWatchlistUsecaseProvider.overrideWith((ref) => mockGetWatchlistUsecase),
        addToWatchlistUsecaseProvider.overrideWith((ref) => mockAddToWatchlistUsecase),
        removeFromWatchlistUsecaseProvider.overrideWith((ref) => mockRemoveFromWatchlistUsecase),
        userSessionServiceProvider.overrideWith((ref) => mockUserSessionService),
      ],
      child: const MaterialApp(home: WatchlistPage()),
    );
  }

  group('WatchlistPage UI Elements', () {
    testWidgets('should display Watchlist title', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Watchlist'), findsOneWidget);
    });

    testWidgets('should display search hint text', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(
        find.text('Search stock symbol or name (e.g. NABIL, NTC)'),
        findsOneWidget,
      );
    });

    testWidgets('should display search icon', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display subtitle text', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Search NEPSE stocks and add to watchlist'), findsOneWidget);
    });
  });

  group('WatchlistPage Loaded State', () {
    testWidgets('should show empty message when watchlist is empty', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('No stocks in watchlist yet.\nSearch and add stocks to get started.'),
        findsOneWidget,
      );
    });

    testWidgets('should display stock symbol when watchlist has items', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([tEntity]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('NABIL'), findsOneWidget);
    });

    testWidgets('should display stock name when watchlist has items', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([tEntity]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nabil Bank Ltd.'), findsOneWidget);
    });

    testWidgets('should display delete icon for each watchlist item', (tester) async {
      // Arrange
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Right([tEntity]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('WatchlistPage Loading State', () {
    testWidgets('should show loading indicator while fetching watchlist', (tester) async {
      // Arrange — use Completer so no pending timer is left
      final completer = Completer<Either<Failure, List<WatchlistEntity>>>();
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // one frame — still loading, completer not resolved

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending async work after test ends
      completer.complete(const Right([]));
      await tester.pumpAndSettle();
    });
  });

  group('WatchlistPage Error State', () {
    testWidgets('should show error snackbar when loading fails', (tester) async {
      // Arrange
      const failure = ServerFailure(message: 'No internet connection');
      when(() => mockGetWatchlistUsecase.call())
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // trigger load
      await tester.pump(const Duration(milliseconds: 100)); // let snackbar appear

      // Assert
      expect(find.text('No internet connection'), findsOneWidget);
    });
  });
}