import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_item.dart';
import '../../calculator/models/calculation.dart';

/// Service handling local Hive storage for calculation history (Phase 5).
class HistoryService {
  static const String _boxName = 'historyBox';

  Future<Box<HistoryItem>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<HistoryItem>(_boxName);
    }
    return await Hive.openBox<HistoryItem>(_boxName);
  }

  Future<List<HistoryItem>> getHistory() async {
    final box = await _getBox();
    final items = box.values.toList();
    // Display newest calculations first
    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items;
  }

  Future<void> addCalculation({
    required double pricePerKg,
    required double activeWeight,
    required double calculatedPrice,
    required bool isManualMode,
  }) async {
    final box = await _getBox();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final calculation = Calculation(
      id: id,
      unitPrice: pricePerKg,
      unitWeightInGrams: 1000.0,
      targetWeightInGrams: activeWeight,
      calculatedPrice: calculatedPrice,
      timestamp: now,
    );

    final historyItem = HistoryItem(
      id: id,
      calculation: calculation,
      notes: isManualMode ? 'Manual' : 'Picker',
      recordedAt: now,
    );

    await box.put(id, historyItem);
  }

  Future<void> deleteHistoryItem(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> restoreHistoryItem(HistoryItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  Future<void> clearAllHistory() async {
    final box = await _getBox();
    await box.clear();
  }
}
