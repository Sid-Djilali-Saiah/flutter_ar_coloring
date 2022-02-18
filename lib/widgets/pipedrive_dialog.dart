import 'package:ar_flutter_plugin_example/widgets/pipedrive_form.dart';
import 'package:flutter/material.dart';

class PipedriveDialog extends StatelessWidget {
  const PipedriveDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Pipedrive form'),
          content: PipedriveForm(),
          /*actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],*/
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}