import 'package:flutter/material.dart';

class OnboardingModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}