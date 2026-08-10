import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';
import 'widgets/animated_section.dart';
import 'widgets/section_header.dart';
import 'widgets/setting_tile.dart';
import 'widgets/settings_divider.dart';
import 'widgets/version_badge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern Collapsing AppBar for a premium look
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: AppDimensions.m, bottom: 16),
              centerTitle: false,
              title: Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.05),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppDimensions.m, 0, AppDimensions.m, AppDimensions.xxl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SectionHeader(title: 'Support & Legal'),
                AnimatedSection(
                  index: 2,
                  child: CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SettingTile(
                          icon: Icons.info_rounded,
                          title: 'About ByTrain',
                          subtitle: 'Version, licenses and team info',
                          onTap: () => context.push('/settings/about'),
                        ),
                        const SettingsDivider(),
                        const SettingTile(
                          icon: Icons.help_center_rounded,
                          title: 'Help Center',
                          subtitle: 'FAQs and contact support',
                        ),
                        const SettingsDivider(),
                        const SettingTile(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'How we handle your data',
                        ),
                        const SettingsDivider(),
                        const SettingTile(
                          icon: Icons.description_rounded,
                          title: 'Terms of Service',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.xl),
                
                const VersionBadge(),

                const SizedBox(height: AppDimensions.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
