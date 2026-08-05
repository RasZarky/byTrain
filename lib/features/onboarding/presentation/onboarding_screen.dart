
import 'package:by_train/features/onboarding/domain/onboarding_model.dart';
import 'package:by_train/features/onboarding/presentation/widgets/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _accent = Color(0xFF378ADD);

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      icon: Icons.train_outlined,
      title: 'Book train tickets in seconds',
      subtitle: 'Search routes, compare fares, and book instantly.',
    ),
    OnboardingModel(
      icon: Icons.map_outlined,
      title: 'Live routes and platforms',
      subtitle: 'Real-time updates on delays, gates, and connections.',
    ),
    OnboardingModel(
      icon: Icons.confirmation_number_outlined,
      title: 'Tickets in your pocket',
      subtitle: 'Skip the counter with mobile tickets and QR boarding.',
    ),
    OnboardingModel(
      icon: Icons.notifications_outlined,
      title: 'Never miss a departure',
      subtitle: 'Get alerts for delays, platform changes, and boarding time.',
    ),
    OnboardingModel(
      icon: Icons.rocket_launch_outlined,
      title: 'Ready to ride',
      subtitle: 'Create an account to start booking your journeys.',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _next() {
    if (_isLastPage) {
      context.go('/home');
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _skip() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: _isLastPage
                    ? const SizedBox(height: 20)
                    : TextButton(
                        onPressed: _skip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: _accent, fontSize: 14),
                        ),
                      ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingWidget(page: page);
                },
              ),
            ),

            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final active = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? _accent : const Color(0xFFB4B2A9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            // CTA buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isLastPage ? 'Get started' : 'Next',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
