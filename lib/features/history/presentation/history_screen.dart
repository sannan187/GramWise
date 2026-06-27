import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/history_controller.dart';
import '../widgets/history_widgets.dart';

/// Premium History Screen displaying past calculations, swipe-to-delete, and clear button (Phase 5).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyList = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'History',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (historyList.isNotEmpty)
            Tooltip(
              message: 'Clear All History',
              child: IconButton(
                icon: Icon(
                  Icons.delete_sweep_rounded,
                  size: 26,
                  color: theme.colorScheme.error,
                ),
                onPressed: () => showClearHistoryDialog(context, ref),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: AppConstants.spacingSM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beautiful page header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXXS),
                    Text(
                      'Recent Calculations',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),

              // Main List OR Empty State
              Expanded(
                child: historyList.isEmpty
                    ? const Center(child: EmptyHistoryState())
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item = historyList[index];
                          return HistoryCard(item: item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
