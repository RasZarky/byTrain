import 'package:flutter/material.dart';

class SettingsItemModel {
  final IconData icon;
  final String title;

  /// If true, this row renders a toggle switch instead of being tappable.
  final bool hasToggle;

  const SettingsItemModel({
    required this.icon,
    required this.title,
    this.hasToggle = false,
  });
}
