import 'package:by_train/features/onboarding/domain/onboarding_model.dart';
import 'package:flutter/material.dart';

class OnboardingWidget extends StatelessWidget {
  final OnboardingModel page;

  const OnboardingWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(page.icon, size: 44),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF5F5E5A),
            ),
          ),
        ],
      ),
    );
  }
}
