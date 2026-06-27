import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

/// StateNotifier managing History state and instantly syncing with Hive storage (Phase 5).
class HistoryController extends StateNotifier<List<HistoryItem>> {
  final HistoryService _service;

  HistoryController(this._service) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final items = await _service.getHistory();
    state = items;
  }

  Future<void> addCalculation({
    required double pricePerKg,
    required double activeWeight,
    required double calculatedPrice,
    required bool isManualMode,
  }) async {
    await _service.addCalculation(
      pricePerKg: pricePerKg,
      activeWeight: activeWeight,
      calculatedPrice: calculatedPrice,
      isManualMode: isManualMode,
    );
    await loadHistory();
  }

  Future<void> deleteHistoryItem(String id) async {
    await _service.deleteHistoryItem(id);
    await loadHistory();
  }

  Future<void> restoreHistoryItem(HistoryItem item) async {
    await _service.restoreHistoryItem(item);
    await loadHistory();
  }

  Future<void> clearAllHistory() async {
    await _service.clearAllHistory();
    await loadHistory();
  }
}

final historyProvider = StateNotifierProvider<HistoryController, List<HistoryItem>>((ref) {
  final service = ref.watch(historyServiceProvider);
  return HistoryController(service);
});
