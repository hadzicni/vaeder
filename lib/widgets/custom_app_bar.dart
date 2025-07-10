import 'dart:ui';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShowFavorites;
  final VoidCallback onToggleUnits;
  final VoidCallback onShowAbout;
  final VoidCallback onOpenForecast;
  final bool isFavorite;

  const CustomAppBar({
    super.key,
    required this.onSearchTap,
    required this.onToggleFavorite,
    required this.onShowFavorites,
    required this.onToggleUnits,
    required this.onShowAbout,
    required this.onOpenForecast,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: TextButton.icon(
            onPressed: onSearchTap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.search, size: 20),
            label: const Text(
              'Search location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),

      actions: [
        IconButton(
          onPressed: onToggleFavorite,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        IconButton(
          onPressed: onShowFavorites,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.list, color: Colors.white, size: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            color: Colors.transparent,
            elevation: 0,
            offset: const Offset(0, 40),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
            onSelected: (value) {
              if (value == 'forecast') onOpenForecast();
              if (value == 'about') onShowAbout();
              if (value == 'units') onToggleUnits();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'forecast',
                padding: EdgeInsets.zero,
                child: _buildMenuItem(Icons.calendar_today, 'Forecast'),
              ),
              PopupMenuItem<String>(
                value: 'about',
                padding: EdgeInsets.zero,
                child: _buildMenuItem(Icons.info_outline, 'About'),
              ),
              PopupMenuItem<String>(
                value: 'units',
                padding: EdgeInsets.zero,
                child: _buildMenuItem(Icons.thermostat, 'Change Units'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.9)),
        title: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
