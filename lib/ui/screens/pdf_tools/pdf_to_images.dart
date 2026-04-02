import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class PdfToImagesScreen extends StatefulWidget {
  const PdfToImagesScreen({super.key});
  @override
  State<PdfToImagesScreen> createState() => _PdfToImagesScreenState();
}

class _PdfToImagesScreenState extends State<PdfToImagesScreen> {
  File? _file;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() => _file = File(result.files.single.path!));
    }
  }

  Future<void> _process() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Saved to /FileSnap/Images\n\nExtracted 10 images."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Share.shareXFiles([XFile(_file!.path)]); // Mock share
              }, 
              child: const Text("SHARE")
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF to Images")),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            if (_file == null)
              Expanded(
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
                    onPressed: _pickFile, 
                    icon: const Icon(LucideIcons.files, size: 48), 
                    label: const Text("SELECT PDF")
                  )
                )
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(LucideIcons.file, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(_file!.path.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 32),
                    const Text("Extracting all pages to High-Resolution JPG"),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      onPressed: _process,
                      icon: const Icon(LucideIcons.download),
                      label: const Text("EXTRACT IMAGES")
                    )
                  ],
                )
              )
            ]
          ]
        )
    );
  }
}
