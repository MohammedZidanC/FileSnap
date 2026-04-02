import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../services/storage_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/processing_screen.dart';

class CameraToPdfScreen extends StatefulWidget {
  const CameraToPdfScreen({super.key});
  @override
  State<CameraToPdfScreen> createState() => _CameraToPdfScreenState();
}

class _CameraToPdfScreenState extends State<CameraToPdfScreen> {
  final List<File> _images = [];
  bool _isProcessing = false;

  Future<void> _capture() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (xfile != null) {
      setState(() => _images.add(File(xfile.path)));
    }
  }

  Future<void> _buildPdf() async {
    if (_images.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final finalDir = await StorageService.getPdfsDirectory();
      final finalName = 'Camera_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outPath = p.join(finalDir.path, finalName);
      
      final pdf = pw.Document();
      for (var f in _images) {
        final image = pw.MemoryImage(f.readAsBytesSync());
        pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
      }
      final file = File(outPath);
      file.writeAsBytesSync(await pdf.save());

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
            ],
          )
        );
      }
    } finally {
       setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera to PDF")),
      body: _isProcessing 
        ? const ProcessingScreen(progress: 0.5)
        : Column(
          children: [
            Expanded(
              child: _images.isEmpty 
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
                        onPressed: _capture, 
                        icon: const Icon(LucideIcons.camera, size: 48), 
                        label: const Text("START CAPTURING")
                      ),
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
                     for (int i=0; i<_images.length; i++)
                       ListTile(
                         key: ValueKey(_images[i].path),
                         leading: Image.file(_images[i], width: 50, height: 50, fit: BoxFit.cover),
                         title: Text("Page ${i+1}"),
                         trailing: IconButton(
                           icon: const Icon(LucideIcons.trash2, color: Colors.red),
                           onPressed: () => setState(()=>_images.removeAt(i)),
                         ),
                       )
                  ],
                ),
            ),
            if (_images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: _capture, icon: const Icon(LucideIcons.plus), label: const Text("ADD MORE"))),
                    const SizedBox(width: 16),
                    Expanded(child: ElevatedButton(onPressed: _buildPdf, child: const Text("CREATE PDF"))),
                  ],
                )
              )
          ],
        )
    );
  }
}
