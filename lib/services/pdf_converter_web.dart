import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

class PdfConversionResult {
  final List<Uint8List> images;
  final String? error;

  PdfConversionResult({required this.images, this.error});
}

@JS('convertPdfToImages')
external JSPromise<JSString> _convertPdfToImages(JSString base64Data);

@JS('downloadImageFile')
external void _downloadImageFile(JSString dataUrl, JSString filename);

Future<PdfConversionResult> convertPdfBytesToImages(Uint8List pdfBytes) async {
  try {
    final base64String = base64Encode(pdfBytes);
    final jsPromise = _convertPdfToImages(base64String.toJS);
    final jsResult = await jsPromise.toDart;
    final jsonStr = jsResult.toDart;

    final List<dynamic> dataUrls = jsonDecode(jsonStr);
    final List<Uint8List> images = [];

    for (final url in dataUrls) {
      final str = url.toString();
      final commaIndex = str.indexOf(',');
      if (commaIndex != -1) {
        final b64 = str.substring(commaIndex + 1);
        images.add(base64Decode(b64));
      }
    }

    return PdfConversionResult(images: images);
  } catch (e) {
    return PdfConversionResult(images: [], error: e.toString());
  }
}

void triggerImageDownload(Uint8List imageBytes, String filename) {
  try {
    final b64 = base64Encode(imageBytes);
    final dataUrl = 'data:image/png;base64,$b64';
    _downloadImageFile(dataUrl.toJS, filename.toJS);
  } catch (_) {}
}

