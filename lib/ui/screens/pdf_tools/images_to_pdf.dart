import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../services/storage_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/processing_screen.dart';
import 'pdf_viewer_screen.dart';
import 'package:flutter/foundation.dart';
import '../image_tools/image_editor_screen.dart'; // To open image editor

Future<void> _buildPdfInIsolate(Map<String, dynamic> args) async {
  List<String> paths = args['paths'];
  String outPath = args['outPath'];

  final pdf = pw.Document();
  for (var path in paths) {
    final file = File(path);
    final image = pw.MemoryImage(file.readAsBytesSync());
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );
  }
  final file = File(outPath);
  file.writeAsBytesSync(await pdf.save());
}

class ImagesToPdfScreen extends StatefulWidget {
  const ImagesToPdfScreen({super.key});

  @override
  State<ImagesToPdfScreen> createState() => _ImagesToPdfScreenState();
}

class _ImagesToPdfScreenState extends State<ImagesToPdfScreen> {
  final List<File> _images = [];
  bool _isProcessing = false;

  Future<void> _pickImages() async {
    final xfiles = await ImagePicker().pickMultiImage();
    if (xfiles.isNotEmpty) {
      setState(() {
        _images.addAll(xfiles.map((x) => File(x.path)));
      });
    }
  }

  void _openEditor() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageEditorScreen()));
  }

  Future<void> _buildPdf() async {
    if (_images.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final finalDir = await StorageService.getPdfsDirectory();
      final finalName = 'Document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outPath = p.join(finalDir.path, finalName);
      
      final paths = _images.map((f) => f.path).toList();
      
      await compute(_buildPdfInIsolate, {'paths': paths, 'outPath': outPath});

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: Text("Saved to /FileSnap/PDFs\n\n$finalName"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Share.shareXFiles([XFile(outPath)]);
                }, 
                child: const Text("SHARE")
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PdfViewerScreen(path: outPath)));
                },
                child: const Text("VIEW")
              ),
            ],
          )
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to build PDF.")));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images to PDF"),
        actions: [
          if (_images.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.edit2),
              onPressed: _openEditor,
              tooltip: "Edit Images",
            )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isProcessing 
          ? const ProcessingScreen(progress: 0.5)
          : Column(
              children: [
                Expanded(
                child: _images.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.imagePlus, size: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text("No images selected"),
                        ],
                      ),
                    )
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _images.removeAt(oldIndex);
                          _images.insert(newIndex, item);
                        });
                      },
                      children: [
                        for (int i = 0; i < _images.length; i++)
                          ListTile(
                            key: ValueKey(_images[i].path),
                            leading: Image.file(_images[i], width: 50, height: 50, fit: BoxFit.cover),
                            title: Text('Page ${i+1}'),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.trash2, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(i);
                                });
                              },
                            ),
                          )
                      ],
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: _pickImages, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text("ADD IMAGES"))),
                      const SizedBox(width: 16),
                      Expanded(child: ElevatedButton(onPressed: _images.isEmpty ? null : _buildPdf, child: const Text("CREATE PDF"))),
                    ],
                  ),
                )
              ],
          ),
      ),
    );
  }
}
