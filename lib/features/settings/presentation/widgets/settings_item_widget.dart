import 'package:by_train/core/theme/app_dimensions.dart';
import 'package:by_train/features/settings/domain/settings_item_model.dart';
import 'package:flutter/material.dart';

class SettingsTileWidget extends StatelessWidget {
  final SettingsItemModel settings;
  const SettingsTileWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s),
        child: Row(
          spacing: 16.0,
          children: [Icon(settings.icon), Text(settings.title)],
        ),
      ),
    );
  }
}
