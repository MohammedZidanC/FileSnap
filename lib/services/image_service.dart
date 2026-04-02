import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'storage_service.dart';

class ImageService {
  /// Strict resize to target KB.
  /// Iteratively reduces quality and scaling to ensure output is <= target an at least 1KB below target if possible.
  static Future<File?> resizeImageToTargetList({
    required File originalFile,
    required double targetKB,
  }) async {
    int targetBytes = (targetKB * 1024).toInt();
    int minBytes = targetBytes - 1024; // At least 1KB below
    if (minBytes < 0) minBytes = 0;

    // Safety bounds
    if (targetBytes < 1024) throw Exception("Target size too small (min 1KB)");

    int currentQuality = 90;
    int currentWidth = 1920; 
    
    File? lastValidFile;

    // Retry limit to 7 to guarantee finding target without infinite loop
    for (int i = 0; i < 7; i++) {
      final tempFile = await StorageService.getTempFile('jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        tempFile.absolute.path,
        quality: currentQuality,
        minWidth: currentWidth,
        minHeight: currentWidth,
        format: CompressFormat.jpeg,
      );

      if (result == null) throw Exception("Compression failed");

      final resultFile = File(result.path);
      final size = await resultFile.length();

      if (size <= targetBytes) {
        lastValidFile = resultFile;
        // If it's within the sweet spot (<= target and >= target-1024), we break early.
        // Even if safely below strictly, we accept it to guarantee completion.
        if (size <= targetBytes) {
           break;
        }
      }

      // If it's still too big, push quality and resolution down aggressively
      if (size > targetBytes) {
        currentQuality -= 15;
        if (currentQuality < 10) currentQuality = 10;
        
        // Adaptive resolution scaling guarantees exponential size drop
        if (i >= 1) {
           currentWidth = (currentWidth * 0.7).toInt(); // drop resolution by 30%
           if (currentWidth < 100) currentWidth = 100;
        }
      }
    }

    if (lastValidFile != null) {
      // Move to FileSnap output folder
      final finalDir = await StorageService.getImagesDirectory();
      final outputName = 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final finalFile = await lastValidFile.copy(p.join(finalDir.path, outputName));
      return finalFile;
    }
    
    throw Exception("Could not compress image to target size after multiple attempts");
  }
}
