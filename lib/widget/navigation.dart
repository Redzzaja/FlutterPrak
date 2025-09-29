import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/profile.dart';
import '../screens/favorites_page.dart'; // Impor halaman favorit

class NavigationPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  const NavigationPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // State untuk data yang akan dibagikan antar halaman
  List<Country> _allCountries = [];
  Set<String> _favoriteCountryNames = {};

  void _updateCountries(List<Country> countries) {
    setState(() {
      _allCountries = countries;
    });
  }

  void _updateFavorites(Set<String> favorites) {
    setState(() {
      _favoriteCountryNames = favorites;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onCountriesLoaded: _updateCountries,
        onFavoritesChanged: _updateFavorites,
      ),
      FavoritesPage(
        allCountries: _allCountries,
        favoriteCountryNames: _favoriteCountryNames,
        onFavoriteToggle: (String countryName) {
          // Logika ini perlu di-pass dari HomePage, untuk sementara kosong
        },
      ),
      ProfilePage(
        onHomeTap: () => _onTabTapped(0),
        onThemeChanged: widget.onThemeChanged,
        isDarkMode: widget.isDarkMode,
      ),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'), // Tab baru
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}