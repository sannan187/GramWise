import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/navigation_shell.dart';
import '../../calculator/controllers/calculator_controller.dart';
import '../controllers/price_book_controller.dart';
import '../models/price_book_item.dart';
import '../models/price_history_entry.dart';
import '../widgets/price_book_widgets.dart';

/// Product Details Screen featuring Price History, Analytics, and fl_chart Line Chart.
class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(priceBookProvider);
    
    // Find item, handle case where it might have been deleted
    final item = items.firstWhere(
      (element) => element.id == itemId,
      orElse: () => PriceBookItem(
        id: '',
        name: 'Product not found',
        category: 'kg',
        currentUnitPrice: 0.0,
        baseWeightInGrams: 1000.0,
        priceHistory: [],
        updatedAt: DateTime.now(),
      ),
    );

    if (item.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found or removed.')),
      );
    }

    final priceStr = item.price == item.price.roundToDouble()
        ? item.price.round().toString()
        : item.price.toStringAsFixed(2);
    final lastUpdatedStr = DateFormat('MMMM d, yyyy').format(item.updatedAt);

    // Prepare sorted price history (chronological: oldest first for chart)
    final sortedHistory = List<PriceHistoryEntry>.from(item.priceHistory)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate Analytics
    double highest = 0.0;
    double lowest = 0.0;
    double average = 0.0;
    double percentageChange = 0.0;
    bool hasPriorData = sortedHistory.length >= 2;

    if (sortedHistory.isNotEmpty) {
      highest = sortedHistory.map((e) => e.unitPrice).reduce(math.max);
      lowest = sortedHistory.map((e) => e.unitPrice).reduce(math.min);
      average = sortedHistory.map((e) => e.unitPrice).reduce((a, b) => a + b) / sortedHistory.length;

      if (hasPriorData) {
        final latestPrice = sortedHistory.last.unitPrice;
        final previousPrice = sortedHistory[sortedHistory.length - 2].unitPrice;
        final diff = latestPrice - previousPrice;
        if (previousPrice > 0) {
          percentageChange = (diff / previousPrice) * 100;
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Product Summary Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '📦',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingXXS),
                              Text(
                                'Last updated: $lastUpdatedStr',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLG),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Price',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXXS),
                            Text(
                              '${AppConstants.defaultCurrencySymbol}$priceStr per ${item.unit}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLG),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => showAddEditPriceBookModal(context, ref, item: item),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                              ),
                            ),
                            icon: Icon(Icons.update_rounded, color: theme.colorScheme.primary),
                            label: Text(
                              'Update Price',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSM),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(calculatorProvider.notifier).updatePricePerKg(priceStr);
                              ref.read(navigationIndexProvider.notifier).state = 0;
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                              ),
                            ),
                            icon: const Icon(Icons.calculate_rounded),
                            label: const Text(
                              'Use in Calculator',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // 2. Analytics Section
              Text(
                'Price Analytics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AnalyticsCard(
                    title: 'Latest Price',
                    value: '${AppConstants.defaultCurrencySymbol}$priceStr',
                    subtitle: 'per ${item.unit}',
                    icon: Icons.tag_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  _AnalyticsCard(
                    title: 'Average Price',
                    value: '${AppConstants.defaultCurrencySymbol}${average.toStringAsFixed(1)}',
                    subtitle: 'All recorded prices',
                    icon: Icons.functions_rounded,
                    color: Colors.blue,
                  ),
                  _AnalyticsCard(
                    title: 'Highest Price',
                    value: '${AppConstants.defaultCurrencySymbol}${highest == highest.roundToDouble() ? highest.round() : highest.toStringAsFixed(2)}',
                    subtitle: 'Peak price recorded',
                    icon: Icons.trending_up_rounded,
                    color: Colors.orange,
                  ),
                  _AnalyticsCard(
                    title: 'Lowest Price',
                    value: '${AppConstants.defaultCurrencySymbol}${lowest == lowest.roundToDouble() ? lowest.round() : lowest.toStringAsFixed(2)}',
                    subtitle: 'Best price recorded',
                    icon: Icons.trending_down_rounded,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Percentage change card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: (hasPriorData && percentageChange != 0)
                            ? (percentageChange > 0 ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12))
                            : theme.colorScheme.onSurfaceVariant.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (hasPriorData && percentageChange != 0)
                            ? (percentageChange > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
                            : Icons.trending_flat_rounded,
                        color: (hasPriorData && percentageChange != 0)
                            ? (percentageChange > 0 ? Colors.red : Colors.green)
                            : theme.colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trend from Previous Price',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXXS),
                          Text(
                            hasPriorData
                                ? (percentageChange == 0
                                    ? '0.0% (No change)'
                                    : '${percentageChange > 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%')
                                : 'No prior data available',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: (hasPriorData && percentageChange != 0)
                                  ? (percentageChange > 0 ? Colors.red : Colors.green)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // 3. Line Chart Section
              Text(
                'Price Fluctuation Chart',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),
              Container(
                height: 280,
                padding: const EdgeInsets.only(left: 16, right: 28, top: 28, bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: sortedHistory.isEmpty
                    ? const Center(child: Text('No price history available.'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: (highest - lowest) > 0 ? ((highest - lowest) / 4) : 10.0,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: theme.colorScheme.outline.withOpacity(0.15),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${AppConstants.defaultCurrencySymbol}${value.round()}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= sortedHistory.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final entry = sortedHistory[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('MMM d').format(entry.timestamp),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: sortedHistory.length > 1 ? (sortedHistory.length - 1).toDouble() : 1.0,
                          minY: (lowest * 0.9).floorToDouble(),
                          maxY: (highest * 1.1).ceilToDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: sortedHistory.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.unitPrice);
                              }).toList(),
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: theme.colorScheme.primary,
                              barWidth: 3.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: theme.colorScheme.primary,
                                    strokeWidth: 2,
                                    strokeColor: theme.colorScheme.surface,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // 4. Price Timeline Section
              Text(
                'Price Timeline',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedHistory.length,
                itemBuilder: (context, index) {
                  // Display newest entries first in the timeline list
                  final entry = sortedHistory[sortedHistory.length - 1 - index];
                  final entryPriceStr = entry.unitPrice == entry.unitPrice.roundToDouble()
                      ? entry.unitPrice.round().toString()
                      : entry.unitPrice.toStringAsFixed(2);
                  final entryDateStr = DateFormat('MMM d, yyyy').format(entry.timestamp);
                  final entryTimeStr = DateFormat('h:mm a').format(entry.timestamp);

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMD),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entryDateStr,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingXXS),
                                Text(
                                  entryTimeStr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${AppConstants.defaultCurrencySymbol}$entryPriceStr',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
