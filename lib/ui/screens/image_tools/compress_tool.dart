import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../services/storage_service.dart';
import 'package:path/path.dart' as p;

class CompressToolScreen extends StatefulWidget {
  const CompressToolScreen({super.key});

  @override
  State<CompressToolScreen> createState() => _CompressToolScreenState();
}

class _CompressToolScreenState extends State<CompressToolScreen> {
  File? _originalFile;
  double _quality = 80;
  bool _isProcessing = false;
  File? _resultFile;
  final _targetController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _originalFile = File(xfile.path);
        _resultFile = null;
      });
    }
  }

  Future<void> _compressByQuality() async {
    if (_originalFile == null) return;
    setState(() => _isProcessing = true);
    
    HapticFeedback.mediumImpact(); // Haptic feedback on button
    
    try {
      final tempFile = await StorageService.getTempFile('jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        _originalFile!.path,
        tempFile.path,
        quality: _quality.toInt(),
      );
      
      if (result != null) {
        final finalDir = await StorageService.getImagesDirectory();
        final finalFile = await File(result.path).copy(p.join(finalDir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg'));
        setState(() {
          _resultFile = finalFile;
        });
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compress Image")),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _originalFile != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_originalFile!, fit: BoxFit.cover))
                        : const Center(child: Icon(Icons.add_photo_alternate, size: 60)),
                  ),
                ),
                const SizedBox(height: 32),
                const Text("Quality Slider", style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _quality,
                  min: 10,
                  max: 100,
                  divisions: 90,
                  label: "${_quality.toInt()}%",
                  onChanged: (val) {
                    setState(() => _quality = val);
                    // Haptic feedback every 10%
                    if (val % 10 == 0) HapticFeedback.selectionClick();
                  },
                ),
                const SizedBox(height: 16),
                const Text("Target KB (Strict)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "e.g., 500 for 500KB"),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _originalFile == null ? null : _compressByQuality,
                  child: const Padding(padding: EdgeInsets.all(16), child: Text("COMPRESS NOW")),
                ),
                if (_resultFile != null) ...[
                   const SizedBox(height: 24),
                   Text("Saved to: ${_resultFile!.path}", style: const TextStyle(color: Colors.green), textAlign: TextAlign.center),
                ]
              ],
            ),
        ),
    );
  }
}
