import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'features/calculator/models/calculation.dart';
import 'features/history/models/history_item.dart';
import 'features/price_book/models/price_history_entry.dart';
import 'features/price_book/models/price_book_item.dart';
import 'features/settings/models/settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline storage directory via path_provider (Desktop/Mobile only; Web uses IndexedDB natively)
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // Register manual Hive TypeAdapters (zero code generation overhead)
  Hive.registerAdapter(CalculationAdapter());
  Hive.registerAdapter(HistoryItemAdapter());
  Hive.registerAdapter(PriceHistoryEntryAdapter());
  Hive.registerAdapter(PriceBookItemAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // Run the app wrapped in Riverpod's ProviderScope
  runApp(
    const ProviderScope(
      child: GramWiseApp(),
    ),
  );
}
