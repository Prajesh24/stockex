import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/services/sensor/shake_detector.dart';

import '../../../watchlist/presentation/state/watchlist_state.dart';

import '../../../watchlist/presentation/viewmodel/watchlist_viewmodel.dart';
// import '../../../../domain/watchlist/entities/watchlist_entity.dart';

import '../../domain/entities/watchlist_entity.dart';
// import '../../../../data/nepse/models/stock_model.dart';
import '../../../../data/nepse/model/stock_model.dart';

class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage> {
  final ShakeDetector _shakeDetector = ShakeDetector();
  @override
  void initState() {
    super.initState();
    _shakeDetector.start(_onShake);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(watchlistViewModelProvider.notifier).loadWatchlist();
    });
  }

  void _onShake() {
    ref.read(watchlistViewModelProvider.notifier).loadWatchlist();

    if (!mounted) return; // ← add this line
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Refreshing prices...'),
          ],
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1B5E20),
      ),
    );
  }

  @override
  void dispose() {
    _shakeDetector.dispose();
    super.dispose();
  }

  Color _getBgColor(double pointChange) {
    if (pointChange > 0) return const Color(0xFFD1FAE5);
    if (pointChange < 0) return const Color(0xFFFEE2E2);
    return const Color(0xFFDBEAFE);
  }

  Color _getBorderColor(double pointChange) {
    if (pointChange > 0) return const Color(0xFFA7F3D0);
    if (pointChange < 0) return const Color(0xFFFECACA);
    return const Color(0xFFBFDBFE);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(watchlistViewModelProvider);
    final notifier = ref.read(watchlistViewModelProvider.notifier);

    // Show error

    ref.listen(watchlistViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: notifier.clearError,
            ),
          ),
        );
        notifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(state, notifier)),
    );
  }

  Widget _buildBody(WatchlistState state, WatchlistViewModel notifier) {
    if (state.status == WatchlistStatus.loading && state.watchlist.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: notifier.loadWatchlist,
      color: Colors.white,
      backgroundColor: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Watchlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search NEPSE stocks and add to watchlist',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Search Box
            _buildSearchBox(state, notifier),
            const SizedBox(height: 32),

            // Watchlist
            _buildWatchlist(state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(WatchlistState state, WatchlistViewModel notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search stock symbol or name (e.g. NABIL, NTC)',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) => notifier.searchStocks(value),
                ),
              ),
              if (state.searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () => notifier.clearSearch(),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
            ],
          ),

          if (state.searchResults.isNotEmpty) ...[
            const Divider(height: 24),
            Column(
              children: state.searchResults.map((stock) {
                return _buildSearchResultItem(stock, notifier);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(StockModel stock, WatchlistViewModel notifier) {
    final isPositive = stock.percentChange >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '${stock.ltp} (${stock.percentChange}%)',
                style: TextStyle(
                  color: isPositive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => notifier.addToWatchlist(stock),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlist(WatchlistState state, WatchlistViewModel notifier) {
    if (state.watchlist.isEmpty && state.status != WatchlistStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No stocks in watchlist yet.\nSearch and add stocks to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.watchlist.length,
      itemBuilder: (context, index) {
        final stock = state.watchlist[index];
        return _buildWatchlistCard(stock, notifier);
      },
    );
  }

  Widget _buildWatchlistCard(
    WatchlistEntity stock,
    WatchlistViewModel notifier,
  ) {
    final bgColor = _getBgColor(stock.pointChange);
    final borderColor = _getBorderColor(stock.pointChange);
    final isPositive = stock.pointChange >= 0;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.name,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _showDeleteConfirmation(context, stock.symbol, notifier),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDataItem('LTP', stock.ltp.toStringAsFixed(2)),
                _buildDataItem('High', stock.high.toStringAsFixed(2)),
                _buildDataItem('Low', stock.low.toStringAsFixed(2)),
                _buildDataItem(
                  'Ch',
                  stock.pointChange.toStringAsFixed(2),
                  valueColor: isPositive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
                _buildDataItem(
                  'Ch%',
                  '${stock.percentChange.toStringAsFixed(2)}%',
                  valueColor: isPositive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
                _buildDataItem(
                  'Prev Close',
                  stock.previousClose.toStringAsFixed(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value, {Color? valueColor}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String symbol,
    WatchlistViewModel notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Remove Stock',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove $symbol from your watchlist?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              notifier.removeFromWatchlist(symbol);
              Navigator.pop(context);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}
