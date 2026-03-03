// lib/features/portfolio/presentation/state/portfolio_state.dart

import '../../domain/entities/portfolio_entity.dart';

abstract class PortfolioState {
  const PortfolioState();
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<PortfolioEntity> stocks;
  final PortfolioOverview? overview;
  final List<SymbolSummary> symbolSummaries;

  const PortfolioLoaded({
    required this.stocks,
    this.overview,
    this.symbolSummaries = const [],
  });

  PortfolioLoaded copyWith({
    List<PortfolioEntity>? stocks,
    PortfolioOverview? overview,
    List<SymbolSummary>? symbolSummaries,
  }) {
    return PortfolioLoaded(
      stocks: stocks ?? this.stocks,
      overview: overview ?? this.overview,
      symbolSummaries: symbolSummaries ?? this.symbolSummaries,
    );
  }
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);
}

class PortfolioActionLoading extends PortfolioState {
  final String action;

  const PortfolioActionLoading(this.action);
}

class PortfolioActionSuccess extends PortfolioState {
  final String message;

  const PortfolioActionSuccess(this.message);
}

class PortfolioActionError extends PortfolioState {
  final String message;

  const PortfolioActionError(this.message);
}