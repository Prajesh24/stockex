// lib/features/portfolio/presentation/pages/portfolio_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:stockex/core/services/sensor/shake_detector.dart';
import 'package:stockex/core/services/sensor/flip_detector.dart';
import 'package:stockex/features/portfolio/domain/entities/portfolio_entity.dart';
import 'package:stockex/features/portfolio/presentation/viewmodel/portfolio_viewmodel.dart';
import 'package:stockex/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:stockex/features/portfolio/presentation/widgets/add_stock_dialog.dart';
import 'package:stockex/features/portfolio/presentation/widgets/sell_stock_dialog.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  final ShakeDetector _shakeDetector = ShakeDetector();
  final FlipDetector _flipDetector = FlipDetector();

  bool _privacyMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(portfolioViewModelProvider.notifier).loadPortfolio();
    });

    // Keep screen on so face-down doesn't trigger screen-off
    WakelockPlus.enable();

    // ── Gesture 1: Shake to refresh ──────────────────────────────────────────
    _shakeDetector.start(_onShake);

    // ── Gesture 2: Flip face-down/up for privacy mode ─────────────────────────
    _flipDetector.start(
      onFaceDown: _onFaceDown,
      onFaceUp: _onFaceUp,
    );
  }

  void _onShake() {
    ref.read(portfolioViewModelProvider.notifier).loadPortfolio();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Refreshing portfolio…'),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _onFaceDown() {
    if (!mounted) return;
    setState(() => _privacyMode = true);
    // Haptic confirms privacy activated without needing to look at screen
    HapticFeedback.mediumImpact();
  }

  void _onFaceUp() {
    if (!mounted) return;
    setState(() => _privacyMode = false);
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    // Release wakelock when leaving page — don't drain battery elsewhere
    WakelockPlus.disable();
    _shakeDetector.dispose();
    _flipDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioViewModelProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_NP',
      symbol: 'NPR ',
      decimalDigits: 2,
    );

    ref.listen(portfolioViewModelProvider, (previous, next) {
      if (next is PortfolioActionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
      } else if (next is PortfolioActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBody(state, currencyFormat),

          // ── Privacy overlay — covers everything when face-down ─────────────
          if (_privacyMode)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.93),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          color: Colors.grey[600], size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Privacy Mode',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Flip phone face-up to reveal',
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // Hide FAB in privacy mode too
      floatingActionButton: _privacyMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddStockDialog(context),
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.add),
              label: const Text('Add Stock'),
            ),
    );
  }

  Widget _buildBody(PortfolioState state, NumberFormat format) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
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

    if (state is PortfolioActionLoading) {
      return Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.action,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (state is PortfolioActionSuccess || state is PortfolioActionError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PortfolioLoaded) {
      return RefreshIndicator(
        onRefresh: () async =>
            ref.read(portfolioViewModelProvider.notifier).loadPortfolio(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(state),
              const SizedBox(height: 24),
              if (state.overview != null)
                _buildOverviewCards(state.overview!, format),
              const SizedBox(height: 24),
              _buildHoldingsSection(state.symbolSummaries, format),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHeader(PortfolioLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Portfolio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${state.stocks.length} stocks',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        IconButton(
          onPressed: () =>
              ref.read(portfolioViewModelProvider.notifier).loadPortfolio(),
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(PortfolioOverview overview, NumberFormat format) {
    final totalInvestment = overview.totalInvestment;
    final currentValue = overview.currentValue;
    final profitLoss = currentValue - totalInvestment;
    final isProfit = profitLoss >= 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _OverviewCard(
          title: 'Total Investment',
          value: format.format(totalInvestment),
          valueColor: Colors.white,
          icon: Icons.account_balance_wallet,
        ),
        _OverviewCard(
          title: 'Current Value',
          value: format.format(currentValue),
          valueColor: Colors.white,
          icon: Icons.trending_up,
        ),
        _OverviewCard(
          title: 'Unrealized P/L',
          value: '${isProfit ? '+' : ''}${format.format(profitLoss)}',
          valueColor: isProfit ? Colors.green : Colors.red,
          subtitle:
              '${isProfit ? '+' : ''}${overview.profitLossPercent.toStringAsFixed(2)}%',
          icon: isProfit ? Icons.trending_up : Icons.trending_down,
        ),
        _OverviewCard(
          title: 'Total Fees',
          value: format.format(overview.totalFees),
          valueColor: Colors.orange,
          icon: Icons.money_off,
        ),
      ],
    );
  }

  Widget _buildHoldingsSection(
    List<SymbolSummary> summaries,
    NumberFormat format,
  ) {
    if (summaries.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Your portfolio is empty',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Holdings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: summaries.length,
          itemBuilder: (context, index) {
            final stock = summaries[index];
            return _StockCard(
              summary: stock,
              format: format,
              privacyMode: _privacyMode,
              onSell: () => _showSellDialog(stock),
              onDelete: () => _confirmDelete(stock),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _showAddStockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddStockDialog(
        onAdd: (params) {
          ref.read(portfolioViewModelProvider.notifier).addStock(
                symbol: params['symbol']!,
                name: params['name']!,
                sector: params['sector'],
                transactionType: params['transactionType']!,
                units: int.parse(params['units']!),
                buyPrice: double.parse(params['buyPrice']!),
                buyDate: params['buyDate']!,
                ltp: params['ltp'] != null
                    ? double.tryParse(params['ltp']!)
                    : null,
              );
        },
      ),
    );
  }

  void _showSellDialog(SymbolSummary summary) {
    final availableStock = summary.individualStocks.firstWhere(
      (s) => s.remainingUnits > 0,
      orElse: () => summary.individualStocks.first,
    );

    showDialog(
      context: context,
      builder: (context) => SellStockDialog(
        stock: availableStock,
        onSell: (params) {
          ref.read(portfolioViewModelProvider.notifier).sellStock(
                id: availableStock.id!,
                units: int.parse(params['units']!),
                sellPrice: double.parse(params['sellPrice']!),
                sellDate: params['sellDate']!,
              );
        },
      ),
    );
  }

  void _confirmDelete(SymbolSummary summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Remove Stock?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove ${summary.symbol} completely? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(portfolioViewModelProvider.notifier)
                  .removeAllBySymbol(summary.symbol, summary.stockIds);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Overview Card ─────────────────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;
  final String? subtitle;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: valueColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stock Card ────────────────────────────────────────────────────────────────
class _StockCard extends StatelessWidget {
  final SymbolSummary summary;
  final NumberFormat format;
  final bool privacyMode;       // ← controlled by flip gesture
  final VoidCallback onSell;
  final VoidCallback onDelete;

  const _StockCard({
    required this.summary,
    required this.format,
    required this.privacyMode,
    required this.onSell,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = summary.isProfit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Symbol + badges + buttons — always visible ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          summary.symbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isProfit
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isProfit ? 'PROFIT' : 'LOSS',
                            style: TextStyle(
                              color: isProfit ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (summary.soldUnits > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PARTIAL SELL',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.name,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (summary.remainingUnits > 0)
                    IconButton(
                      onPressed: onSell,
                      icon: const Icon(Icons.attach_money, color: Colors.green),
                    ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Unit badges — always visible ────────────────────────────────────
          Row(
            children: [
              _buildUnitBadge(
                  'Total', summary.totalUnits.toString(), Colors.grey),
              const SizedBox(width: 8),
              _buildUnitBadge(
                  'Remaining', summary.remainingUnits.toString(), Colors.green),
              if (summary.soldUnits > 0) ...[
                const SizedBox(width: 8),
                _buildUnitBadge(
                    'Sold', summary.soldUnits.toString(), Colors.orange),
              ],
            ],
          ),

          // ── NPR values — blurred when face-down ────────────────────────────
          if (summary.remainingUnits > 0) ...[
            const SizedBox(height: 16),
            privacyMode
                ? _buildBlurredValues(isProfit)
                : _buildValues(isProfit),
          ],
        ],
      ),
    );
  }

  // Your original values layout — completely unchanged
  Widget _buildValues(bool isProfit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceBox(
                'Market LTP',
                format.format(summary.currentLTP),
                isProfit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceBox(
                'Your WACC',
                format.format(summary.wacc),
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isProfit
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isProfit
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unrealized P/L',
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${isProfit ? '+' : ''}${format.format(summary.unrealizedPL)} (${summary.unrealizedPLPercent.toStringAsFixed(2)}%)',
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Blurred placeholder — same height as values so card doesn't jump
  Widget _buildBlurredValues(bool isProfit) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // Invisible copy keeps card height identical to normal view
          Opacity(opacity: 0, child: _buildValues(isProfit)),
          // Blur on top
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          color: Colors.grey[500], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Hidden',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}