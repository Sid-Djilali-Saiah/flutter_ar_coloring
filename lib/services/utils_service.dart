import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UtilsService {
  static Future<String> compressImageToFile(image, filename) async {
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    final File newImagePath = File(path); //pasting path

    newImagePath.writeAsBytesSync(image.bytes);

    await FlutterImageCompress.compressAndGetFile(
      newImagePath.absolute.path, '${temp.path}/$filename',
      quality: 95,
    );

    return '${temp.path}/$filename';
  }

  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('www.google.fr');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }

    return false;
  }

  static Future<void> askPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
      Permission.location,
    ].request();
  }
}
