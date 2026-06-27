import 'package:hive_flutter/hive_flutter.dart';
import '../models/price_book_item.dart';
import '../models/price_history_entry.dart';

/// Service handling local Hive storage for Price Book products (Phase 6).
class PriceBookService {
  static const String _boxName = 'priceBookBox';

  Future<Box<PriceBookItem>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<PriceBookItem>(_boxName);
    }
    return await Hive.openBox<PriceBookItem>(_boxName);
  }

  Future<List<PriceBookItem>> getItems() async {
    final box = await _getBox();
    final items = box.values.toList();
    // Display newest or most recently updated items first
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<void> addOrUpdateItem({
    required String id,
    required String name,
    required double price,
    required String unit,
  }) async {
    final box = await _getBox();
    final now = DateTime.now();
    final existing = box.get(id);

    if (existing != null) {
      existing.name = name;
      existing.price = price;
      existing.unit = unit;
      existing.updatedAt = now;
      existing.priceHistory.add(
        PriceHistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          unitPrice: price,
          timestamp: now,
        ),
      );
      await existing.save();
    } else {
      final newItem = PriceBookItem(
        id: id,
        name: name,
        category: unit, // category acts as the unit string
        currentUnitPrice: price,
        baseWeightInGrams: 1000.0,
        priceHistory: [
          PriceHistoryEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            unitPrice: price,
            timestamp: now,
          ),
        ],
        updatedAt: now,
      );
      await box.put(id, newItem);
    }
  }

  Future<void> deleteItem(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> restoreItem(PriceBookItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }
}
