import 'package:another_flushbar/flushbar.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
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

class ArView extends StatefulWidget {
  final String selectedModel;

  ArView({Key key, this.selectedModel}) : super(key: key);

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
          actions: [],
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

            actions.add(IconButton(
              icon: const Icon(Icons.perm_device_information),
              onPressed: onShowInformation,
              color: Colors.amber.shade600,
              iconSize: 50,
            ));

            return Container(
                child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig:
                    PlaneDetectionConfig.horizontalAndVertical,
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
        );
    this.arObjectManager.onInitialize();

    this.arSessionManager.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager.onNodeTap = onNodeTapped;
  }

  Future<void> onRemoveEverything() async {
    anchors.forEach((anchor) {
      this.arAnchorManager.removeAnchor(anchor);
    });
    anchors = [];
  }

  Future<void> onShowInformation() async {
    Flushbar(
      title: 'Information',
      message:
          'The following model has been selected : ' + widget.selectedModel,
    )..show(context);
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
    var number = nodes.length;
    this.arSessionManager.onError("Tapped $number node(s)");
  }

  String getModelFilename() {
    const rootPath = "assets/models/";
    switch (widget.selectedModel) {
      case "elephant":
        return rootPath + "Chicken_01/Chicken_01.gltf";
        break;
      case "snake":
        return rootPath + "Dinosaur/dinosaur.gltf";
        break;
      case "monkey":
        return rootPath + "Chicken_01/Chicken_01.gltf";
        break;
      default:
        return rootPath + "Dinosaur/dinosaur.gltf";
    }
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor =
          ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool didAddAnchor = await this.arAnchorManager.addAnchor(newAnchor);
      if (didAddAnchor) {
        this.anchors.add(newAnchor);
        // Add note to anchor
        var newNode = ARNode(
            type: NodeType.localGLTF2,
            uri: getModelFilename(),
            scale: Vector.Vector3(0.2, 0.2, 0.2),
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
  }

  @override
  void dispose() {
    super.dispose();
    arSessionManager.dispose();
  }
}
