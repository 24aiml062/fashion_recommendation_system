import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final Map<String, dynamic> weather;
  const WeatherWidget({super.key, required this.weather});

  String get _emoji {
    final cond = (weather['condition'] ?? '').toString().toLowerCase();
    if (cond.contains('rain')) return '🌧️';
    if (cond.contains('cloud')) return '⛅';
    if (cond.contains('snow')) return '❄️';
    if (cond.contains('thunder')) return '⛈️';
    return '☀️';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Text(_emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${weather['temperature']?.toStringAsFixed(0) ?? '--'}°C',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${weather['condition'] ?? 'Unknown'} · ${weather['city'] ?? ''}',
            style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
          ),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${weather['humidity'] ?? '--'}% 💧', style: const TextStyle(fontSize: 12)),
          Text('${weather['wind_speed']?.toStringAsFixed(1) ?? '--'} m/s 💨', style: const TextStyle(fontSize: 12)),
        ]),
      ]),
    );
  }
}
