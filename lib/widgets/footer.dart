import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        'Made by Nikola Hadzic',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
