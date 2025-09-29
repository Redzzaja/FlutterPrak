import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home.dart';
import '../screens/profile.dart';
import '../screens/favorites_page.dart';

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

  List<Country> _allCountries = [];
  Set<String> _favoriteCountryNames = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _favoriteCountryNames = (prefs.getStringList('favoriteCountries') ?? []).toSet();
      });
    }
  }

  void _updateCountries(List<Country> countries) {
    if (mounted) {
      setState(() {
        _allCountries = countries;
      });
    }
  }

  void _updateFavorites(Set<String> favorites) {
    if (mounted) {
      setState(() {
        _favoriteCountryNames = favorites;
      });
    }
  }

  Future<void> _toggleFavorite(String countryName) async {
    final prefs = await SharedPreferences.getInstance();

    final currentFavorites = _favoriteCountryNames.toSet();

    if (currentFavorites.contains(countryName)) {
      currentFavorites.remove(countryName);
    } else {
      currentFavorites.add(countryName);
    }

    await prefs.setStringList('favoriteCountries', currentFavorites.toList());
    _updateFavorites(currentFavorites);
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
        onFavoriteToggle: _toggleFavorite,
        favoriteCountryNames: _favoriteCountryNames,
      ),
      FavoritesPage(
        allCountries: _allCountries,
        favoriteCountryNames: _favoriteCountryNames,
        onFavoriteToggle: _toggleFavorite,
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
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}