// test/unit/watchlist/usecase/get_watchlist_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/watchlist/domain/entities/watchlist_entity.dart';
import 'package:stockex/features/watchlist/domain/repository/watchlist_repo.dart';
import 'package:stockex/features/watchlist/domain/usecase/watchlist_usecase.dart';

class MockWatchlistRepository extends Mock implements IWatchlistRepository {}

void main() {
  late MockWatchlistRepository mockRepository;
  late GetWatchlistUsecase usecase;

  setUp(() {
    mockRepository = MockWatchlistRepository();
    usecase = GetWatchlistUsecase(mockRepository);
  });

  const tWatchlist = [
    WatchlistEntity(
      id: 'w1', userId: 'user_123', symbol: 'NABIL', name: 'Nabil Bank Ltd.',
      ltp: 452.5, high: 460.0, low: 445.0, pointChange: 5.0,
      percentChange: 1.11, previousClose: 447.5, open: 448.0,
    ),
    WatchlistEntity(
      id: 'w2', userId: 'user_123', symbol: 'HBL', name: 'Himalayan Bank Ltd.',
      ltp: 321.8, high: 330.0, low: 315.0, pointChange: -3.0,
      percentChange: -0.92, previousClose: 324.8, open: 323.0,
    ),
  ];

  group('GetWatchlistUsecase', () {
    test('should return list of WatchlistEntity when successful', () async {
      // Arrange
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => const Right(tWatchlist));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Right(tWatchlist));
      verify(() => mockRepository.getWatchlist()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when watchlist is empty', () async {
      // Arrange
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase.call();

      // Assert
      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r, isEmpty),
      );
      verify(() => mockRepository.getWatchlist()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'No internet connection');
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getWatchlist()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository exactly once', () async {
      // Arrange
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => const Right([]));

      // Act
      await usecase.call();

      // Assert
      verify(() => mockRepository.getWatchlist()).called(1);
    });

    test('should preserve failure message from repository', () async {
      // Arrange
      const failure = ServerFailure(message: 'Session expired');
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call();

      // Assert
      result.fold(
        (f) => expect(f.message, equals('Session expired')),
        (_) => fail('Expected Left'),
      );
    });
  });
}