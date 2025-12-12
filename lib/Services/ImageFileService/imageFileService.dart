import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<File> loadAssetAsFile(String assetPath) async {
  // Load asset as ByteData
  ByteData byteData = await rootBundle.load(assetPath);

  // Create a temporary directory to store the file
  final tempDir = await getTemporaryDirectory();

  // Create a file path in the temporary directory
  final tempFile = File('${tempDir.path}/temp_asset_file.png'); // Change the extension based on the file type

  // Write the byte data into the file
  return await tempFile.writeAsBytes(byteData.buffer.asUint8List());
}
