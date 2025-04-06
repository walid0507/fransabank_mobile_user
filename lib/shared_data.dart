import 'dart:typed_data';

class SharedData {
  static Uint8List? imageData;     // photo récupérée via NFC
  static Uint8List? signatureData; // signature récupérée via NFC

  static bool get hasNfcData => imageData != null || signatureData != null;

  static void clear() {
    imageData = null;
    signatureData = null;
  }
}
