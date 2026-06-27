import 'file_helper_io.dart' if (dart.library.html) 'file_helper_web.dart';

/// Abstract cross-platform file helper for exporting and importing JSON files.
abstract class FileHelper {
  static Future<void> saveJsonFile(String filename, String content) async {
    await saveFileImpl(filename, content);
  }

  static Future<String?> pickAndReadJsonFile() async {
    return await pickFileImpl();
  }
}
