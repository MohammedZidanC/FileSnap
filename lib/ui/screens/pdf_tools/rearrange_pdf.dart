import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class RearrangePdfScreen extends StatefulWidget {
  const RearrangePdfScreen({super.key});
  @override
  State<RearrangePdfScreen> createState() => _RearrangePdfScreenState();
}

class _RearrangePdfScreenState extends State<RearrangePdfScreen> {
  File? _pdfFile;
  final List<int> _pages = [];
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        // Mock 10 pages for UI
        _pages.clear();
        _pages.addAll(List.generate(10, (i) => i + 1));
      });
    }
  }

  Future<void> _process() async {
    setState(() => _isProcessing = true);
    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Saved to /FileSnap/PDFs\n\nRearranged.pdf"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Share.shareXFiles([XFile(_pdfFile!.path)]);
              }, 
              child: const Text("SHARE")
            ),
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rearrange Pages")),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if (_pdfFile == null)
                Expanded(
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickFile, 
                      icon: const Icon(LucideIcons.filePlus, size: 48), 
                      label: const Text("SELECT PDF")
                    )
                  )
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Drag to reorder pages of ${_pdfFile!.path.split('/').last}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _pages.removeAt(oldIndex);
                        _pages.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int i=0; i<_pages.length; i++)
                        ListTile(
                          key: ValueKey(_pages[i]),
                          leading: const Icon(LucideIcons.file),
                          title: Text("Page ${_pages[i]}"),
                          trailing: const Icon(Icons.drag_handle),
                        )
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: _process,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("SAVE REARRANGED PDF")
                  ),
                )
              ]
            ],
          )
    );
  }
}
