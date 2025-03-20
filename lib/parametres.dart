import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun
import 'package:projet1/configngrok.dart';

class ParametresScreen extends StatefulWidget {
  @override
  _ParametresScreenState createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _notificationsEnabled = true;
  double _textSize = 1.0;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Automatique';
  int _appUsageTime = 75; // Simulé : Temps passé sur l'application en minutes

  final List<String> _languages = [
    'Français',
    'Anglais',
    'Espagnol',
    'Allemand',
    'Italien',
    'Arabe',
  ];
  final List<String> _themes = ['Clair', 'Sombre', 'Automatique'];

  @override
  Widget build(BuildContext context) {
    return CommonHeader(
      title: 'Paramètres',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 50),
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications de l\'application',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Langue de l\'application',
                value: _selectedLanguage,
                items: _languages,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
              _buildDropdownTile(
                icon: Icons.color_lens,
                title: 'Thème de l\'application',
                value: _selectedTheme,
                items: _themes,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
              _buildSliderTile(
                icon: Icons.text_fields,
                title: 'Taille et style du texte',
                value: _textSize,
                onChanged: (value) {
                  setState(() {
                    _textSize = value;
                  });
                },
              ),
              _buildSettingsItem(
                  Icons.security, "Permissions de l'application"),
              _buildInfoTile(
                icon: Icons.bar_chart,
                title: 'Statistiques d\'utilisation',
                value: '$_appUsageTime minutes aujourd\'hui',
              ),
              _buildSettingsItem(Icons.delete, "Vider le cache"),
              _buildSettingsItem(Icons.info, "Informations sur l’application"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {
        // Ajouter la navigation vers les pages correspondantes ici
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.blue),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: DropdownButton<String>(
        value: value,
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required Function(double) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: 0.5,
        max: 1.5,
        divisions: 5,
        label: '${(value * 100).toInt()}%',
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: Colors.black54)),
    );
  }
}
