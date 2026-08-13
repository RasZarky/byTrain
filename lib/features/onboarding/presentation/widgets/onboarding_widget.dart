import 'package:by_train/features/onboarding/domain/onboarding_model.dart';
import 'package:flutter/material.dart';

class OnboardingWidget extends StatelessWidget {
  final OnboardingModel page;
  final PageController controller;
  final int index;

  const OnboardingWidget({
    super.key,
    required this.page,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double t;
        if (controller.hasClients && controller.position.haveDimensions) {
          t = (controller.page ?? controller.initialPage.toDouble()) - index;
        } else {
          t = (controller.initialPage - index).toDouble();
        }
        final clamped = t.clamp(-1.0, 1.0);
        final progress = 1 - clamped.abs();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image/Icon section removed as requested
              Opacity(
                opacity: progress.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - progress) * 20),
                  child: Column(
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
