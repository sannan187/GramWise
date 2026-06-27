import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../../core/constants/app_constants.dart';
import 'privacy_policy_screen.dart';

/// Complete production-ready Settings Screen (Phase 7).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: AppConstants.spacingSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXXS),
                          Text(
                            'App Preferences & Data Management',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSM),

                    /* ==========================================================
                       1. Appearance Section
                       ========================================================== */
                    _SectionHeader(title: 'Appearance', icon: Icons.palette_rounded, color: theme.colorScheme.primary),
                    const SizedBox(height: AppConstants.spacingSM),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Mode',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXXS),
                          Text(
                            'Apply changes instantly across the application',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLG),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: 'light',
                                  label: Text('Light'),
                                  icon: Icon(Icons.light_mode_rounded),
                                ),
                                ButtonSegment<String>(
                                  value: 'dark',
                                  label: Text('Dark'),
                                  icon: Icon(Icons.dark_mode_rounded),
                                ),
                                ButtonSegment<String>(
                                  value: 'system',
                                  label: Text('System'),
                                  icon: Icon(Icons.settings_system_daydream_rounded),
                                ),
                              ],
                              selected: {settingsState.themeMode},
                              onSelectionChanged: (Set<String> newSelection) {
                                settingsNotifier.setThemeMode(newSelection.first);
                              },
                              style: SegmentedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),

                    /* ==========================================================
                       2. Currency Section
                       ========================================================== */
                    _SectionHeader(title: 'Currency', icon: Icons.payments_rounded, color: Colors.green),
                    const SizedBox(height: AppConstants.spacingSM),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Default Currency',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXXS),
                          Text(
                            'Flexible architecture ready for future currencies',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMD),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '₹',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.spacingMD),
                                    Text(
                                      'Indian Rupee (₹ INR)',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Chip(
                                  label: const Text('Selected (V1)'),
                                  backgroundColor: Colors.green.withOpacity(0.15),
                                  labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                  side: BorderSide.none,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),

                    /* ==========================================================
                       3. Data Management Section
                       ========================================================== */
                    _SectionHeader(title: 'Data Management', icon: Icons.storage_rounded, color: Colors.orange),
                    const SizedBox(height: AppConstants.spacingSM),
                    Container(
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
                        children: [
                          // Export Data
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.file_download_rounded, color: Colors.blue),
                            ),
                            title: Text(
                              'Export Data',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Export all History and Price Book data as a JSON file.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                              ),
                            ),
                            onTap: () async {
                              await settingsNotifier.exportData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Data successfully exported to gramwise_backup.json'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Divider(color: theme.colorScheme.outline.withOpacity(0.15), height: 1),

                          // Import Data
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.file_upload_rounded, color: Colors.green),
                            ),
                            title: Text(
                              'Import Data',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Allow importing a previously exported JSON file. Validates before saving.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                              ),
                            ),
                            onTap: () async {
                              final success = await settingsNotifier.importData(ref);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Data successfully imported & verified!' : 'Invalid backup file or import failed.'),
                                    backgroundColor: success ? Colors.green : theme.colorScheme.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Divider(color: theme.colorScheme.outline.withOpacity(0.15), height: 1),

                          // Clear All Data
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.delete_forever_rounded, color: theme.colorScheme.error),
                            ),
                            title: Text(
                              'Clear All Data',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            subtitle: Text(
                              'Delete Calculator History, Price Book, and Product Price Timeline.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Clear All Data?'),
                                  content: const Text(
                                    'This action will permanently delete all Calculator History, saved Price Book items, and Product Price Timelines. This cannot be undone.',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.error,
                                        foregroundColor: theme.colorScheme.onError,
                                      ),
                                      onPressed: () async {
                                        await settingsNotifier.clearAllData(ref);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('All application data cleared successfully.'),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Delete Permanently'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),

                    /* ==========================================================
                       4. Privacy Section
                       ========================================================== */
                    _SectionHeader(title: 'Privacy', icon: Icons.privacy_tip_rounded, color: Colors.blue),
                    const SizedBox(height: AppConstants.spacingSM),
                    Container(
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_rounded, color: Colors.blue),
                        ),
                        title: Text(
                          'Privacy Policy',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'View our commitment to offline-first local data privacy.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),

                    /* ==========================================================
                       5. About Section
                       ========================================================== */
                    _SectionHeader(title: 'About', icon: Icons.info_rounded, color: Colors.purple),
                    const SizedBox(height: AppConstants.spacingSM),
                    Container(
                      padding: const EdgeInsets.all(28.0),
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
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.scale_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMD),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GramWise',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.spacingXXS),
                                    Chip(
                                      label: const Text('Version 1.0.0'),
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                                      labelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingLG),
                          Divider(color: theme.colorScheme.outline.withOpacity(0.15)),
                          const SizedBox(height: AppConstants.spacingLG),
                          Row(
                            children: [
                              Icon(Icons.code_rounded, color: theme.colorScheme.onSurfaceVariant, size: 22),
                              const SizedBox(width: AppConstants.spacingSM),
                              Text(
                                'Created using Flutter.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMD),
                          Row(
                            children: [
                              Icon(Icons.offline_pin_rounded, color: Colors.green, size: 22),
                              const SizedBox(width: AppConstants.spacingSM),
                              Text(
                                'Offline First.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100.0), // Generous bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, required this.color});

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: AppConstants.spacingSM),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
