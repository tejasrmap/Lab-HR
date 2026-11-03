import 'dart:typed_data';

class PdfConversionResult {
  final List<Uint8List> images;
  final String? error;

  PdfConversionResult({required this.images, this.error});
}

Future<PdfConversionResult> convertPdfBytesToImages(Uint8List pdfBytes) async {
  return PdfConversionResult(
    images: [],
    error: 'PDF to image conversion is optimized for web browser execution.',
  );
}

void triggerImageDownload(Uint8List imageBytes, String filename) {
  // Stub for non-web platforms
}

