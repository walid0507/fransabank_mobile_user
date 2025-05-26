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
    static InputImage rotateInputImage(InputImage inputImage, int angleDegrees) {
    // Convertir l'image en imglib.Image pour la manipulation
    final imglibImage = convertFileToImage(File(inputImage.filePath!));
    if (imglibImage == null) {
      throw Exception('Impossible de convertir l\'image pour la rotation.');
    }

    // Faire pivoter l'image selon l'angle spécifié
    imglib.Image rotated;
    switch (angleDegrees) {
      case 90:
        rotated = imglib.copyRotate(imglibImage, 90);
        break;
      case 180:
        rotated = imglib.copyRotate(imglibImage, 180);
        break;
      case 270:
        rotated = imglib.copyRotate(imglibImage, 270);
        break;
      default:
        rotated = imglibImage;
    }

    // Convertir l'image pivotée en InputImage
    final tempFile = File(inputImage.filePath!);
    tempFile.writeAsBytesSync(imglib.encodeJpg(rotated));

    return InputImage.fromFile(tempFile);
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

  // Vérifier si les plans sont valides
  if (image.planes.length < 3) {
    throw Exception('Image YUV420 invalide: nombre de plans insuffisant');
  }

  // Vérifier les dimensions des plans
  if (image.planes[0].bytes.length < width * height) {
    throw Exception('Plan Y invalide: dimensions incorrectes');
  }

  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;

  // Pré-calculer les indices UV
  final uvIndices = List<int>.generate(
    (width * height) ~/ 4,
    (i) =>
        uvPixelStride! * (i % (width ~/ 2)) +
        uvyButtonStride * (i ~/ (width ~/ 2)),
  );

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      try {
        final int index = y * width + x;
        final int uvIndex = uvIndices[(y ~/ 2) * (width ~/ 2) + (x ~/ 2)];

        if (index < image.planes[0].bytes.length &&
            uvIndex < image.planes[1].bytes.length &&
            uvIndex < image.planes[2].bytes.length) {
          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];

          // Optimisation des calculs RGB
          final vp1436 = vp * 1436;
          final up46549 = up * 46549;
          final vp93604 = vp * 93604;
          final up1814 = up * 1814;

          int r = (yp + (vp1436 ~/ 1024) - 179).clamp(0, 255);
          int g = (yp - (up46549 ~/ 131072) + 44 - (vp93604 ~/ 131072) + 91)
              .clamp(0, 255);
          int b = (yp + (up1814 ~/ 1024) - 227).clamp(0, 255);

          img.data[index] = hexFF | (b << 16) | (g << 8) | r;
        }
      } catch (e) {
        print('Erreur lors de la conversion YUV420: $e');
      }
    }
  }

  return img;
}
