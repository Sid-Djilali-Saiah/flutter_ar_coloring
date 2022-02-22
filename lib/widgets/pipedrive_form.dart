import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class PipedriveForm extends StatefulWidget {
  const PipedriveForm({Key key, this.image}) : super(key: key);
  final MemoryImage image;

  @override
  State<PipedriveForm> createState() => _PipedriveFormState();
}

class _PipedriveFormState extends State<PipedriveForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void submit() async {
    // It returns true if the form is valid, otherwise returns false
    if (_formKey.currentState.validate()) {
      // If the form is valid, display a Snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created in Pipedrive.')));

      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      final File newImagePath = File(path); //pasting path

      newImagePath.writeAsBytesSync(widget.image.bytes);

      await FlutterImageCompress.compressAndGetFile(
        newImagePath.absolute.path, '${temp.path}/image2.jpg',
        quality: 95,
      );

      var url = Uri.parse('https://nonstopintegration.pipedrive.com/api/v1/persons?api_token=3ccde48496d27a21b7362aa1bd42b888bbc00164');
      http.post(url, body: {
        'name': nameController.text,
        'email': emailController.text
      });

      Share.shareFiles(['${temp.path}/image2.jpg'], text: 'Test');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                icon: const Icon(Icons.person),
                hintText: 'Enter your full name',
                labelText: 'Name',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                icon: const Icon(Icons.email),
                hintText: 'Enter an email',
                labelText: 'Email',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter valid Email';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                <Widget>[
                  ElevatedButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                  ),
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () => submit(),
                  )
              ]
            )
          ],
        )
      );
    }
}
