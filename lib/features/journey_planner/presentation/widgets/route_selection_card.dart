import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';

class RouteSelectionCard extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final FocusNode fromFocusNode;
  final FocusNode toFocusNode;
  final double swapTurns;
  final DateTime selectedDateTime;
  final bool isSearching;
  final VoidCallback onSwap;
  final VoidCallback onSelectDateTime;
  final VoidCallback onSearch;
  final VoidCallback onNowPressed;
  final String formattedDateTime;
  final Function(String) onClear;

  const RouteSelectionCard({
    super.key,
    required this.fromController,
    required this.toController,
    required this.fromFocusNode,
    required this.toFocusNode,
    required this.swapTurns,
    required this.selectedDateTime,
    required this.isSearching,
    required this.onSwap,
    required this.onSelectDateTime,
    required this.onSearch,
    required this.onNowPressed,
    required this.formattedDateTime,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: AppDimensions.m,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, left: 4, right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                )
                              ]
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: colorScheme.surface, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.secondary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                )
                              ]
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Input TextFields
                    Expanded(
                      child: Column(
                        children: [
                          _StationTextField(
                            controller: fromController,
                            focusNode: fromFocusNode,
                            label: 'From Station',
                            hint: 'Where from?',
                            onClear: () => onClear('from'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                          ),
                          _StationTextField(
                            controller: toController,
                            focusNode: toFocusNode,
                            label: 'To Station',
                            hint: 'Where to?',
                            onClear: () => onClear('to'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),

                // Absolute positioned Swap Button with rotation animation
                Positioned(
                  right: 0,
                  child: AnimatedRotation(
                    turns: swapTurns,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutBack,
                    child: Material(
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: const CircleBorder(),
                      color: colorScheme.primary,
                      child: InkWell(
                        onTap: onSwap,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            color: colorScheme.onPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.m),

            // Date & Time Custom selector row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSelectDateTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppDimensions.s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Departure Time',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formattedDateTime,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s),

                // Quick "Now" button shortcut
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onNowPressed,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        color: colorScheme.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Now',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.l),

            // Search trigger using our highly customized AppButton widget
            AppButton(
              label: 'Find Best Journeys',
              icon: Icons.search_rounded,
              isLoading: isSearching,
              onPressed: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}

class _StationTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final VoidCallback onClear;

  const _StationTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        filled: false,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
