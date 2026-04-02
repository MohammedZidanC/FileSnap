import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A reusable stub screen for PDF tools that are wired but not fully implemented yet.
/// Shows a proper UI with file picker instead of a dead button.
class PdfToolStubScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;
  final bool pickFiles; // true = file picker, false = camera

  const PdfToolStubScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.pickFiles = true,
  });

  @override
  State<PdfToolStubScreen> createState() => _PdfToolStubScreenState();
}

class _PdfToolStubScreenState extends State<PdfToolStubScreen> {
  final List<File> _selectedFiles = [];

  Future<void> _pickFiles() async {
    if (widget.pickFiles) {
      final xfiles = await ImagePicker().pickMultiImage();
      if (xfiles.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(xfiles.map((x) => File(x.path)));
        });
      }
    } else {
      final xfile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (xfile != null) {
        setState(() {
          _selectedFiles.add(File(xfile.path));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Icon(widget.icon, size: 48, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.description, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedFiles.isNotEmpty) ...[
              Text("${_selectedFiles.length} file(s) selected", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (ctx, i) => ListTile(
                    leading: const Icon(LucideIcons.file),
                    title: Text("File ${i + 1}"),
                    trailing: IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red),
                      onPressed: () => setState(() => _selectedFiles.removeAt(i)),
                    ),
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Text("No files selected", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: Icon(widget.pickFiles ? LucideIcons.upload : LucideIcons.camera),
              label: Text(widget.pickFiles ? "SELECT FILES" : "CAPTURE"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Processing... This tool is being finalized.")),
                  );
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text("PROCESS"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
