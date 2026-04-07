import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moodiary/common/values/colors.dart';
import 'package:moodiary/components/mood_icon/mood_icon_view.dart';

class MoodTrendChart extends StatelessWidget {
  final List<double> moodValues;
  final List<DateTime> dates;
  final double width;
  final double height;

  const MoodTrendChart({
    super.key,
    required this.moodValues,
    required this.dates,
    this.width = 300,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (moodValues.isEmpty || dates.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                moodValues.length,
                (index) => FlSpot(index.toDouble(), moodValues[index]),
              ),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: AppColor.getEmotionColor(moodValues[index]),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withAlpha(30),
              ),
            ),
          ],
          minY: 0,
          maxY: 1,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.25,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dates.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${dates[index].month}/${dates[index].day}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.onSurface.withAlpha(50),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
        ),
      ),
    );
  }
}

class MoodStatistics extends StatelessWidget {
  final List<double> moodValues;

  const MoodStatistics({super.key, required this.moodValues});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (moodValues.isEmpty) {
      return const SizedBox.shrink();
    }

    final avg = moodValues.reduce((a, b) => a + b) / moodValues.length;
    final max = moodValues.reduce((a, b) => a > b ? a : b);
    final min = moodValues.reduce((a, b) => a < b ? a : b);

    return Card.filled(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(theme, '平均', avg, AppColor.getEmotionColor(avg)),
                _buildStatItem(theme, '最高', max, AppColor.getEmotionColor(max)),
                _buildStatItem(theme, '最低', min, AppColor.getEmotionColor(min)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      children: [
        MoodIconComponent(value: value, width: 40),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          '${(value * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
