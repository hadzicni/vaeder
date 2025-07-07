import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vaeder/models/weather_model.dart';
import 'package:vaeder/services/weather_service.dart';

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
  bool _isLoading = true;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchWeather();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);

      if (mounted) {
        setState(() {
          _currentLocationCity = cityName;
          _weather = weather;
          _isLoading = false;
        });

        if (_slideController.isAnimating) _slideController.stop();
        if (_fadeController.isAnimating) _fadeController.stop();

        _slideController.forward();
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching weather data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchWeatherForCity(String city) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherService.getWeather(city);

      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoading = false;
        });

        if (_slideController.isAnimating) _slideController.stop();
        if (_fadeController.isAnimating) _fadeController.stop();

        _slideController.forward();
        _fadeController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${_capitalizeWords(city)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching weather data'),
            backgroundColor: Colors.red,
          ),
        );
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

  Future<void> _showCityInputDialog() async {
    String? cityName;
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change City',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter city name',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                    filled: true,
                    fillColor: Colors.white.withAlpha(13),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                    ),
                  ),
                  onChanged: (value) => cityName = value,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white.withAlpha(179)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (cityName != null && cityName!.trim().isNotEmpty) {
                          _slideController.reset();
                          _fadeController.reset();
                          _fetchWeatherForCity(cityName!.trim());
                        }
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  Color getWeatherColor(String? mainCondition) {
    if (mainCondition == null) return const Color(0xFF87CEEB);
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return const Color(0xFF6B7280);
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return const Color(0xFF4A5568);
      case 'thunderstorm':
        return const Color(0xFF2D3748);
      case 'clear':
        return const Color(0xFF87CEEB);
      default:
        return const Color(0xFF87CEEB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showCityInputDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _weather == null
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [
                    getWeatherColor(_weather?.mainCondition).withAlpha(204),
                    const Color(0xFF0F172A),
                  ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingWidget()
              : _weather == null
              ? _buildErrorWidget()
              : _buildWeatherContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading weather...',
            style: TextStyle(color: Colors.white.withAlpha(179)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withAlpha(179),
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            'Failed to load weather data',
            style: TextStyle(color: Colors.white.withAlpha(179)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            _slideController.reset();
            _fadeController.reset();
            await _fetchWeather();
          },
          backgroundColor: const Color(0xFF1E293B),
          color: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildWeatherAnimation(),
                const SizedBox(height: 40),
                _buildTemperatureCard(),
                const SizedBox(height: 40),
                _buildWeatherDetails(),
                const SizedBox(height: 40),
                if (_currentLocationCity != null &&
                    _weather?.cityName.trim().toLowerCase() !=
                        _currentLocationCity!.trim().toLowerCase()) ...[
                  _buildResetToCurrentLocationButton(),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Made by Nikola Hadzic',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(128),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetToCurrentLocationButton() {
    return GestureDetector(
      onTap: () {
        _slideController.reset();
        _fadeController.reset();
        _fetchWeather();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withAlpha(77), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.my_location,
              color: Colors.white.withAlpha(204),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Use current location',
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(51), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: Colors.white.withAlpha(230),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _weather!.cityName.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAnimation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Lottie.asset(
        getWeatherAnimation(_weather?.mainCondition),
        width: 200,
        height: 200,
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${_weather!.temperature.round()}°',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _weather!.mainCondition.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailItem(
            icon: Icons.thermostat_rounded,
            label: 'FEELS LIKE',
            value: '${(_weather!.temperature + 2).round()}°',
          ),
          Container(width: 1, height: 40, color: Colors.white.withAlpha(51)),
          _buildDetailItem(
            icon: Icons.air_rounded,
            label: 'CONDITION',
            value: _weather!.mainCondition.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withAlpha(179), size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withAlpha(153),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(230),
          ),
        ),
      ],
    );
  }
}
