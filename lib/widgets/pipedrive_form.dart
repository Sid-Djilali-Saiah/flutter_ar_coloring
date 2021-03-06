import 'package:ar_flutter_plugin_example/services/utils_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ar_flutter_plugin_example/services/pipedrive_service.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';

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

      PipedriveService.createUser(nameController.text, emailController.text);
      var path = await UtilsService.compressImageToFile(widget.image, 'image2.jpg');

      Share.shareFiles([path], text: '#Cerealis');
      Navigator.pop(context, 'Cancel');
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
                return PipedriveService.isNameValid(value) ? null : 'Please enter some text';
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
                return PipedriveService.isEmailValid(value) ? null : 'Please enter an valid email';
              },
            ),
            CheckboxListTileFormField(
              title: Text('I agree to share my data', style: TextStyle(fontSize: 12),),
              validator: (bool value) {
                if (value) {
                  return null;
                } else {
                  return 'Please, check the box';
                }
              },
              autovalidateMode: AutovalidateMode.disabled,
              contentPadding: const EdgeInsets.only(top: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              ),
            )
          ],
        )
      );
    }
}
