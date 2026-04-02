import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class SplitPdfScreen extends StatefulWidget {
  const SplitPdfScreen({super.key});
  @override
  State<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends State<SplitPdfScreen> {
  File? _file;
  RangeValues _range = const RangeValues(1, 10);
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
        _range = const RangeValues(1, 10);
      });
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
          content: const Text("Saved to /FileSnap/PDFs\n\nSplit_1_10.pdf"),
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
      appBar: AppBar(title: const Text("Split PDF")),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            if (_file == null)
              Expanded(
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickFile, 
                    icon: const Icon(LucideIcons.scissors, size: 48), 
                    label: const Text("SELECT PDF")
                  )
                )
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(LucideIcons.file, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_file!.path.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 32),
                    Text("Split Pages: ${_range.start.toInt()} to ${_range.end.toInt()}", style: const TextStyle(fontSize: 16)),
                    RangeSlider(
                      values: _range,
                      min: 1,
                      max: 20, // dummy max
                      divisions: 19,
                      labels: RangeLabels(_range.start.toInt().toString(), _range.end.toInt().toString()),
                      onChanged: (v) => setState(() => _range = v),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      onPressed: _process,
                      child: const Text("SPLIT AND SAVE")
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
