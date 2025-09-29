import 'package:flutter/material.dart';
import 'home.dart'; // Impor class Country
import 'detail.dart';

class FavoritesPage extends StatelessWidget {
  final List<Country> allCountries;
  final Set<String> favoriteCountryNames;
  final Function(String) onFavoriteToggle;

  const FavoritesPage({
    super.key,
    required this.allCountries,
    required this.favoriteCountryNames,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Filter negara yang hanya ada di daftar favorit
    final favoriteCountries = allCountries
        .where((country) => favoriteCountryNames.contains(country.name))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Countries'),
      ),
      body: favoriteCountries.isEmpty
          ? const Center(
        child: Text('No favorite countries yet.'),
      )
          : ListView.builder(
        itemCount: favoriteCountries.length,
        itemBuilder: (context, i) {
          final country = favoriteCountries[i];
          final isFavorite = favoriteCountryNames.contains(country.name);

          return Card(
            child: ListTile(
              leading: country.flagsPng != null
                  ? Image.network(country.flagsPng!, width: 50)
                  : const SizedBox(width: 50),
              title: Text(country.name),
              subtitle: Text(country.region),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  onFavoriteToggle(country.name);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(country: country),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}