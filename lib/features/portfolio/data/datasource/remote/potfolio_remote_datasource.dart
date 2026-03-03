// lib/features/portfolio/data/datasource/remote/portfolio_remote_datasource.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/api/app_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../models/portfolio_api_model.dart';

final portfolioRemoteDatasourceProvider =
    Provider<IPortfolioRemoteDatasource>((ref) {
  return PortfolioRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

abstract class IPortfolioRemoteDatasource {
  Future<List<PortfolioApiModel>> getPortfolio();
  Future<PortfolioApiModel> addStock({
    required String symbol,
    required String name,
    String? sector,
    required String transactionType,
    required int units,
    required double buyPrice,
    required String buyDate,
    double? ltp,
  });
  Future<void> removeStock(String id);
  Future<SellResultModel> sellStock({
    required String id,
    required int units,
    required double sellPrice,
    required String sellDate,
  });
  Future<PortfolioOverviewModel> getOverview();
  Future<List<Map<String, dynamic>>> getSellHistory();
}

class PortfolioRemoteDatasource implements IPortfolioRemoteDatasource {
  final ApiClient _apiClient;

  PortfolioRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// GET /api/portfolio
  @override
  Future<List<PortfolioApiModel>> getPortfolio() async {
    final response = await _apiClient.get(ApiEndpoints.portfolio);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] as List? ?? [];
      return data
          .map((json) => PortfolioApiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load portfolio');
  }

  /// POST /api/portfolio
  @override
  Future<PortfolioApiModel> addStock({
    required String symbol,
    required String name,
    String? sector,
    required String transactionType,
    required int units,
    required double buyPrice,
    required String buyDate,
    double? ltp, // ✅ pass market LTP to backend
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.portfolio,
      data: {
        'symbol': symbol,
        'name': name,
        if (sector != null) 'sector': sector,
        'transactionType': transactionType,
        'units': units,
        'buyPrice': buyPrice,
        'buyDate': buyDate,
        // ✅ Send ltp so backend stores market price, not buyPrice
        if (ltp != null) 'ltp': ltp,
      },
    );

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PortfolioApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to add stock');
  }

  /// DELETE /api/portfolio/:id
  @override
  Future<void> removeStock(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.removeStock(id));
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to remove stock');
    }
  }

  /// POST /api/portfolio/:id/sell
  @override
  Future<SellResultModel> sellStock({
    required String id,
    required int units,
    required double sellPrice,
    required String sellDate,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.sellStock(id),
      data: {
        'units': units,
        'sellPrice': sellPrice,
        'sellDate': sellDate,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return SellResultModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to sell stock');
  }

  /// GET /api/portfolio/overview
  @override
  Future<PortfolioOverviewModel> getOverview() async {
    final response = await _apiClient.get(ApiEndpoints.portfolioOverview);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PortfolioOverviewModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to load overview');
  }

  /// GET /api/portfolio/sell-history
  @override
  Future<List<Map<String, dynamic>>> getSellHistory() async {
    final response = await _apiClient.get(ApiEndpoints.sellHistory);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] as List? ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(response.data['message'] ?? 'Failed to load sell history');
  }
}