import 'dart:typed_data';

import 'package:ar_flutter_plugin_example/widgets/header.dart';
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: BaseAppBar(actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              this.arCoreController.dispose();

              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ArView(selectedModel: 'rhinoceros')),
              );
            },
          )
        ],),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          type: ArCoreViewType.AUGMENTEDIMAGES,
          enableUpdateListener: false,
          enablePlaneRenderer: false,
          enableTapRecognizer: false,
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
    final ByteData rhinoceros = await rootBundle.load('assets/models/Rhinoceros/rhinoceros.jpg');
    final ByteData snake = await rootBundle.load('assets/models/Snake/snake.jpg');
    final ByteData monkey = await rootBundle.load('assets/models/Monkey/monkey.jpg');
    bytesMap["rhinoceros"] = rhinoceros.buffer.asUint8List();
    bytesMap["snake"] = snake.buffer.asUint8List();
    bytesMap["monkey"] = monkey.buffer.asUint8List();

    arCoreController.loadMultipleAugmentedImage(bytesMap: bytesMap);
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) async {
    if (!augmentedImagesMap.containsKey(augmentedImage.name)) {
      augmentedImagesMap[augmentedImage.name] = augmentedImage;

      this.arCoreController.dispose();

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArView(selectedModel: augmentedImage.name)),
      );
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}