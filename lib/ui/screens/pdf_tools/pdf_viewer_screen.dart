import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path/path.dart' as p;

class PdfViewerScreen extends StatefulWidget {
  final String path;
  final String? title;

  const PdfViewerScreen({super.key, required this.path, this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  late PDFViewController pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? p.basename(widget.path)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {
              Share.shareXFiles([XFile(widget.path)], text: 'Document from FileSnap');
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: false, // User requested vertical scroll pages
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                pages = pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController vc) {
              pdfViewController = vc;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(child: CircularProgressIndicator())
                  : Container()
              : Center(child: Text(errorMessage)),
        ],
      ),
      floatingActionButton: isReady
          ? FloatingActionButton.extended(
              onPressed: null, // Just a passive indicator
              backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.9),
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 4,
              label: Text("Page ${currentPage! + 1} of $pages"),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
