import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  static Future<String> getAppStoragePath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      // Use external storage for user visibility
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    // Fallback if null
    directory ??= await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<Directory> getImagesDirectory() async {
    final basePath = await getAppStoragePath();
    final dir = Directory(p.join(basePath, 'FileSnap', 'Images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getPdfsDirectory() async {
    final basePath = await getAppStoragePath();
    final dir = Directory(p.join(basePath, 'FileSnap', 'PDFs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> getTempFile(String extension) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return File(p.join(tempDir.path, fileName));
  }
}
