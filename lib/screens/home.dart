import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  final Function(List<Country>) onCountriesLoaded;
  final Function(Set<String>) onFavoritesChanged;
  final Function(String) onFavoriteToggle;
  final Set<String> favoriteCountryNames;

  const HomePage({
    super.key,
    required this.onCountriesLoaded,
    required this.onFavoritesChanged,
    required this.onFavoriteToggle,
    required this.favoriteCountryNames,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Country> _allCountries = [];
  List<Country> _displayCountries = [];
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  final int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
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
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadMoreCountries() {
    if (_isLoadingMore || _isSearching) return;
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      final currentLength = _displayCountries.length;
      final nextItems = _allCountries.skip(currentLength).take(_perPage);
      _displayCountries.addAll(nextItems);
      _isLoadingMore = false;
      if (mounted) setState(() {});
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCountries();
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        // Reset ke daftar paginasi
        _displayCountries = _allCountries.take(_displayCountries.length > _perPage ? _displayCountries.length : _perPage).toList();
      });
    } else {
      setState(() {
        _isSearching = true;
        _displayCountries = _allCountries
            .where((country) => country.name.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search country...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
        )
            : const Text('Countries'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: _displayCountries.length + (_isLoadingMore && !_isSearching ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _displayCountries.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final country = _displayCountries[i];
          final isFavorite = widget.favoriteCountryNames.contains(country.name);

          return Card(
            child: ListTile(
              leading: country.flagsPng != null
                  ? Image.network(country.flagsPng!, width: 50, errorBuilder: (c, e, s) => Icon(Icons.error))
                  : const SizedBox(width: 50),
              title: Text(country.name),
              subtitle: Text(country.region),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () => widget.onFavoriteToggle(country.name),
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
    return Country(
      name: json['name'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
      capital: json['capital'],
      flagsPng: json['flags'] != null ? json['flags']['png'] : null,
      languages: (json['languages'] as List?)
          ?.map((l) => l['name'].toString())
          .toList(),
      currencies: (json['currencies'] as List?)
          ?.map((c) => c['name'].toString())
          .toList(),
    );
  }
}