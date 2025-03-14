import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String clientBaseUrl =
      "https://e564-197-204-252-224.ngrok-free.app/api/client/";

  static const String baseUrl =
      "https://e564-197-204-252-224.ngrok-free.app/api/demandecompte/"; // Remplacez par l'URL de votre API

  static Future<Map<String, dynamic>> createDemande(
      Map<String, dynamic> formData, String token) async {
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant !");
    }

    print("Token utilisé : $token");
    print("En-têtes envoyés: ${{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }}");

    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(formData),
    );

    print("Code réponse: ${response.statusCode}");
    print("Réponse : ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  // Méthode pour uploader des fichiers (photo, signature)
  static Future<void> uploadFile(String url, File file, String token) async {
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant !");
    }

    print("Token utilisé pour l'upload : $token");

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    print("Code réponse upload: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception(
          'Échec de l\'upload du fichier. Code: ${response.statusCode}');
    }
  }

  // Vérifier si le token est valide
  static Future<void> checkToken(String token) async {
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant !");
    }

    final response = await http.get(
      Uri.parse(
          'https://e564-197-204-252-224.ngrok-free.app/api/protected-endpoint/'), // Un endpoint nécessitant un token
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Le token est valide ✅");
    } else {
      print("Token invalide ❌ : ${response.statusCode} - ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> demanderCarte(
      String clientId, String typeCarte, String token) async {
    if (token.isEmpty) {
      throw Exception("Token manquant !");
    }

    final url = Uri.parse('$clientBaseUrl$clientId/demande-carte/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"type_carte": typeCarte}),
    );

    print("Code réponse: ${response.statusCode}");
    print("Réponse API: ${response.body}");

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Erreur ${response.statusCode}: ${jsonDecode(response.body)["error"] ?? response.body}');
    }
  }
}
