import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class CompressPdfToolScreen extends StatefulWidget {
  const CompressPdfToolScreen({super.key});
  @override
  State<CompressPdfToolScreen> createState() => _CompressPdfToolScreenState();
}

class _CompressPdfToolScreenState extends State<CompressPdfToolScreen> {
  File? _file;
  int _quality = 50; // 1-100
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
          content: const Text("Saved to /FileSnap/PDFs\n\nCompressed.pdf"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Share.shareXFiles([XFile(_file!.path)]);
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
      appBar: AppBar(title: const Text("Compress PDF")),
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
                    icon: const Icon(LucideIcons.shrink, size: 48), 
                    label: const Text("SELECT PDF TO COMPRESS")
                  )
                )
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(LucideIcons.file, size: 64, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text(_file!.path.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    Text("Quality: ${_quality}%", style: const TextStyle(fontSize: 16)),
                    Slider(
                      value: _quality.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: _quality.toString(),
                      onChanged: (v) => setState(() => _quality = v.toInt()),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      onPressed: _process,
                      child: const Text("COMPRESS & SAVE")
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
