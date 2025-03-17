import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String clientBaseUrl =
      "https://05e3-105-235-131-236.ngrok-free.app/api/client/";

  static const String baseUrl =
      "https://05e3-105-235-131-236.ngrok-free.app/api/demandecompte/"; // Remplacez par l'URL de votre API

  static const String refreshTokenEndpoint =
      "https://05e3-105-235-131-236.ngrok-free.app/api/token/refresh/";

  static Future<String?> refreshToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        print("⚠️ Refresh token non trouvé dans SharedPreferences !");
        return null;
      }

      final response = await http.post(
        Uri.parse(refreshTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['access'];

        // Sauvegarder le nouveau token
        await prefs.setString('access_token', newToken);
        print("✅ Nouveau token sauvegardé avec succès");
        return newToken;
      } else {
        print("❌ Échec du rafraîchissement du token : ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erreur lors du rafraîchissement du token: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> createDemande(
      Map<String, dynamic> formData, String token) async {
    try {
      final response = await authenticatedRequest(
        baseUrl,
        'POST',
        body: formData,
      );

      print("Code réponse: ${response.statusCode}");
      print("Réponse : ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("Erreur lors de la création de la demande: $e");
      throw e;
    }
  }

  // Méthode pour uploader des fichiers (photo, signature)
  static Future<void> uploadFile(String url, File file, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Obtenir le token actuel ou rafraîchi
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentToken = prefs.getString('token');

      if (currentToken == null) {
        throw Exception("Token manquant !");
      }

      request.headers['Authorization'] = 'Bearer $currentToken';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        // Si le token est expiré, essayer de le rafraîchir
        String? newToken = await refreshToken();
        if (newToken != null) {
          // Réessayer avec le nouveau token
          request = http.MultipartRequest('POST', Uri.parse(url));
          request.headers['Authorization'] = 'Bearer $newToken';
          request.files
              .add(await http.MultipartFile.fromPath('file', file.path));
          streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        }
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Échec de l\'upload du fichier. Code: ${response.statusCode}, Message: ${response.body}');
      }
    } catch (e) {
      print("Erreur lors de l'upload du fichier: $e");
      throw e;
    }
  }

  // Vérifier si le token est valide
  static Future<void> checkToken(String token) async {
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant !");
    }

    final response = await http.get(
      Uri.parse(
          'https://05e3-105-235-131-236.ngrok-free.app/api/protected-endpoint/'), // Un endpoint nécessitant un token
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

    final url = Uri.parse(
        'https://05e3-105-235-131-236.ngrok-free.app/api/client/demande-carte/');

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
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception('Erreur ${response.statusCode}: ${errorBody["error"]}');
      } catch (e) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    }
  }

  // 🔑 Fonction pour la connexion et récupération du client_id
  static Future<Map<String, dynamic>> clientSec(
      String clientId, String password) async {
    final url = Uri.parse(
        'https://05e3-105-235-131-236.ngrok-free.app/api/client/login/');

    try {
      print("=== DÉBUT DE LA CONNEXION ===");
      print("Tentative de connexion avec client_id: $clientId");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"client_id": clientId, "password": password}),
      );

      print("=== RÉPONSE DU SERVEUR ===");
      print("Code de réponse: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("\n=== DONNÉES DÉCODÉES ===");
        print(data);

        // Stocker les tokens et le client_id
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (data["token"] != null) {
          await prefs.setString("access_token", data["token"]);
          print("\n=== TOKEN SAUVEGARDÉ (format token) ===");
          print(data["token"]);
        } else if (data["access"] != null) {
          await prefs.setString("access_token", data["access"]);
          await prefs.setString("refresh_token", data["refresh"]);
          print("\n=== TOKEN SAUVEGARDÉ (format access) ===");
          print(data["access"]);
        }

        // Vérification
        String? savedToken = await prefs.getString('access_token');
        print("\n=== VÉRIFICATION DU TOKEN SAUVEGARDÉ ===");
        print("Token récupéré: $savedToken");
        print("=== FIN DE LA CONNEXION ===\n");

        return data;
      } else {
        print("\n=== ERREUR DE CONNEXION ===");
        print("Status: ${response.statusCode}");
        print("Message: ${response.body}");
        return {"error": "Identifiant ou mot de passe incorrect."};
      }
    } catch (e) {
      print("\n=== ERREUR INATTENDUE ===");
      print(e.toString());
      return {"error": "Erreur de connexion: ${e.toString()}"};
    }
  }

  static Future<http.Response> authenticatedRequest(String url, String method,
      {Map<String, dynamic>? body,
      Map<String, String>? additionalHeaders}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Token non trouvé');
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    http.Response response;

    if (method.toUpperCase() == 'GET') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else if (method.toUpperCase() == 'POST') {
      response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    } else {
      throw Exception('Méthode HTTP non supportée');
    }

    // Si le token est expiré (401), essayer de le rafraîchir
    if (response.statusCode == 401) {
      String? newToken = await refreshToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';

        // Réessayer la requête avec le nouveau token
        if (method.toUpperCase() == 'GET') {
          response = await http.get(Uri.parse(url), headers: headers);
        } else if (method.toUpperCase() == 'POST') {
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        }
      }
    }

    return response;
  }
}
