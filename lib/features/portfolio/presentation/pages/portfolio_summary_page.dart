// lib/features/portfolio/presentation/pages/portfolio_summary_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:stockex/features/portfolio/presentation/viewmodel/portfolio_viewmodel.dart';
import 'package:stockex/features/portfolio/presentation/widgets/sector_pie_chart.dart';

class PortfolioSummaryPage extends ConsumerStatefulWidget {
  const PortfolioSummaryPage({super.key});

  @override
  ConsumerState<PortfolioSummaryPage> createState() =>
      _PortfolioSummaryPageState();
}

class _PortfolioSummaryPageState extends ConsumerState<PortfolioSummaryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Only reload if portfolio isn't already loaded
      final state = ref.read(portfolioViewModelProvider);
      if (state is! PortfolioLoaded) {
        ref.read(portfolioViewModelProvider.notifier).loadPortfolio();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Portfolio Summary',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(portfolioViewModelProvider.notifier).loadPortfolio(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PortfolioState state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(portfolioViewModelProvider.notifier).loadPortfolio(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is PortfolioLoaded) {
      if (state.symbolSummaries.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No holdings to display',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async =>
            ref.read(portfolioViewModelProvider.notifier).loadPortfolio(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: SectorPieChart(summaries: state.symbolSummaries),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}