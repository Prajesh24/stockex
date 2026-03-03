// lib/features/portfolio/data/services/nepse_fee_service.dart

/// NEPSE Fee & WACC Calculator
/// Rules:
/// - Secondary Market: full broker commission + NEPSE + SEBON + DP
/// - IPO / FPO:        no broker commission, only SEBON + DP
/// - Right Share:      no broker commission, only SEBON + DP
/// - Bonus Share:      zero cost (WACC = 0, but we use prev WACC for display)

class NepseFeeResult {
  final double brokerCommission;
  final double nepseCommission;
  final double sebonFee;
  final double dpCharge;
  final double totalFees;
  final double totalCost;      // investment + fees
  final double costPerShare;   // WACC = totalCost / units
  final double brokerRate;     // broker % used

  const NepseFeeResult({
    required this.brokerCommission,
    required this.nepseCommission,
    required this.sebonFee,
    required this.dpCharge,
    required this.totalFees,
    required this.totalCost,
    required this.costPerShare,
    required this.brokerRate,
  });
}

class NepseFeeService {
  NepseFeeService._(); // prevent instantiation

  // ─── Broker commission slab rates (on transaction amount) ───────────────
  static double _brokerRate(double amount) {
    if (amount <= 50000) return 0.0040;
    if (amount <= 500000) return 0.0037;
    if (amount <= 2000000) return 0.0034;
    if (amount <= 10000000) return 0.0030;
    return 0.0027;
  }

  // ─── NEPSE commission = 20% of broker commission ────────────────────────
  static double _nepseCommission(double brokerCommission) =>
      brokerCommission * 0.20;

  // ─── SEBON fee = 0.015% of transaction amount ───────────────────────────
  static double _sebonFee(double amount) => amount * 0.00015;

  // ─── DP charge = fixed NPR 25 per transaction ───────────────────────────
  static const double _dpCharge = 25.0;

  /// Calculate buy cost & WACC based on transaction type
  static NepseFeeResult calculateWACC({
    required int units,
    required double buyPrice,
    required String transactionType,
  }) {
    switch (transactionType.toLowerCase()) {
      case 'secondary':
        return _secondary(units, buyPrice);
      case 'ipo':
      case 'fpo':
        return _ipoFpo(units, buyPrice);
      case 'right':
        return _rightShare(units, buyPrice);
      case 'bonus':
        return _bonusShare(units);
      default:
        return _secondary(units, buyPrice);
    }
  }

  /// Secondary Market — full fees
  static NepseFeeResult _secondary(int units, double buyPrice) {
    final amount = units * buyPrice;
    final rate = _brokerRate(amount);
    final broker = amount * rate;
    final nepse = _nepseCommission(broker);
    final sebon = _sebonFee(amount);
    const dp = _dpCharge;
    final totalFees = broker + nepse + sebon + dp;
    final totalCost = amount + totalFees;

    return NepseFeeResult(
      brokerCommission: broker,
      nepseCommission: nepse,
      sebonFee: sebon,
      dpCharge: dp,
      totalFees: totalFees,
      totalCost: totalCost,
      costPerShare: totalCost / units,
      brokerRate: rate,
    );
  }

  /// IPO / FPO — no broker commission, only SEBON + DP
  static NepseFeeResult _ipoFpo(int units, double buyPrice) {
    final amount = units * buyPrice;
    final sebon = _sebonFee(amount);
    const dp = _dpCharge;
    final totalFees = sebon + dp;
    final totalCost = amount + totalFees;

    return NepseFeeResult(
      brokerCommission: 0,
      nepseCommission: 0,
      sebonFee: sebon,
      dpCharge: dp,
      totalFees: totalFees,
      totalCost: totalCost,
      costPerShare: totalCost / units,
      brokerRate: 0,
    );
  }

  /// Right Share — no broker commission, only SEBON + DP
  static NepseFeeResult _rightShare(int units, double buyPrice) {
    return _ipoFpo(units, buyPrice); // same fee structure as IPO
  }

  /// Bonus Share — zero cost
  /// WACC is not meaningful here (free shares), return 0
  static NepseFeeResult _bonusShare(int units) {
    return NepseFeeResult(
      brokerCommission: 0,
      nepseCommission: 0,
      sebonFee: 0,
      dpCharge: 0,
      totalFees: 0,
      totalCost: 0,
      costPerShare: 0,
      brokerRate: 0,
    );
  }

  /// Sell cost calculation (always secondary market rules)
  static NepseFeeResult calculateSellCost({
    required int units,
    required double sellPrice,
  }) {
    final amount = units * sellPrice;
    final rate = _brokerRate(amount);
    final broker = amount * rate;
    final nepse = _nepseCommission(broker);
    final sebon = _sebonFee(amount);
    const dp = _dpCharge;
    final totalFees = broker + nepse + sebon + dp;

    return NepseFeeResult(
      brokerCommission: broker,
      nepseCommission: nepse,
      sebonFee: sebon,
      dpCharge: dp,
      totalFees: totalFees,
      totalCost: amount - totalFees, // net proceeds after fees
      costPerShare: sellPrice,
      brokerRate: rate,
    );
  }

  /// Human-readable label for transaction type
  static String transactionLabel(String type) {
    switch (type.toLowerCase()) {
      case 'secondary': return 'Secondary Market';
      case 'ipo': return 'IPO';
      case 'fpo': return 'FPO';
      case 'right': return 'Right Share';
      case 'bonus': return 'Bonus Share';
      default: return type;
    }
  }
}