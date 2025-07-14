import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaeder/models/weather_model.dart';
import 'package:vaeder/services/weather_service.dart';

import '../utils/weather_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/error_display.dart';
import '../widgets/footer.dart';
import '../widgets/forecast_button.dart';
import '../widgets/header.dart';
import '../widgets/loading_widget.dart';
import '../widgets/reset_location_button.dart';
import '../widgets/temperature_card.dart';
import '../widgets/weather_animation.dart';
import '../widgets/weather_details.dart';
import '../widgets/uv_index_tile.dart';
import 'forecast_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with TickerProviderStateMixin {
  final _weatherService = WeatherService('0bd21cf6023274a9818128f4eb1f4c79');
  Weather? _weather;
  String? _currentLocationCity;
  Map<String, String> _favoriteCities = {};
  String _units = 'metric';
  double? _uvIndex;
  bool _isLoading = true;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUnits();
    _loadFavorites();
    _fetchWeather();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutExpo),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName, units: _units);
      final uv = await _weatherService.getUvIndex(cityName);

      if (mounted) {
        setState(() {
          _currentLocationCity = cityName;
          _weather = weather;
          _uvIndex = uv;
          _isLoading = false;
        });

        _startAnimations();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error fetching weather data');
      }
    }
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _resetAnimations() {
    _slideController.reset();
    _fadeController.reset();
    _scaleController.reset();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('favoriteCities') ?? [];
    final map = <String, String>{};
    for (final entry in stored) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        map[parts[0]] = parts[1]; // city → country
      }
    }
    setState(() => _favoriteCities = map);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favoriteCities.entries
        .map((e) => '${e.key}|${e.value}')
        .toList();
    await prefs.setStringList('favoriteCities', list);
  }

  Future<void> _loadUnits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _units = prefs.getString('units') ?? 'metric';
    });
  }

  Future<void> _saveUnits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('units', _units);
  }

  Future<void> _toggleFavorite() async {
    if (_weather == null) return;
    final city = _weather!.cityName;
    final country = _weather!.country;

    setState(() {
      if (_favoriteCities.containsKey(city)) {
        _favoriteCities.remove(city);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $city from favorites'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        _favoriteCities[city] = country;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $city to favorites'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
    await _saveFavorites();
  }

  Future<void> _toggleUnitsSetting() async {
    setState(() {
      _units = _units == 'metric' ? 'imperial' : 'metric';
    });
    await _saveUnits();
    if (_weather != null) {
      await _fetchWeatherForCity(_weather!.cityName);
    } else {
      await _fetchWeather();
    }
  }

  void _openForecastPage() {
    if (_weather != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForecastPage(
            city: _weather!.cityName,
            units: _units,
            backgroundColors: _getBackgroundColors(),
          ),
        ),
      );
    }
  }

  void _showFavoritesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_favoriteCities.isEmpty)
                Text(
                  'No favorites added',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                )
              else
                ..._favoriteCities.entries.map((entry) {
                  final city = entry.key;
                  final country = entry.value;
                  return Dismissible(
                    key: ValueKey(city),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      setState(() => _favoriteCities.remove(city));
                      _saveFavorites();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed $city from favorites'),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        '$city, $country',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _fetchWeatherForCity(city);
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'VAEDER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Developer: Nikola Hadzic',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Powered by OpenWeatherMap',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchWeatherForCity(String city) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherService.getWeather(city, units: _units);
      final uv = await _weatherService.getUvIndex(city);

      if (mounted) {
        setState(() {
          _weather = weather;
          _uvIndex = uv;
          _isLoading = false;
        });

        _resetAnimations();
        _startAnimations();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${_capitalizeWords(city)}'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('City not found');
      }
    }
  }

  String _capitalizeWords(String input) {
    return input
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  void _showCityInputBottomSheet() {
    final controller = TextEditingController();
    bool isValid = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter city name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g. New York',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isValid = value.trim().isNotEmpty;
                        });
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          Navigator.pop(context);
                          _fetchWeatherForCity(value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () {
                                Navigator.pop(context);
                                _fetchWeatherForCity(controller.text.trim());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E293B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isLoading
          ? null
          : CustomAppBar(
              onSearchTap: _showCityInputBottomSheet,
              onToggleFavorite: _toggleFavorite,
              onShowFavorites: _showFavoritesSheet,
              onToggleUnits: _toggleUnitsSetting,
              onShowAbout: _showAboutDialog,
              onOpenForecast: _openForecastPage,
              isFavorite:
                  _weather != null &&
                  _favoriteCities.containsKey(_weather!.cityName),
              favoriteCities: _favoriteCities,
            ),

      body: _isLoading
          ? Container(
              color: const Color(0xFF0F172A),
              alignment: Alignment.center,
              child: const LoadingWidget(),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getBackgroundColors(),
                ),
              ),
              child: SafeArea(
                child: _weather == null
                    ? _buildErrorWidget()
                    : _buildWeatherContent(),
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return ErrorDisplay(onRetry: _fetchWeather);
  }

  Widget _buildWeatherContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            _resetAnimations();
            await _fetchWeather();
          },
          backgroundColor: Colors.white.withOpacity(0.2),
          color: Colors.white,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildWeatherAnimation(),
                const SizedBox(height: 32),
                _buildTemperatureCard(),
                const SizedBox(height: 24),
                _buildWeatherDetails(),
                if (_uvIndex != null) ...[
                  const SizedBox(height: 24),
                  _buildUvIndexTile(),
                ],
                const SizedBox(height: 24),
                ForecastButton(onTap: _openForecastPage),
                const SizedBox(height: 32),
                if (_currentLocationCity != null &&
                    _weather?.cityName.trim().toLowerCase() !=
                        _currentLocationCity!.trim().toLowerCase()) ...[
                  _buildResetToCurrentLocationButton(),
                  const SizedBox(height: 24),
                ],
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Header(weather: _weather!),
    );
  }

  Widget _buildWeatherAnimation() {
    return WeatherAnimation(condition: _weather?.mainCondition);
  }

  Widget _buildTemperatureCard() {
    return TemperatureCard(
      temperature: _weather!.temperature,
      unitSymbol: _units == 'metric' ? 'C' : 'F',
    );
  }

  Widget _buildWeatherDetails() {
    return WeatherDetails(
      feelsLike: _weather!.temperature + 2,
      condition: _weather!.mainCondition,
      unitSymbol: _units == 'metric' ? 'C' : 'F',
    );
  }

  Widget _buildUvIndexTile() {
    return UvIndexTile(uvIndex: _uvIndex ?? 0);
  }

  Widget _buildResetToCurrentLocationButton() {
    return ResetLocationButton(
      onTap: () {
        _resetAnimations();
        _fetchWeather();
      },
    );
  }

  Widget _buildFooter() {
    return const Footer();
  }

  List<Color> _getBackgroundColors() {
    if (_weather == null) {
      return [const Color(0xFF0F172A), const Color(0xFF1E293B)];
    }
    return [
      ...getWeatherGradient(_weather!.mainCondition),
      const Color(0xFF0F172A),
    ];
  }
}
