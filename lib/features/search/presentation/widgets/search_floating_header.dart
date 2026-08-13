import 'dart:ui';
import 'package:flutter/material.dart';

class SearchFloatingHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final bool voiceActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onVoiceTap;

  const SearchFloatingHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    this.voiceActive = false,
    required this.onChanged,
    required this.onClear,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: voiceActive
                    ? theme.colorScheme.error.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search train, station or route...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: voiceActive
                      ? _VoiceButton(
                          key: const ValueKey('voice-on'),
                          active: true,
                          onPressed: onVoiceTap,
                        )
                      : isSearching
                      ? IconButton(
                          key: const ValueKey('clear'),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: onClear,
                        )
                      : _VoiceButton(
                          key: const ValueKey('voice-off'),
                          active: false,
                          onPressed: onVoiceTap,
                        ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The mic toggle. Off shows a muted outline icon; on shows a filled,
/// error-tinted icon (the app's "listening" state).
class _VoiceButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;

  const _VoiceButton({
    super.key,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return IconButton(
      icon: Icon(
        active ? Icons.mic_rounded : Icons.mic_none_rounded,
        color: color,
      ),
      tooltip: active ? 'Stop voice input' : 'Start voice input',
      onPressed: onPressed,
    );
  }
}
