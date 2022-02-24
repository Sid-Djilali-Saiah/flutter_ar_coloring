import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PipedriveService {
  static void createUser(name, email) async {
    var url = Uri.parse('https://epsi6.pipedrive.com/api/v1/persons?api_token=022810c0b654fdf281de997b82ba38a202f500dc');
    http.post(url, body: {
      'name': name,
      'email': email
    });
  }

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

  static bool isNameValid(String name) {
    return name.isNotEmpty;
  }

  static bool isEmailValid(String email) {
    return email.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
