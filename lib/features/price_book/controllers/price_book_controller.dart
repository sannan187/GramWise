import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_book_item.dart';
import '../services/price_book_service.dart';

final priceBookServiceProvider = Provider<PriceBookService>((ref) {
  return PriceBookService();
});

final priceBookSearchProvider = StateProvider<String>((ref) => '');

/// StateNotifier managing Price Book state and instantly syncing with Hive storage (Phase 6).
class PriceBookController extends StateNotifier<List<PriceBookItem>> {
  final PriceBookService _service;

  PriceBookController(this._service) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await _service.getItems();
    state = items;
  }

  Future<void> addOrUpdateItem({
    required String id,
    required String name,
    required double price,
    required String unit,
  }) async {
    await _service.addOrUpdateItem(
      id: id,
      name: name,
      price: price,
      unit: unit,
    );
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _service.deleteItem(id);
    await loadItems();
  }

  Future<void> restoreItem(PriceBookItem item) async {
    await _service.restoreItem(item);
    await loadItems();
  }
}

final priceBookProvider = StateNotifierProvider<PriceBookController, List<PriceBookItem>>((ref) {
  final service = ref.watch(priceBookServiceProvider);
  return PriceBookController(service);
});

final filteredPriceBookProvider = Provider<List<PriceBookItem>>((ref) {
  final items = ref.watch(priceBookProvider);
  final query = ref.watch(priceBookSearchProvider).trim().toLowerCase();

  if (query.isEmpty) {
    return items;
  }

  return items.where((item) => item.name.toLowerCase().contains(query)).toList();
});
