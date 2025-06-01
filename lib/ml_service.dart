import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import 'utils.dart';
import 'image_converter.dart';

class MLService {
  Interpreter? interpreter;
  bool isInitialized = false;
  List? predictedArray;

  initializeInterpreter() async {
    if (isInitialized) return;
    try {
      Delegate? delegate;
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2();
        debugPrint('on est ici android');
      } else if (Platform.isIOS) {
        delegate = GpuDelegate();
      }

      final options = InterpreterOptions();
      if (delegate != null) options.addDelegate(delegate);

      interpreter = await Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
        options: options,
      );
      isInitialized = true;
      debugPrint(' Interpreter loaded with GPU');
    } catch (e) {
      debugPrint(' GPU init failed: $e');
      debugPrint(' Falling back to CPU...');
      try {
        interpreter = await Interpreter.fromAsset(
          'assets/mobilefacenet.tflite',
        );
        isInitialized = true;
        debugPrint(' Interpreter loaded with CPU');
      } catch (e) {
        debugPrint(' Interpreter init failed completely: $e');
        isInitialized = false;
      }
    }
  }

  Future<List> predict(InputImage inputImage, Face face) async {
    await initializeInterpreter();

    if (interpreter == null || !isInitialized) {
      throw Exception('Interpreter not initialized');
    }

    List input = _preProcess(inputImage, face);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter!.run(input, output);
    return output.reshape([192]);
  }

  double euclideanDistance(List<double> l1, List<double> l2) {
    if (l1.length != l2.length) {
      throw ArgumentError('Les vecteurs doivent avoir la même longueur');
    }

    double sum = 0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]), 2);
    }

    return pow(sum, 0.5).toDouble();
  }

  List _preProcess(InputImage image, Face faceDetected) {
    imglib.Image croppedImage = cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image cropFace(InputImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertInputImage(image);
    // Removed unused variable 'rotatedImage'
    imglib.copyRotate(convertedImage, -90);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;

    imglib.Image croppedImage = imglib.copyCrop(
      convertedImage,
      x.round(),
      y.round(),
      w.round(),
      h.round(),
    );

    return croppedImage;
  }

  imglib.Image _convertInputImage(InputImage image) {
    File imageFile = File(image.filePath!);
    List<int> bytes = imageFile.readAsBytesSync();
    imglib.Image? img = imglib.decodeImage(bytes);
    return img!;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
