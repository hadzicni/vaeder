import 'package:flutter/material.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../widgets/loading_widget.dart';
import '../utils/weather_utils.dart';

class ForecastPage extends StatefulWidget {
  final String city;
  final String units;

  const ForecastPage({super.key, required this.city, required this.units});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  final _weatherService = WeatherService('0bd21cf6023274a9818128f4eb1f4c79');
  List<ForecastDay> _forecast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      final data = await _weatherService.getForecast(widget.city, units: widget.units);
      if (mounted) {
        setState(() {
          _forecast = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ForecastPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city || oldWidget.units != widget.units) {
      setState(() {
        _isLoading = true;
        _forecast = [];
      });
      _loadForecast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast for ${widget.city}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _forecast.isEmpty
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [
                    ...getWeatherGradient(_forecast.first.mainCondition),
                    const Color(0xFF0F172A),
                  ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const LoadingWidget()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _forecast.length,
                  itemBuilder: (context, index) {
                    final day = _forecast[index];
                    final symbol = widget.units == 'metric' ? 'C' : 'F';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${day.date.month}/${day.date.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '${day.temperature.round()}°$symbol',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            day.mainCondition,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
