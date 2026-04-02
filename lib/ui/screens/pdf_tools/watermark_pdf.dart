import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class WatermarkPdfScreen extends StatefulWidget {
  const WatermarkPdfScreen({super.key});
  @override
  State<WatermarkPdfScreen> createState() => _WatermarkPdfScreenState();
}

class _WatermarkPdfScreenState extends State<WatermarkPdfScreen> {
  File? _file;
  String _watermarkText = "FileSnap";
  double _opacity = 0.5;
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
          content: const Text("Saved to /FileSnap/PDFs\n\nWatermarked.pdf"),
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
      appBar: AppBar(title: const Text("Add Watermark (PDF)")),
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
                    icon: const Icon(LucideIcons.stamp, size: 48), 
                    label: const Text("SELECT PDF")
                  )
                )
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(LucideIcons.file, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(_file!.path.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 32),
                    TextField(
                      decoration: const InputDecoration(labelText: "Watermark Text", border: OutlineInputBorder()),
                      onChanged: (v) => setState(() => _watermarkText = v),
                      controller: TextEditingController(text: _watermarkText),
                    ),
                    const SizedBox(height: 16),
                    Text("Opacity: ${(_opacity*100).toInt()}%"),
                    Slider(
                      value: _opacity,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (v) => setState(() => _opacity = v),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      onPressed: _process,
                      icon: const Icon(LucideIcons.check),
                      label: const Text("APPLY & SAVE")
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
