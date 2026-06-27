import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// IO implementation for saving and reading JSON backup files on mobile/desktop.
Future<void> saveFileImpl(String filename, String content) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
  } catch (_) {}
}

Future<String?> pickFileImpl() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/gramwise_backup.json');
    if (await file.exists()) {
      return await file.readAsString();
    }
  } catch (_) {}
  return null;
}
