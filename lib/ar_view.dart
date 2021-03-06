import 'dart:io';
import 'dart:typed_data';

import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_example/services/texturing_service.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:restart_app/restart_app.dart';
import 'package:ar_flutter_plugin_example/services/utils_service.dart';
import 'package:ar_flutter_plugin_example/widgets/header.dart';
import 'package:ar_flutter_plugin_example/widgets/pipedrive_form.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:vector_math/vector_math_64.dart' as Vector;
// ignore: implementation_imports
import 'package:arcore_flutter_plugin/src/arcore_pose.dart';

// ignore: must_be_immutable
class ArView extends StatefulWidget {
  final ArCoreAugmentedImage arCoreAugmentedImage;
  Uint8List screenshotBytes;

  ArView({Key key, this.arCoreAugmentedImage, this.screenshotBytes}) : super(key: key);

  @override
  _ArViewState createState() => _ArViewState();
}

class _ArViewState extends State<ArView> {
  ARSessionManager arSessionManager;
  ARObjectManager arObjectManager;
  ARAnchorManager arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: BaseAppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                Restart.restartApp();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                onRefresh();
              },
            ),
          ],
        ),
        body: FutureBuilder<bool>(
          future: UtilsService.hasInternet(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            List<Widget> actions = [];

            if (snapshot.hasData && snapshot.data == true) {
              actions = [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: onTakeScreenshot,
                  color: Colors.amber.shade600,
                  iconSize: 50,
                )
              ];
            }

            actions.add(IconButton(
              icon: const Icon(Icons.highlight_remove_outlined),
              onPressed: onRemoveEverything,
              color: Colors.amber.shade600,
              iconSize: 50,
            ));

            return Container(
                child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig:
                    PlaneDetectionConfig.horizontal,
              ),
              Align(
                alignment: FractionalOffset.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: actions,
                ),
              )
            ]));
          },
        ),
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: false,
          showAnimatedGuide: false,
        );
    this.arObjectManager.onInitialize();

    this.arSessionManager.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager.onNodeTap = onNodeTapped;

    this.onFoundImage();
  }

  Future<void> onRemoveEverything() async {
    anchors.forEach((anchor) {
      this.arAnchorManager.removeAnchor(anchor);
    });
    anchors = [];
  }

  Future<bool> onTakeScreenshot() async {
    bool hasInternet = await UtilsService.hasInternet();

    if (hasInternet == false) {
      await showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text("Your internet is OFF !"),
              content: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                      ),
                    ]),
              )));
      return false;
    }

    MemoryImage image = await this.arSessionManager.snapshot();

    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: PipedriveForm(image: image),
            ));

    return true;
  }

  Future<void> onNodeTapped(List<String> nodes) async {
    String modelName =
        "${(await getModelName())?.toUpperCase()[0]}${(await getModelName())?.substring(1)?.toLowerCase()}";
    this.arSessionManager.onError("This is a : " + modelName);
  }

  Future<Map<String, Object>> getModelData() async {
    const rootPath = "assets/models/";
    String modelPath = rootPath + "Dinosaur/dinosaur.gltf";
    switch (await getModelName()) {
      case "rhinoceros":
        modelPath = rootPath + "Rhinoceros/rhinoceros.gltf";
        break;
      case "snake":
        modelPath = rootPath + "Snake/snake.gltf";
        break;
      case "monkey":
        modelPath = rootPath + "Monkey/monkey.gltf";
        break;
    }

    if (widget.screenshotBytes.isNotEmpty) {
      String webModelPath = await TexturingService.getTexturedFile(widget.screenshotBytes, await getModelName());
      if (webModelPath.isNotEmpty) {
        return {
          'modalPath': "http://92.91.241.13:2000/get/model/" + webModelPath,
          'type': NodeType.webGLB
        };
      }
    }

    return {'modalPath': modelPath, 'type': NodeType.localGLTF2};
  }

  Future<void> onRefresh() async {
    await this.onRemoveEverything();

    String imagePath = await NativeScreenshot.takeScreenshot();
    widget.screenshotBytes = File(imagePath).readAsBytesSync();

    ArCorePose centerPose = widget.arCoreAugmentedImage.centerPose;

    var transformation = new Matrix4.compose(
        centerPose.translation,
        new Vector.Quaternion(0.0, centerPose.rotation.y, 0.0, centerPose.rotation.w),
        Vector.Vector3(0.1, 0.1, 0.1)
    );

    await placeNode(transformation);
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    await this.onRemoveEverything();

    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      await placeNode(singleHitTestResult.worldTransform);
    }
  }

  Future<void> onFoundImage() async {
    if (widget.arCoreAugmentedImage != null) {
      await Future.delayed(Duration(seconds: 3));
      ArCorePose centerPose = widget.arCoreAugmentedImage.centerPose;

      var transformation = new Matrix4.compose(
          centerPose.translation,
          new Vector.Quaternion(0.0, centerPose.rotation.y, 0.0, centerPose.rotation.w),
          Vector.Vector3(0.1, 0.1, 0.1)
      );

      await placeNode(transformation);
    }
  }

  Future<void> placeNode(transformation) async {
    var newAnchor = ARPlaneAnchor(transformation: transformation);
    bool didAddAnchor = await this.arAnchorManager.addAnchor(newAnchor);
    if (didAddAnchor) {
      this.arSessionManager.onError("Adding node ...");
      this.anchors.add(newAnchor);
      // Add note to anchor
      var modelData = await getModelData();
      var newNode = ARNode(
          type: modelData["type"],
          uri: modelData["modalPath"],
          scale: Vector.Vector3(0.1, 0.1, 0.1),
          position: Vector.Vector3(0.0, 0.0, 0.0),
          rotation: Vector.Vector4(1.0, 0.0, 0.0, 0.0));
      bool didAddNodeToAnchor =
      await this.arObjectManager.addNode(newNode, planeAnchor: newAnchor);
      if (didAddNodeToAnchor) {
        this.nodes.add(newNode);
      } else {
        this.arSessionManager.onError("Adding Node to Anchor failed");
      }
    } else {
      this.arSessionManager.onError("Adding Anchor failed");
    }
  }

  Future<String> getModelName() async {
    switch (widget.arCoreAugmentedImage?.name) {
      case "rhinocerosHead":
        return "rhinoceros";
        break;
      case "snakeHead":
        return "snake";
        break;
      case "monkeyHead":
        return "monkey";
        break;
    }

    return widget.arCoreAugmentedImage?.name;
  }

  @override
  Future<void> dispose() async {
    await arSessionManager.dispose();
    super.dispose();
  }
}
