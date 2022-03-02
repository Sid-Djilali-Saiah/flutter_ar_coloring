import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TexturingService {
  static Future<String> getTexturedFile(Uint8List imageBytes, String model) async {
    var request = new http.MultipartRequest("POST", Uri.parse("http://92.91.241.13:2000/texture/"+model));
    request.files.add(http.MultipartFile.fromBytes(
        'screenshot',
        imageBytes,
        contentType: MediaType('image', 'png'),
        filename: 'screenshot.png'
    ));

    String modelPath = "";
    try {
      await request.send().then((response) async {
        String stringResponse = await response.stream.bytesToString();
        debugPrint('paabo : 5 : ' + response.statusCode.toString());
        debugPrint('paabo : 55 : ' + stringResponse);
        if (response.statusCode == 200 && stringResponse.isNotEmpty) {
          modelPath = stringResponse;
        }
      });
    } on Exception catch (_) {
      modelPath = "";
    }

    return modelPath;
  }
}
