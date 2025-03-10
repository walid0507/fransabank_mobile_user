import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://f3e5-105-99-19-72.ngrok-free.app"; // Mets l'IP de ton serveur

  static Future<Map<String, dynamic>> createDemande(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse("${baseUrl}demandecompte/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la création de la demande");
    }
  }

  static Future<void> uploadFile(String url, File file, String token) async {
    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath('document', file.path));

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Échec de l'upload");
    }
  }
}
