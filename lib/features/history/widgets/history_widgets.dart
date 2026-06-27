import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../models/history_item.dart';
import '../controllers/history_controller.dart';

/* ==========================================================================
   1. History Card (Swipe-to-delete enabled)
   ========================================================================== */
class HistoryCard extends ConsumerWidget {
  const HistoryCard({super.key, required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calc = item.calculation;
    
    // Formatting values beautifully
    final priceStr = calc.calculatedPrice == calc.calculatedPrice.roundToDouble() 
        ? calc.calculatedPrice.round().toString() 
        : calc.calculatedPrice.toStringAsFixed(2);
    final weightStr = calc.targetWeightInGrams == 1000.0 ? '1kg' : '${calc.targetWeightInGrams.round()}g';
    final pricePerKgStr = calc.unitPrice == calc.unitPrice.roundToDouble() 
        ? calc.unitPrice.round().toString() 
        : calc.unitPrice.toStringAsFixed(2);
    
    final dateStr = DateFormat('MMM d, yyyy').format(item.recordedAt);
    final timeStr = DateFormat('h:mm a').format(item.recordedAt);
    final isManualMode = item.notes == 'Manual';

    return TweenAnimationBuilder<double>(
      key: Key('anim_${item.id}'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          ref.read(historyProvider.notifier).deleteHistoryItem(item.id);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Calculation removed from history'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  ref.read(historyProvider.notifier).restoreHistoryItem(item);
                },
              ),
            ),
          );
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingLG),
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.onErrorContainer,
            size: 28,
          ),
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingLG),
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
              // Top Row: Mode Badge & Date/Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    ),
                    child: Text(
                      isManualMode ? 'Manual Mode' : 'Picker Mode',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$dateStr • $timeStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),

              // Main Content: Final Price, Weight, Price per KG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CALCULATED PRICE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXXS),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${AppConstants.defaultCurrencySymbol}$priceStr',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Text(
                            '/ $weightStr',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${AppConstants.defaultCurrencySymbol}$pricePerKgStr / kg',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ==========================================================================
   2. Empty History State
   ========================================================================== */
class EmptyHistoryState extends StatelessWidget {
  const EmptyHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppConstants.spacingXXL),
          Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'No calculations yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            'Your recent calculations will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   3. Clear All History Dialog helper
   ========================================================================== */
void showClearHistoryDialog(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
        ),
        title: Text(
          'Clear All History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete all past calculation history? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
            ),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAllHistory();
              Navigator.pop(context);
            },
            child: Text(
              'Delete All',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
