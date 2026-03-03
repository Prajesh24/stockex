// lib/features/portfolio/presentation/widgets/sector_pie_chart.dart

import 'package:flutter/material.dart';
import 'package:stockex/features/portfolio/domain/entities/portfolio_entity.dart';

class SectorPieChart extends StatefulWidget {
  final List<SymbolSummary> summaries;

  const SectorPieChart({super.key, required this.summaries});

  @override
  State<SectorPieChart> createState() => _SectorPieChartState();
}

class _SectorPieChartState extends State<SectorPieChart> {
  String? _hoveredSector;

  final Map<String, Color> sectorColors = {
    'Commercial Banks': const Color(0xFF3B82F6),
    'Development Bank': const Color(0xFF8B5CF6),
    'Finance': const Color(0xFFF59E0B),
    'Hotels & Tourism': const Color(0xFFEC4899),
    'HydroPower': const Color(0xFF10B981),
    'Life Insurance': const Color(0xFFEF4444),
    'Microfinance': const Color(0xFF06B6D4),
    'Non Life Insurance': const Color(0xFFF97316),
    'Others': const Color(0xFF6B7280),
    'Manufacturing & Processing': const Color(0xFF84CC16),
  };

  Color getSectorColor(String sector) =>
      sectorColors[sector] ?? const Color(0xFF6366F1);

  String formatCurrency(double value) {
    if (value >= 10000000)
      return 'NPR ${(value / 10000000).toStringAsFixed(2)}Cr';
    if (value >= 100000) return 'NPR ${(value / 100000).toStringAsFixed(2)}L';
    if (value >= 1000) return 'NPR ${(value / 1000).toStringAsFixed(1)}K';
    return 'NPR ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final sectorData = <String, double>{};
    for (final summary in widget.summaries) {
      final sector = summary.individualStocks.isNotEmpty
          ? (summary.individualStocks.first.sector ?? 'Others')
          : 'Others';
      sectorData[sector] = (sectorData[sector] ?? 0) + summary.currentValue;
    }

    if (sectorData.isEmpty) return const SizedBox.shrink();

    final totalValue = sectorData.values.fold<double>(0, (a, b) => a + b);
    final sortedSectors = sectorData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'Sector Allocation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Pie Chart (centered) ──────────────────────────────────
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _PieChartPainter(
                      data: sortedSectors,
                      total: totalValue,
                      colors: sectorColors,
                      hoveredSector: _hoveredSector,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        formatCurrency(totalValue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Legend (vertical list — no Row overflow) ──────────────
          Column(
            children: sortedSectors.map((entry) {
              final percentage = (entry.value / totalValue) * 100;
              final isHovered = _hoveredSector == entry.key;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredSector = entry.key),
                onExit: (_) => setState(() => _hoveredSector = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // ── Color dot ───────────────────────────────
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: getSectorColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ── Sector name + % ─────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Value (right-aligned, no overflow) ───────
                      Text(
                        formatCurrency(entry.value),
                        style: TextStyle(
                          color: getSectorColor(entry.key),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double total;
  final Map<String, Color> colors;
  final String? hoveredSector;

  _PieChartPainter({
    required this.data,
    required this.total,
    required this.colors,
    this.hoveredSector,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var startAngle = -90.0;

    for (final entry in data) {
      final sweepAngle = (entry.value / total) * 360;
      final isHovered = hoveredSector == entry.key;

      final paint = Paint()
        ..color = colors[entry.key] ?? Colors.grey
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: isHovered ? radius + 4 : radius,
        ),
        _toRadians(startAngle),
        _toRadians(sweepAngle),
        true,
        paint,
      );

      // Separator
      final separatorPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _toRadians(startAngle),
        _toRadians(sweepAngle),
        true,
        separatorPaint,
      );

      startAngle += sweepAngle;
    }

    // Donut hole
    canvas.drawCircle(
      center,
      radius * 0.5,
      Paint()..color = Colors.grey.shade900,
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.hoveredSector != hoveredSector ||
      oldDelegate.data != data ||
      oldDelegate.total != total;

  double _toRadians(double degrees) => degrees * 3.14159265359 / 180;
}
