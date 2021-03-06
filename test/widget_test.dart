// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_flutter_plugin_example/services/pipedrive_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('Counter value should be incremented', () {
    expect(PipedriveService.isEmailValid("nicolasChambonTamere@lorem.fr"), true);
    expect(PipedriveService.isEmailValid("nicolasChambonTamere"), false);
  });

  test('is name valid', () {
    expect(PipedriveService.isNameValid("nicolasChambonTamere"), true);
    expect(PipedriveService.isNameValid(''), false);
  });
}
