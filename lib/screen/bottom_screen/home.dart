import 'package:flutter/material.dart';
import 'package:stockex/data/nepse/dummy/dummy_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMoverTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use DummyNepseData class getters
    final summary = DummyNepseData.marketSummary;
    final gainers = DummyNepseData.topGainers.take(5).toList();
    final losers = DummyNepseData.topLosers.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50), // Add space for status bar

                // NEPSE Index Card with Glassmorphism
                _buildNepseCard(summary),

                // Market Status Bar
                _buildStatusBar(summary),

                const SizedBox(height: 24),

                // Advance/Decline with Visual Bars
                _buildMarketBreadth(summary),

                const SizedBox(height: 24),

                // Market Summary Grid
                _buildSectionTitle('Market Overview'),
                _buildSummaryGrid(summary),

                const SizedBox(height: 24),

                // Top Movers with Tabs
                _buildSectionTitle('Top Movers'),
                _buildMoversSection(gainers, losers),

                const SizedBox(height: 24),

                // Top Demand/Supply with Progress Bars
                _buildSectionTitle('Market Depth'),
                _buildMarketDepth(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNepseCard(dynamic summary) {
    final isPositive = summary.nepse.isPositive;
    final color = isPositive
        ? const Color(0xFF00D084)
        : const Color(0xFFFF4757);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [const Color(0xFF1A2F1A), const Color(0xFF0A1F0A)]
              : [const Color(0xFF2F1A1A), const Color(0xFF1F0A0A)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'NEPSE INDEX',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        summary.nepse.value.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${isPositive ? '+' : ''}${summary.nepse.percentChange.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat(
                    'Points',
                    '${isPositive ? '+' : ''}${summary.nepse.pointChange.toStringAsFixed(2)}',
                    color,
                  ),
                  const SizedBox(width: 24),
                  _buildMiniStat('Status', summary.status, Colors.white70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(dynamic summary) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusItem(
            'Volume',
            '${(summary.totalVolume / 1000000).toStringAsFixed(2)}M',
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildStatusItem('Turnover', 'Rs. ${summary.turnoverInArba}B'),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildStatusItem('Trades', '${summary.totalTrades}'),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMarketBreadth(dynamic summary) {
    final total = summary.advance + summary.decline + summary.unchanged;
    final advancePct = summary.advance / total;
    final declinePct = summary.decline / total;
    final unchangedPct = summary.unchanged / total;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Breadth',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: (advancePct * 100).toInt(),
                  child: Container(height: 8, color: const Color(0xFF00D084)),
                ),
                Expanded(
                  flex: (unchangedPct * 100).toInt(),
                  child: Container(height: 8, color: const Color(0xFFFFA502)),
                ),
                Expanded(
                  flex: (declinePct * 100).toInt(),
                  child: Container(height: 8, color: const Color(0xFFFF4757)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBreadthStat(
                'Advance',
                summary.advance,
                const Color(0xFF00D084),
              ),
              _buildBreadthStat(
                'Unchanged',
                summary.unchanged,
                const Color(0xFFFFA502),
              ),
              _buildBreadthStat(
                'Decline',
                summary.decline,
                const Color(0xFFFF4757),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadthStat(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(dynamic summary) {
    final items = [
      _GridItem(
        'Turnover',
        'Rs. ${summary.turnoverInArba}B',
        Icons.account_balance_wallet,
      ),
      _GridItem(
        'Traded',
        '${(summary.totalVolume / 1000000).toStringAsFixed(1)}M',
        Icons.show_chart,
      ),
      _GridItem('Transactions', '${summary.totalTrades}', Icons.swap_horiz),
      _GridItem('Scrips', '241', Icons.list),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF15151F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1E1E2C), const Color(0xFF15151F)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(item.icon, color: Colors.white38, size: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoversSection(List gainers, List losers) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMoverTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedMoverTab == 0
                            ? const Color(0xFF00D084).withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: _selectedMoverTab == 0
                            ? Border.all(
                                color: const Color(0xFF00D084).withOpacity(0.3),
                              )
                            : null,
                      ),
                      child: Text(
                        'Top Gainers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedMoverTab == 0
                              ? const Color(0xFF00D084)
                              : Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMoverTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedMoverTab == 1
                            ? const Color(0xFFFF4757).withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: _selectedMoverTab == 1
                            ? Border.all(
                                color: const Color(0xFFFF4757).withOpacity(0.3),
                              )
                            : null,
                      ),
                      child: Text(
                        'Top Losers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedMoverTab == 1
                              ? const Color(0xFFFF4757)
                              : Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedMoverTab == 0
                ? _buildStockList(gainers, true)
                : _buildStockList(losers, false),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(List stocks, bool isGainer) {
    return Column(
      key: ValueKey(isGainer ? 'gainers' : 'losers'),
      children: stocks.asMap().entries.map((entry) {
        final index = entry.key;
        final stock = entry.value;
        final color = isGainer
            ? const Color(0xFF00D084)
            : const Color(0xFFFF4757);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: index != stocks.length - 1
                ? Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      stock.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${stock.ltp.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${isGainer ? '+' : ''}${stock.percentChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarketDepth() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ✅ FIXED: Use DummyNepseData.stocks
          _buildDepthCard('Top Demand', DummyNepseData.stocks.take(5).toList(), true),
          const SizedBox(height: 12),
          _buildDepthCard(
            'Top Supply',
            DummyNepseData.stocks.reversed.take(5).toList(),
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildDepthCard(String title, List stocks, bool isDemand) {
    final color = isDemand ? const Color(0xFF00D084) : const Color(0xFFFF4757);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                isDemand ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stocks.asMap().entries.map((entry) {
            final stock = entry.value;
            final maxVolume = stocks
                .map((s) => s.volume)
                .reduce((a, b) => a > b ? a : b);
            final volumePct = stock.volume / maxVolume;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      stock.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0F),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: volumePct,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(stock.volume / 1000).toStringAsFixed(1)}K',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _GridItem {
  final String label;
  final String value;
  final IconData icon;

  _GridItem(this.label, this.value, this.icon);
}