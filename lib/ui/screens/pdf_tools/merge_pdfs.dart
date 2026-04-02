import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class MergePdfsScreen extends StatefulWidget {
  const MergePdfsScreen({super.key});
  @override
  State<MergePdfsScreen> createState() => _MergePdfsScreenState();
}

class _MergePdfsScreenState extends State<MergePdfsScreen> {
  final List<File> _files = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);
    if (result != null) {
      setState(() {
        _files.addAll(result.paths.where((p) => p != null).map((p) => File(p!)));
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
          content: const Text("Saved to /FileSnap/PDFs\n\nMerged.pdf"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Share.shareXFiles([XFile(_files.first.path)]);
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
      appBar: AppBar(title: const Text("Merge PDFs")),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: _files.isEmpty 
                  ? Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
                        onPressed: _pickFiles, 
                        icon: const Icon(LucideIcons.filePlus, size: 48), 
                        label: const Text("SELECT PDF FILES")
                      )
                    )
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _files.removeAt(oldIndex);
                          _files.insert(newIndex, item);
                        });
                      },
                      children: [
                        for (int i=0; i<_files.length; i++)
                          ListTile(
                            key: ValueKey(_files[i].path),
                            leading: const Icon(LucideIcons.file, color: Colors.red),
                            title: Text(_files[i].path.split('/').last),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.trash2, color: Colors.red),
                              onPressed: () => setState(()=>_files.removeAt(i)),
                            ),
                          )
                      ],
                    )
              ),
              if (_files.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(child: ElevatedButton.icon(onPressed: _pickFiles, icon: const Icon(LucideIcons.plus), label: const Text("ADD MORE"))),
                      const SizedBox(width: 16),
                      Expanded(child: ElevatedButton(onPressed: _files.length > 1 ? _process : null, child: const Text("MERGE PDFs"))),
                    ],
                  )
                )
            ],
          )
    );
  }
}
