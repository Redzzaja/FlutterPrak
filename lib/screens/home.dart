import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  final Function(List<Country>) onCountriesLoaded;
  final Function(Set<String>) onFavoritesChanged;

  const HomePage({
    super.key,
    required this.onCountriesLoaded,
    required this.onFavoritesChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Country> _allCountries = [];
  final List<Country> _displayCountries = [];
  Set<String> _favoriteCountryNames = {};
  final _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  final int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadCountries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndLoadCountries() async {
    await _loadFavorites();
    try {
      final uri = Uri.parse('https://www.apicountries.com/countries');
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final respBody = await response.transform(utf8.decoder).join();
        final List<dynamic> jsonData = jsonDecode(respBody);
        _allCountries.addAll(jsonData.map((j) => Country.fromJson(j)).toList());
        widget.onCountriesLoaded(_allCountries);
        _loadMoreCountries();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadMoreCountries() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulasi jeda jaringan
    Future.delayed(const Duration(milliseconds: 500), () {
      final currentLength = _displayCountries.length;
      final nextItems = _allCountries.skip(currentLength).take(_perPage);
      _displayCountries.addAll(nextItems);
      _isLoadingMore = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCountries();
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteCountries') ?? [];
    if (mounted) {
      setState(() {
        _favoriteCountryNames = favorites.toSet();
        widget.onFavoritesChanged(_favoriteCountryNames);
      });
    }
  }

  Future<void> _toggleFavorite(String countryName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteCountryNames.contains(countryName)) {
        _favoriteCountryNames.remove(countryName);
      } else {
        _favoriteCountryNames.add(countryName);
      }
      prefs.setStringList('favoriteCountries', _favoriteCountryNames.toList());
      widget.onFavoritesChanged(_favoriteCountryNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: _displayCountries.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _displayCountries.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final country = _displayCountries[i];
          final isFavorite = _favoriteCountryNames.contains(country.name);

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
                onPressed: () => _toggleFavorite(country.name),
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

class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final List<String>? languages;
  final List<String>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<String>? langs;
    if (json['languages'] != null) {
      langs = (json['languages'] as List)
          .map((l) => l['name'].toString())
          .toList();
    }
    List<String>? cur;
    if (json['currencies'] != null) {
      cur = (json['currencies'] as List)
          .map((c) => c['name'].toString())
          .toList();
    }
    return Country(
      name: json['name'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
      capital: json['capital'],
      flagsPng: json['flags'] != null ? json['flags']['png'] : null,
      languages: langs,
      currencies: cur,
    );
  }
}