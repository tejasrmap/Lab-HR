import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_converter.dart';

class PdfToImagesView extends StatefulWidget {
  const PdfToImagesView({super.key});

  @override
  State<PdfToImagesView> createState() => _PdfToImagesViewState();
}

class _PdfToImagesViewState extends State<PdfToImagesView> {
  bool _isProcessing = false;
  String? _selectedFileName;
  int? _fileSizeBytes;
  List<Uint8List> _convertedImages = [];
  String? _errorMessage;

  Future<void> _pickAndConvertPdf() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      final bytes = await file.readAsBytes();
      final size = await file.length();

      if (bytes.isEmpty) {
        setState(() {
          _errorMessage = 'Could not read PDF bytes from selected file.';
        });
        return;
      }

      setState(() {
        _isProcessing = true;
        _errorMessage = null;
        _selectedFileName = file.name;
        _fileSizeBytes = size;
        _convertedImages = [];
      });

      final conversionResult = await convertPdfBytesToImages(bytes);

      if (!mounted) return;

      if (conversionResult.error != null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = conversionResult.error;
        });
      } else {
        setState(() {
          _isProcessing = false;
          _convertedImages = conversionResult.images;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error reading PDF: $e';
      });
    }
  }

  void _downloadSingleImage(int index) {
    if (index >= _convertedImages.length) return;
    final baseName = _selectedFileName?.replaceAll('.pdf', '') ?? 'document';
    final fileName = '${baseName}_page_${index + 1}.png';
    triggerImageDownload(_convertedImages[index], fileName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF06B6D4)),
        ),
      ),
    );
  }

  void _downloadAllImages() {
    for (int i = 0; i < _convertedImages.length; i++) {
      _downloadSingleImage(i);
    }
  }

  void _reset() {
    setState(() {
      _convertedImages = [];
      _selectedFileName = null;
      _fileSizeBytes = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtitle
          const Center(
            child: Text(
              'High-fidelity client-side PDF renderer. Convert PDF pages into crystal-clear PNG images.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),

          // Upload Box / Converted Gallery
          if (_convertedImages.isEmpty && !_isProcessing)
            _buildUploadCard()
          else if (_isProcessing)
            _buildProcessingCard()
          else
            _buildGalleryView(),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2E0D1B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF43F5E)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFF43F5E), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFFDA4AF), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // GT INNOX Studio-styled Drop/Browse Zone
  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1527),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _pickAndConvertPdf,
            borderRadius: BorderRadius.circular(40),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.file_upload_outlined, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select your PDF document, or browse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Extracts all pages into lossless 2x scale PNG images in seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickAndConvertPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Choose PDF File', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: const Color(0xFF070B14),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildFeatureBadge(Icons.bolt_rounded, 'Fast On-Device Engine', const Color(0xFF38BDF8)),
              _buildFeatureBadge(Icons.lock_outline_rounded, '100% Private (No Cloud Upload)', const Color(0xFF10B981)),
              _buildFeatureBadge(Icons.hd_rounded, 'High-Res 2x PNG Output', const Color(0xFFA855F7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 54),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1527),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF06B6D4)),
          const SizedBox(height: 22),
          Text(
            'Rendering pages for "${_selectedFileName ?? 'Document'}"...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Extracting raster images on-device via high-performance canvas engine...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryView() {
    final sizeKb = ((_fileSizeBytes ?? 0) / 1024).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Header & Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1527),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF052E16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF16A34A)),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFileName ?? 'PDF Document',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_convertedImages.length} page(s) extracted • $sizeKb KB',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF94A3B8)),
                label: const Text('Convert Another', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _downloadAllImages,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download All', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: const Color(0xFF070B14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Grid of Converted Pages
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _convertedImages.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 440,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final imgBytes = _convertedImages[index];

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1527),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Page Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF070B14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Text(
                            'Page ${index + 1} of ${_convertedImages.length}',
                            style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFF06B6D4)),
                          tooltip: 'Download Page ${index + 1}',
                          onPressed: () => _downloadSingleImage(index),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFF1E293B)),

                  // Image Preview
                  Expanded(
                    child: Container(
                      color: const Color(0xFF070B14),
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.memory(
                            imgBytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Button
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadSingleImage(index),
                        icon: const Icon(Icons.download_for_offline_outlined, size: 16, color: Colors.white),
                        label: Text(
                          'Save Page ${index + 1} PNG',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E293B)),
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
