import 'package:by_train/core/data/onboarding_store.dart';
import 'package:by_train/features/onboarding/domain/onboarding_model.dart';
import 'package:by_train/features/onboarding/presentation/widgets/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late final AnimationController _entrance;
  late final Animation<double> _entranceFade;

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      icon: Icons.train_outlined,
      title: 'Book train tickets in seconds',
      subtitle: 'Search routes, compare fares, and book instantly.',
      color: Color(0xFF378ADD),
    ),
    OnboardingModel(
      icon: Icons.map_outlined,
      title: 'Live routes and platforms',
      subtitle: 'Real-time updates on delays, gates, and connections.',
      color: Color(0xFF2FAE8B),
    ),
    OnboardingModel(
      icon: Icons.confirmation_number_outlined,
      title: 'Tickets in your pocket',
      subtitle: 'Skip the counter with mobile tickets and QR boarding.',
      color: Color(0xFFE08A3C),
    ),
    OnboardingModel(
      icon: Icons.notifications_outlined,
      title: 'Never miss a departure',
      subtitle: 'Get alerts for delays, platform changes, and boarding time.',
      color: Color(0xFFD1495B),
    ),
    OnboardingModel(
      icon: Icons.rocket_launch_outlined,
      title: 'Ready to ride',
      subtitle: 'No account needed start booking your journeys.',
      color: Color(0xFF7A5CD6),
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;
  Color get _accent => _pages[_currentPage].color;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _entranceFade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
  }

  void _next() {
    if (_isLastPage) {
      OnboardingStore().markCompleted();
      context.go('/home');
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _accent.withValues(alpha: 0.06),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _entranceFade,
            child: Column(
              children: [
                // Skip button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _isLastPage ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _isLastPage,
                        child: TextButton(
                          onPressed: _skip,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(color: _accent, fontSize: 14),
                            child: const Text('Skip'),
                          ),
                        ),
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
                      return OnboardingWidget(
                        page: _pages[index],
                        controller: _controller,
                        index: index,
                      );
                    },
                  ),
                ),

                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final active = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? _accent : const Color(0xFFB4B2A9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                // CTA button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _next,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                    opacity: anim,
                                    child: ScaleTransition(
                                      scale: anim,
                                      child: child,
                                    ),
                                  ),
                              child: Row(
                                key: ValueKey(_isLastPage),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isLastPage ? 'Get started' : 'Next',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    _isLastPage
                                        ? Icons.rocket_launch_outlined
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
