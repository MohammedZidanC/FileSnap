import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/tool_card.dart';
import 'images_to_pdf.dart';
import 'camera_to_pdf.dart';
import 'rearrange_pdf.dart';
import 'merge_pdfs.dart';
import 'split_pdf.dart';
import 'compress_pdf_tool.dart';
import 'pdf_to_images.dart';
import 'watermark_pdf.dart';

class PdfHome extends StatelessWidget {
  const PdfHome({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = <Widget>[
      ToolCard(
        title: "Images to PDF",
        icon: LucideIcons.imagePlus,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImagesToPdfScreen())),
      ),
      ToolCard(
        title: "Camera to PDF",
        icon: LucideIcons.camera,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraToPdfScreen())),
      ),
      ToolCard(
        title: "Rearrange Pages",
        icon: LucideIcons.layers,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RearrangePdfScreen())),
      ),
      ToolCard(
        title: "Merge PDFs",
        icon: LucideIcons.filePlus,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MergePdfsScreen())),
      ),
      ToolCard(
        title: "Split PDF",
        icon: LucideIcons.scissors,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitPdfScreen())),
      ),
      ToolCard(
        title: "Compress PDF",
        icon: LucideIcons.shrink,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompressPdfToolScreen())),
      ),
      ToolCard(
        title: "PDF to Images",
        icon: LucideIcons.files,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfToImagesScreen())),
      ),
      ToolCard(
        title: "Add Watermark",
        icon: LucideIcons.stamp,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WatermarkPdfScreen())),
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            "PDF Tools",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.8),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              return tools[index]
                  .animate()
                  .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index))
                  .slideY(begin: 0.1, duration: 300.ms, delay: Duration(milliseconds: 50 * index));
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
