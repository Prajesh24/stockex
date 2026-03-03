import '../model/nepse_index_model.dart';
import '../model/stock_model.dart';
import '../model/stock_summary_model.dart';

// 📊 Market Summary
final _dummyMarketSummary = MarketSummaryModel(
  date: "2026-02-15",
  time: "14:45 NPT",
  status: "Open",
  nepse: NepseIndexModel(
    symbol: "NEPSE",
    value: 2187.64,
    pointChange: -18.92,
    percentChange: -0.86,
    isPositive: false,
  ),
  turnoverInArba: 3.87,
  totalTrades: 48712,
  totalVolume: 12456789,
  totalTurnover: 3870000000,
  advance: 68,
  decline: 142,
  unchanged: 31,
);

// 📈 Sub Indices
final _dummySubIndices = <NepseIndexModel>[
  NepseIndexModel(symbol: "Banking", value: 1423.45, pointChange: -9.12, percentChange: -0.64, isPositive: false),
  NepseIndexModel(symbol: "Development Bank", value: 3987.21, pointChange: 45.67, percentChange: 1.16, isPositive: true),
  NepseIndexModel(symbol: "Finance", value: 1678.90, pointChange: -21.34, percentChange: -1.26, isPositive: false),
  NepseIndexModel(symbol: "Hotels & Tourism", value: 5123.78, pointChange: 78.92, percentChange: 1.56, isPositive: true),
  NepseIndexModel(symbol: "Hydropower", value: 2890.34, pointChange: -12.45, percentChange: -0.43, isPositive: false),
  NepseIndexModel(symbol: "Insurance", value: 10987.43, pointChange: 132.43, percentChange: 1.22, isPositive: true),
  NepseIndexModel(symbol: "Microfinance", value: 3987.65, pointChange: -34.12, percentChange: -0.85, isPositive: false),
  NepseIndexModel(symbol: "Manufacturing", value: 6234.87, pointChange: 88.21, percentChange: 1.43, isPositive: true),
];

// 📉 Stocks (FULL DUMMY DATA)
final _dummyStocks = <StockModel>[
  StockModel(
    symbol: "NABIL",
    name: "Nabil Bank Ltd.",
    sector: "Commercial Banks",
    ltp: 512.40,
    previousClose: 515.80,
    open: 516.00,
    high: 520.00,
    low: 510.00,
    pointChange: -3.40,
    percentChange: -0.66,
    volume: 245678,
    turnover: 125890000,
    trades: 1345,
  ),
  StockModel(
    symbol: "GBIME",
    name: "Global IME Bank Ltd.",
    sector: "Commercial Banks",
    ltp: 198.70,
    previousClose: 196.20,
    open: 197.00,
    high: 200.50,
    low: 196.00,
    pointChange: 2.50,
    percentChange: 1.27,
    volume: 189432,
    turnover: 37650000,
    trades: 987,
  ),
  StockModel(
    symbol: "NICA",
    name: "NIC Asia Bank Ltd.",
    sector: "Commercial Banks",
    ltp: 305.20,
    previousClose: 310.00,
    open: 308.00,
    high: 312.00,
    low: 302.00,
    pointChange: -4.80,
    percentChange: -1.55,
    volume: 312450,
    turnover: 95230000,
    trades: 1450,
  ),
  StockModel(
    symbol: "EBL",
    name: "Everest Bank Ltd.",
    sector: "Commercial Banks",
    ltp: 615.00,
    previousClose: 600.50,
    open: 602.00,
    high: 620.00,
    low: 598.00,
    pointChange: 14.50,
    percentChange: 2.41,
    volume: 98765,
    turnover: 60230000,
    trades: 732,
  ),
  StockModel(
    symbol: "UPPER",
    name: "Upper Tamakoshi Hydropower Ltd.",
    sector: "Hydropower",
    ltp: 225.30,
    previousClose: 220.40,
    open: 221.00,
    high: 228.00,
    low: 219.50,
    pointChange: 4.90,
    percentChange: 2.22,
    volume: 432190,
    turnover: 97234000,
    trades: 1650,
  ),
  StockModel(
    symbol: "CHCL",
    name: "Chilime Hydropower Company Ltd.",
    sector: "Hydropower",
    ltp: 495.00,
    previousClose: 505.00,
    open: 503.00,
    high: 508.00,
    low: 492.00,
    pointChange: -10.00,
    percentChange: -1.98,
    volume: 154321,
    turnover: 76450000,
    trades: 1023,
  ),
  StockModel(
    symbol: "HDL",
    name: "Himalayan Distillery Ltd.",
    sector: "Manufacturing",
    ltp: 2105.00,
    previousClose: 2080.00,
    open: 2090.00,
    high: 2120.00,
    low: 2075.00,
    pointChange: 25.00,
    percentChange: 1.20,
    volume: 34210,
    turnover: 72000000,
    trades: 321,
  ),
  StockModel(
    symbol: "NRIC",
    name: "Nepal Reinsurance Company Ltd.",
    sector: "Insurance",
    ltp: 685.00,
    previousClose: 670.00,
    open: 672.00,
    high: 690.00,
    low: 668.00,
    pointChange: 15.00,
    percentChange: 2.24,
    volume: 87654,
    turnover: 60123000,
    trades: 543,
  ),
  StockModel(
    symbol: "NTC",
    name: "Nepal Doorsanchar Company Ltd.",
    sector: "Others",
    ltp: 890.00,
    previousClose: 885.00,
    open: 887.00,
    high: 895.00,
    low: 882.00,
    pointChange: 5.00,
    percentChange: 0.56,
    volume: 54321,
    turnover: 48321000,
    trades: 412,
  ),
  StockModel(
    symbol: "UNL",
    name: "Unilever Nepal Ltd.",
    sector: "Manufacturing",
    ltp: 19200.00,
    previousClose: 19050.00,
    open: 19100.00,
    high: 19350.00,
    low: 19000.00,
    pointChange: 150.00,
    percentChange: 0.79,
    volume: 1245,
    turnover: 23800000,
    trades: 67,
  ),
];

// Top Gainers
final _dummyTopGainers = [..._dummyStocks]
  ..sort((a, b) => b.percentChange.compareTo(a.percentChange));

//  Top Losers
final _dummyTopLosers = [..._dummyStocks]
  ..sort((a, b) => a.percentChange.compareTo(b.percentChange));

// CLASS WRAPPER 
class DummyNepseData {
  static MarketSummaryModel get marketSummary => _dummyMarketSummary;
  static List<NepseIndexModel> get subIndices => _dummySubIndices;
  static List<StockModel> get stocks => _dummyStocks;
  static List<StockModel> get topGainers => _dummyTopGainers;
  static List<StockModel> get topLosers => _dummyTopLosers;
}