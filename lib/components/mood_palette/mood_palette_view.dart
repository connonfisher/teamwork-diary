import 'package:flutter/material.dart';
import 'package:moodiary/common/values/colors.dart';
import 'package:moodiary/components/mood_icon/mood_icon_view.dart';

class PresetMoodChip extends StatelessWidget {
  final String label;
  final Color color;
  final double value;
  final bool isSelected;
  final Function(double) onSelected;

  const PresetMoodChip({
    super.key,
    required this.label,
    required this.color,
    required this.value,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: MoodIconComponent(value: value, width: 20.0),
      selected: isSelected,
      selectedColor: color.withAlpha(50),
      checkmarkColor: color,
      onSelected: (selected) {
        if (selected) {
          onSelected(value);
        }
      },
    );
  }
}

class MoodPaletteComponent extends StatelessWidget {
  final double currentValue;
  final Function(double) onValueChanged;

  const MoodPaletteComponent({
    super.key,
    required this.currentValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: AppColor.presetEmotions.entries.map((entry) {
            final emotion = entry.value;
            return PresetMoodChip(
              label: emotion['label'] as String,
              color: emotion['color'] as Color,
              value: emotion['value'] as double,
              isSelected: (currentValue - emotion['value']).abs() < 0.05,
              onSelected: onValueChanged,
            );
          }).toList(),
        ),
      ],
    );
  }
}
