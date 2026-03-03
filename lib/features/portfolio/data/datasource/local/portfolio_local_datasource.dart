// lib/features/portfolio/data/datasource/local/portfolio_local_datasource.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final portfolioLocalDatasourceProvider = Provider<IPortfolioLocalDatasource>((ref) {
  return PortfolioLocalDatasource();
});

abstract class IPortfolioLocalDatasource {
  // Placeholder for future local caching
  Future<void> cachePortfolio(List<Map<String, dynamic>> data);
  Future<List<Map<String, dynamic>>?> getCachedPortfolio();
  Future<void> clearCache();
}

class PortfolioLocalDatasource implements IPortfolioLocalDatasource {
  @override
  Future<void> cachePortfolio(List<Map<String, dynamic>> data) async {
    // Implement with SharedPreferences or Hive if needed
    // Currently not used as per your requirement
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedPortfolio() async {
    return null;
  }

  @override
  Future<void> clearCache() async {
    // No-op
  }
}