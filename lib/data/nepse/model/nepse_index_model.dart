class NepseIndexModel {
  final String symbol;
  final double value;
  final double pointChange;
  final double percentChange;
  final bool isPositive;

  NepseIndexModel({
    required this.symbol,
    required this.value,
    required this.pointChange,
    required this.percentChange,
    required this.isPositive,
  });
}