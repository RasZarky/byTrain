import 'package:by_train/features/onboarding/domain/onboarding_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        final scale = 0.88 + (progress * 0.12);
        final imageOffset = clamped * 60;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: progress.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(imageOffset, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: page.imageUrl,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 250),
                              placeholder: (context, url) => Container(
                                color: page.color.withValues(alpha: 0.08),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: page.color.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      page.color.withValues(alpha: 0.18),
                                      page.color.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    page.icon,
                                    size: 56,
                                    color: page.color,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    page.color.withValues(alpha: 0.0),
                                    page.color.withValues(alpha: 0.18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Opacity(
                opacity: progress.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - progress) * 16),
                  child: Column(
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF5F5E5A),
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