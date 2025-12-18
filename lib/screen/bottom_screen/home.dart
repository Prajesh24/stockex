import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  NEPSE INDEX CARD
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: const Color(0xff1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'NEPSE Index',
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '2132.45',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              '+18.34',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '+0.86%',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ADVANCE / DECLINE CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: const Color(0xff1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _marketStat('Advance', '145', Colors.green),
                        _marketStat('Decline', '82', Colors.red),
                        _marketStat('Unchanged', '12', Colors.grey),
                        _marketStat('+Circuit', '9', Colors.greenAccent),
                        _marketStat('-Circuit', '4', Colors.redAccent),
                      ],
                    ),
                  ),
                ),
              ),

              // MARKET SUMMARY
              _sectionTitle('Market Summary'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _summaryCard('Turnover', 'Rs. 4.2B'),
                    _summaryCard('Traded Shares', '8.5M'),
                    _summaryCard('Transactions', '62,134'),
                    _summaryCard('Traded Scripts', '215'),
                  ],
                ),
              ),

              //  TOP MOVERS
              _sectionTitle('Top Movers'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: const Color(0xff1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    height: 280,
                    child: PageView(
                      children: [
                        _moverPage('Top Gainers', true),
                        _moverPage('Top Losers', false),
                      ],
                    ),
                  ),
                ),
              ),

              // TOP DEMAND
              _sectionTitle('Top Demand'),
              _quantityList(true),

              // TOP SUPPLY
              _sectionTitle('Top Supply'),
              _quantityList(false),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // HELPERS

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _marketStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value) {
    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moverPage(String title, bool isGain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              color: isGain ? Colors.green : Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                title: const Text(
                  'ABC Limited',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Rs. 485',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  isGain ? '+7.21%' : '-5.14%',
                  style: TextStyle(
                    color: isGain ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quantityList(bool isDemand) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: const Color(0xff1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: List.generate(5, (index) {
            return ListTile(
              title: const Text(
                'XYZ Limited',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                isDemand ? '125,000' : '98,500',
                style: TextStyle(
                  color: isDemand ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
