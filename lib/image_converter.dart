import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

import 'utils.dart';

class ImageConverter {
  static imglib.Image? convertFileToImage(File file) {
    List<int> bytes = file.readAsBytesSync();
    return imglib.decodeImage(bytes);
  }

  static InputImage convertFileToInputImage(File file) {
    return InputImage.fromFile(file);
  }

  static List<double> convertImageToVector(imglib.Image image) {
    // Redimensionner l'image à 112x112 pixels (taille requise pour le modèle de reconnaissance faciale)
    imglib.Image resizedImage = imglib.copyResizeCropSquare(image, 112);

    // Convertir l'image en vecteur de caractéristiques
    List<double> vector = [];
    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = resizedImage.getPixel(j, i);
        // Normaliser les valeurs RGB entre -1 et 1
        vector.add((imglib.getRed(pixel) - 128) / 128);
        vector.add((imglib.getGreen(pixel) - 128) / 128);
        vector.add((imglib.getBlue(pixel) - 128) / 128);
      }
    }
    return vector;
  }

  static imglib.Image cropFace(imglib.Image image, Face face) {
    double x = face.boundingBox.left - 10.0;
    double y = face.boundingBox.top - 10.0;
    double w = face.boundingBox.width + 20.0;
    double h = face.boundingBox.height + 20.0;

    // S'assurer que les coordonnées sont dans les limites de l'image
    x = x.clamp(0, image.width.toDouble());
    y = y.clamp(0, image.height.toDouble());
    w = w.clamp(0, image.width - x);
    h = h.clamp(0, image.height - y);

    return imglib.copyCrop(image, x.round(), y.round(), w.round(), h.round());
  }
}

imglib.Image? convertToImage(CameraImage image) {
  try {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    throw Exception('Image format not supported');
  } catch (e) {
    printIfDebug("ERROR:" + e.toString());
  }
  return null;
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width, height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  return img;
}
