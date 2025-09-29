import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const ProfilePage({
    super.key,
    this.onHomeTap,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, String>> teamMembers = [
    {
      'Nama': 'justi a',
      'NIM': '21120122120018',
      'githubUsername': 'Justinadva'
    },
    {
      'Nama': 'Muhammad Arif Maulana',
      'NIM': '21120123130111',
      'githubUsername': 'RedzzAja'
    },
    {
      'Nama': 'Althaf',
      'NIM': '21120123149000',
      'githubUsername': 'Althaftaa'
    },
    {
      'Nama': 'Dimas',
      'NIM': '21120123150009',
      'githubUsername': 'dimasagussaputra'
    },
  ];

  Future<void> _launchURL(String username) async {
    final Uri url = Uri.parse('https://github.com/$username');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Kelompok'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: widget.onHomeTap,
          ),
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          final githubUsername = member['githubUsername']!;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/$githubUsername',
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['Nama'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          member['NIM'] ?? 'No NIM',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: () => _launchURL(githubUsername),
                    tooltip: 'Kunjungi Profil GitHub',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}