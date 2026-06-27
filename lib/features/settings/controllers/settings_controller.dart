import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../calculator/models/calculation.dart';
import '../../history/controllers/history_controller.dart';
import '../../history/models/history_item.dart';
import '../../price_book/controllers/price_book_controller.dart';
import '../../price_book/models/price_book_item.dart';
import '../../price_book/models/price_history_entry.dart';
import '../models/settings_model.dart';
import '../services/file_helper.dart';

/// Notifier managing user settings state, Hive persistence, and Data Management (Export/Import/Clear).
class SettingsController extends StateNotifier<SettingsModel> {
  SettingsController() : super(SettingsModel()) {
    _loadSettings();
  }

  Box<SettingsModel>? _box;

  Future<void> _loadSettings() async {
    _box = await Hive.openBox<SettingsModel>('settingsBox');
    final savedSettings = _box!.get('userSettings');
    if (savedSettings != null) {
      state = savedSettings;
    } else {
      final defaultSettings = SettingsModel();
      await _box!.put('userSettings', defaultSettings);
      state = defaultSettings;
    }
  }

  /// Sets the active theme mode ('light', 'dark', or 'system') and saves to Hive.
  Future<void> setThemeMode(String mode) async {
    final newSettings = SettingsModel(
      themeMode: mode,
      defaultCurrencyCode: state.defaultCurrencyCode,
      defaultWeightUnit: state.defaultWeightUnit,
      hapticsEnabled: state.hapticsEnabled,
    );
    if (_box != null) {
      await _box!.put('userSettings', newSettings);
    }
    state = newSettings;
  }

  /// Helper to convert the string state to Flutter's ThemeMode enum.
  ThemeMode get themeMode {
    switch (state.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /* ==========================================================================
     Data Management: Export, Import, and Clear All Data
     ========================================================================== */

  /// Exports all History and Price Book data as a JSON string and downloads it.
  Future<void> exportData() async {
    final historyBox = await Hive.openBox<HistoryItem>('historyBox');
    final priceBookBox = await Hive.openBox<PriceBookItem>('priceBookBox');

    final historyList = historyBox.values.map((item) => {
      'id': item.id,
      'notes': item.notes,
      'recordedAt': item.recordedAt.toIso8601String(),
      'calculation': {
        'id': item.calculation.id,
        'unitPrice': item.calculation.unitPrice,
        'unitWeightInGrams': item.calculation.unitWeightInGrams,
        'targetWeightInGrams': item.calculation.targetWeightInGrams,
        'calculatedPrice': item.calculation.calculatedPrice,
        'timestamp': item.calculation.timestamp.toIso8601String(),
      },
    }).toList();

    final priceBookList = priceBookBox.values.map((item) => {
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'currentUnitPrice': item.currentUnitPrice,
      'baseWeightInGrams': item.baseWeightInGrams,
      'updatedAt': item.updatedAt.toIso8601String(),
      'priceHistory': item.priceHistory.map((entry) => {
        'id': entry.id,
        'unitPrice': entry.unitPrice,
        'timestamp': entry.timestamp.toIso8601String(),
        'note': entry.note,
      }).toList(),
    }).toList();

    final backupData = {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'history': historyList,
      'priceBook': priceBookList,
    };

    final jsonStr = jsonEncode(backupData);
    await FileHelper.saveJsonFile('gramwise_backup.json', jsonStr);
  }

  /// Prompts file picker, validates imported JSON data, saves to Hive, and refreshes UI.
  Future<bool> importData(WidgetRef ref) async {
    try {
      final jsonStr = await FileHelper.pickAndReadJsonFile();
      if (jsonStr == null || jsonStr.isEmpty) return false;

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (!data.containsKey('history') || !data.containsKey('priceBook')) {
        return false;
      }

      final historyList = data['history'] as List;
      final priceBookList = data['priceBook'] as List;

      final historyBox = await Hive.openBox<HistoryItem>('historyBox');
      final priceBookBox = await Hive.openBox<PriceBookItem>('priceBookBox');

      await historyBox.clear();
      await priceBookBox.clear();

      for (final itemMap in historyList) {
        final calcMap = (itemMap['calculation'] as Map?) ?? {};
        final calc = Calculation(
          id: calcMap['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          unitPrice: (calcMap['unitPrice'] as num?)?.toDouble() ?? 0.0,
          unitWeightInGrams: (calcMap['unitWeightInGrams'] as num?)?.toDouble() ?? 1000.0,
          targetWeightInGrams: (calcMap['targetWeightInGrams'] as num?)?.toDouble() ?? 0.0,
          calculatedPrice: (calcMap['calculatedPrice'] as num?)?.toDouble() ?? 0.0,
          timestamp: calcMap['timestamp'] != null ? DateTime.parse(calcMap['timestamp']) : DateTime.now(),
        );

        final item = HistoryItem(
          id: itemMap['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          calculation: calc,
          notes: itemMap['notes'] as String?,
          recordedAt: itemMap['recordedAt'] != null ? DateTime.parse(itemMap['recordedAt']) : DateTime.now(),
        );
        await historyBox.put(item.id, item);
      }

      for (final itemMap in priceBookList) {
        final historyEntriesMap = (itemMap['priceHistory'] as List?) ?? [];
        final priceHistory = historyEntriesMap.map((entryMap) => PriceHistoryEntry(
          id: entryMap['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          unitPrice: (entryMap['unitPrice'] as num?)?.toDouble() ?? 0.0,
          timestamp: entryMap['timestamp'] != null ? DateTime.parse(entryMap['timestamp']) : DateTime.now(),
          note: entryMap['note'] as String?,
        )).toList();

        final item = PriceBookItem(
          id: itemMap['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: itemMap['name'] as String? ?? 'Unnamed',
          category: itemMap['category'] as String? ?? 'kg',
          currentUnitPrice: (itemMap['currentUnitPrice'] as num?)?.toDouble() ?? 0.0,
          baseWeightInGrams: (itemMap['baseWeightInGrams'] as num?)?.toDouble() ?? 1000.0,
          priceHistory: priceHistory,
          updatedAt: itemMap['updatedAt'] != null ? DateTime.parse(itemMap['updatedAt']) : DateTime.now(),
        );
        await priceBookBox.put(item.id, item);
      }

      // Refresh Riverpod providers instantly
      ref.read(historyProvider.notifier).loadHistory();
      ref.read(priceBookProvider.notifier).loadItems();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deletes Calculator History, Price Book, and Price Timeline.
  Future<void> clearAllData(WidgetRef ref) async {
    final historyBox = await Hive.openBox<HistoryItem>('historyBox');
    final priceBookBox = await Hive.openBox<PriceBookItem>('priceBookBox');
    await historyBox.clear();
    await priceBookBox.clear();
    ref.read(historyProvider.notifier).loadHistory();
    ref.read(priceBookProvider.notifier).loadItems();
  }
}

/// Provider for the SettingsController.
final settingsProvider = StateNotifierProvider<SettingsController, SettingsModel>((ref) {
  return SettingsController();
});
