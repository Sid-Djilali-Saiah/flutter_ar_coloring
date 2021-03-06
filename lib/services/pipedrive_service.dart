import 'package:http/http.dart' as http;

class PipedriveService {
  static void createUser(name, email) async {
    var url = Uri.parse('https://epsi6.pipedrive.com/api/v1/persons?api_token=022810c0b654fdf281de997b82ba38a202f500dc');
    http.post(url, body: {
      'name': name,
      'email': email
    });
  }

  static bool isNameValid(String name) {
    return name.isNotEmpty;
  }

  static bool isEmailValid(String email) {
    return email.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
