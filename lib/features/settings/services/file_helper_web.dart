import 'dart:html' as html;
import 'dart:convert';

/// Web implementation for downloading and picking JSON files via dart:html.
Future<void> saveFileImpl(String filename, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<String?> pickFileImpl() async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.json,application/json';
  uploadInput.click();

  await uploadInput.onChange.first;
  if (uploadInput.files == null || uploadInput.files!.isEmpty) {
    return null;
  }

  final file = uploadInput.files!.first;
  final reader = html.FileReader();
  reader.readAsText(file);
  await reader.onLoad.first;
  return reader.result as String?;
}
