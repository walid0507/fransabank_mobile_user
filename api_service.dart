import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Remplacer par votre URL ngrok actuelle
  final String baseUrl = 'https://0376-105-100-44-252.ngrok-free.app';

  // Si vous utilisez l'émulateur Android :
  // final String baseUrl =
  //     'http://10.0.2.2:8000'; // 10.0.2.2 est l'équivalent de localhost pour l'émulateur Android

  // OU si vous utilisez un appareil physique :
  // final String baseUrl = 'http://192.168.1.XX:8000';  // Remplacez XX par votre adresse IP locale

  // OU si vous utilisez iOS Simulator :
  // final String baseUrl = 'http://localhost:8000';

  Future<List<dynamic>?> getComptes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Non authentifié');
    }

    try {
      print('URL appelée: $baseUrl/api/mes-comptes'); // Notez l'ajout de /api/
      final response = await http.get(
        Uri.parse('$baseUrl/api/mes-comptes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '1', // Important pour ngrok
        },
      );

      // Ajout de logs pour déboguer
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse.containsKey('comptes')) {
            return jsonResponse['comptes'] as List<dynamic>;
          } else {
            print('Structure de réponse inattendue: $jsonResponse');
            throw Exception('Structure de réponse invalide');
          }
        } catch (e) {
          print('Erreur de décodage JSON: ${response.body}');
          throw FormatException(
              'La réponse du serveur n\'est pas au format JSON valide');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Échec du chargement des comptes. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête: $e');
      rethrow;
    }
  }
}
