// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PipedriveForm extends StatefulWidget {
  const PipedriveForm({Key key}) : super(key: key);

  @override
  State<PipedriveForm> createState() => _PipedriveFormState();
}

class _PipedriveFormState extends State<PipedriveForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void submit() {
    // It returns true if the form is valid, otherwise returns false
    if (_formKey.currentState.validate()) {
      // If the form is valid, display a Snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created in Pipedrive.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
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
              decoration: const InputDecoration(
                icon: const Icon(Icons.phone),
                hintText: 'Enter a phone number',
                labelText: 'Phone',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter valid phone number';
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
