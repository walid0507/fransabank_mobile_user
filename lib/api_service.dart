import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet1/configngrok.dart';



class ApiService {
  static const String clientBaseUrl = "${Config.baseApiUrl}/api/client/";
  static const String baseUrl = "${Config.baseApiUrl}/api/demandecompte/";
  static const String refreshTokenEndpoint =
      "${Config.baseApiUrl}/api/token/refresh/";

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

  // Fonction pour récupérer le solde d'un client
  static Future<double?> getSolde() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token'); // Récupérer le token
    String? clientId = prefs.getString('client_id');

    if (token == null|| clientId==null) return null;
    print("Client ID utilisé: $clientId");

final apiUrl = "${Config.baseApiUrl}/api/client/$clientId/consulter_solde_da/";
print("URL utilisée: $apiUrl");
    final response = await http.get(
      Uri.parse(
          "${Config.baseApiUrl}/api/client/$clientId/consulter_solde_da/"), // Ajuste l'URL selon ton API
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
       
        
      },
    );
    print("Code HTTP: ${response.statusCode}");
    print("Réponse: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return double.parse(data['solde_da'].toString());

    } else {
      return null; // Gérer l'erreur
    }
  }

  Future<List<dynamic>?> getComptes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      print("🔑 Token envoyé : $token");

      if (token == null) {
        throw Exception("Token non trouvé");
      }
      print("🔗 URL appelée : ${Config.baseApiUrl}/api/client/mes-comptes/");

      final response = await authenticatedRequest(
        "${Config.baseApiUrl}/api/client/mes-comptes/",
        'GET',
      );
      print(
          "🔗 URL appelée : ${response.request?.url}"); // URL finale après redirections
      print("📊 Statut HTTP : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['comptes'];
      }
      return null;
    } catch (e) {
      print("Erreur dans getComptes: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> createDemande(
      Map<String, dynamic> formData, String token) async {
    try {
      final response =
          await authenticatedRequest(baseUrl, 'POST', body: formData);

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

  static Future<void> uploadFile(String url, File file, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

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
        String? newToken = await refreshToken();
        if (newToken != null) {
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

  static Future<void> checkToken(String token) async {
    if (token == null || token.isEmpty) {
      throw Exception("Token manquant !");
    }

    final response = await http.get(
      Uri.parse('${Config.baseApiUrl}/api/protected-endpoint/'),
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

    String cleanClientId = clientId.replaceAll('Client', '').trim();
    final url = Uri.parse('${clientBaseUrl}${cleanClientId}/demande-carte/');

    try {
      print("🚀 Début de la demande de carte");
      print("📍 URL: $url");
      print("🔑 Token utilisé: $token");
      print("📦 Données envoyées: ${jsonEncode({"type_carte": typeCarte})}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({"type_carte": typeCarte}),
      );

      print("📥 Réponse reçue:");
      print("  → Code de statut: ${response.statusCode}");
      print("  → Corps: ${response.body}");
      print("  → Headers: ${response.headers}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(
              'Erreur ${response.statusCode}: ${errorBody["error"] ?? errorBody["detail"] ?? response.body}');
        } catch (e) {
          throw Exception('Erreur ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      print("❌ Erreur lors de la demande de carte: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> clientSec(
      String clientId, String password) async {
    final url = Uri.parse('${Config.baseApiUrl}/api/client/login/');

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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (data["access"] != null && data["refresh"] != null) {
          await prefs.setString("access_token", data["access"]);
          await prefs.setString("refresh_token", data["refresh"]);
          print("✅ Token et refresh_token sauvegardés !");
        }
        if (data["client_id"] != null) {
        await prefs.setString("client_id", data["client_id"]);
        print("✅ client_id sauvegardé : ${data["client_id"]}");
      }

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
      'Accept': 'application/json',
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

    if (response.statusCode == 401) {
      String? newToken = await refreshToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';

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

  static Future<Map<String, dynamic>> changePassword(
    String clientId,
    String oldPassword,
    String newPassword,
    String confirmPassword,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseApiUrl}/api/change-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      print("=== RÉPONSE DU SERVEUR ===");
      print("Code de réponse: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Une erreur est survenue');
      }
    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> effectuerVirement(
    String clientId,
    String compteDestination,
    double montant,
    String token,
    
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token'); // Récupérer le token
    String? clientId = prefs.getString('client_id');
   
    try {
      // Nettoyer l'ID du client (enlever "Client" et les espaces)
     

      final response = await http.post(
        Uri.parse('${Config.baseApiUrl}/api/client/$clientId/virement/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'comptedes': compteDestination,
          'montant': montant.toString(),
        }),
      );

      print("=== RÉPONSE DU SERVEUR ===");
      print("Code de réponse: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Une erreur est survenue');
      }
    } catch (e) {
      print('Erreur lors du virement: $e');
      rethrow;
    }
  }
}
