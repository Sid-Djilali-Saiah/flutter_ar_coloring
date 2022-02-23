import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';

import 'ar_view.dart';

class AugmentedPage extends StatefulWidget {
  @override
  _AugmentedPageState createState() => _AugmentedPageState();
}

class _AugmentedPageState extends State<AugmentedPage> {
  ArCoreController arCoreController;
  Map<String, ArCoreAugmentedImage> augmentedImagesMap = Map();
  Map<String, Uint8List> bytesMap = Map();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          type: ArCoreViewType.AUGMENTEDIMAGES,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController.onTrackingImage = _handleOnTrackingImage;
    await loadMultipleImage();
  }

  loadMultipleImage() async {
    final ByteData earth = await rootBundle.load('assets/images/earth_augmented_image.jpg');
    final ByteData elephant = await rootBundle.load('assets/images/elephant.jpg');
    final ByteData snake = await rootBundle.load('assets/images/snake.jpg');
    final ByteData monkey = await rootBundle.load('assets/images/monkey.jpg');
    bytesMap["earth"] = earth.buffer.asUint8List();
    bytesMap["elephant"] = elephant.buffer.asUint8List();
    bytesMap["snake"] = snake.buffer.asUint8List();
    bytesMap["monkey"] = monkey.buffer.asUint8List();

    arCoreController.loadMultipleAugmentedImage(bytesMap: bytesMap);
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) async {
    if (!augmentedImagesMap.containsKey(augmentedImage.name)) {
      augmentedImagesMap[augmentedImage.name] = augmentedImage;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArView(modelFileName: augmentedImage.name)),
      );
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}