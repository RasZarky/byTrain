import 'package:by_train/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _lineWidth;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _markOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
    ));

    _wordmarkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.6, curve: Curves.easeIn),
    );

    _lineWidth = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _startNavigation();
  }

  void _startNavigation() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) context.go('/onboarding');
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
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                FadeTransition(
                  opacity: _markOpacity,
                  child: Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    child: Image.asset("assets/images/logo.png"),
                  ),
                ),

                const SizedBox(height: 28),

                SlideTransition(
                  position: _wordmarkSlide,
                  child: FadeTransition(
                    opacity: _wordmarkOpacity,
                    child: Text(
                      'ByTrain',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _wordmarkOpacity,
                  child: Text(
                    'City rail, mapped simply',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                AnimatedBuilder(
                  animation: _lineWidth,
                  builder: (context, _) => Container(
                    width: 150 * _lineWidth.value,
                    height: 5,
                    color: AppColors.primary,
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