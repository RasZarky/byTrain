import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';
import 'widgets/animated_section.dart';
import 'widgets/developer_card.dart';
import 'widgets/info_tile.dart';
import 'widgets/section_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Collapsing Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'About ByTrain',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.m),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 60,
                          width: 60,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.train_rounded,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.m),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedSection(
                  index: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Train Timing Tracker',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Version 1.0.0',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                const SectionHeader(title: 'Development Team'),
                AnimatedSection(
                  index: 1,
                  child: Column(
                    children: [
                      DeveloperCard(
                        name: 'Abdul Razak Abubakari',
                        role: 'Mobile Developer',
                        email: 'ubdoolrazak@gmail.com',
                        imageUrl:
                            'https://avatars.githubusercontent.com/u/83512618?v=4',
                        onEmailTap: () =>
                            _launchURL('mailto:ubdoolrazak@gmail.com'),
                      ),
                      const SizedBox(height: AppDimensions.s),
                      DeveloperCard(
                        name: 'Belal Mohamed',
                        role: 'Mobile Developer',
                        email: 'dixen.bugs@gmail.com',
                        imageUrl:
                            'https://avatars.githubusercontent.com/u/267304485?v=4',
                        onEmailTap: () =>
                            _launchURL('mailto:dixen.bugs@gmail.com'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.xl),

                const SectionHeader(title: 'Organization'),
                AnimatedSection(
                  index: 2,
                  child: CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        InfoTile(
                          icon: Icons.business_rounded,
                          label: 'Company',
                          value: 'Apexiums Technologies',
                          onTap: () =>
                              _launchURL('https://apexiumstechnologies.com/'),
                        ),
                        _buildDivider(colorScheme),
                        InfoTile(
                          icon: Icons.language_rounded,
                          label: 'Website',
                          value: 'apexiumstechnologies.com',
                          onTap: () =>
                              _launchURL('https://apexiumstechnologies.com/'),
                        ),
                        _buildDivider(colorScheme),
                        InfoTile(
                          icon: Icons.email_outlined,
                          label: 'Support',
                          value: 'ammanm0789@gmail.com',
                          onTap: () =>
                              _launchURL('mailto:ammanm0789@gmail.com'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xxl),

                Center(
                  child: Text(
                    '© 2026 Apexiums Technologies',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
                const SizedBox(height: AppDimensions.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: AppDimensions.m,
      color: colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }
}
