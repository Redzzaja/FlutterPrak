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
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Menampilkan 2 kartu per baris
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Membuat kartu menjadi persegi
        ),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          final githubUsername = member['githubUsername']!;

          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Foto Profil
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/$githubUsername',
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Nama
                  Text(
                    member['Nama'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),

                  // NIM
                  Text(
                    member['NIM'] ?? 'No NIM',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  const SizedBox(height: 8.0),

                  // Ikon Link GitHub
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