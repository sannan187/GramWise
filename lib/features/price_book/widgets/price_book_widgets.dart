import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/navigation_shell.dart';
import '../../calculator/controllers/calculator_controller.dart';
import '../models/price_book_item.dart';
import '../controllers/price_book_controller.dart';
import '../presentation/product_details_screen.dart';

/* ==========================================================================
   1. Price Book Card (Swipe-to-delete enabled & Calculator Integration)
   ========================================================================== */
class PriceBookCard extends ConsumerWidget {
  const PriceBookCard({super.key, required this.item});

  final PriceBookItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final priceStr = item.price == item.price.roundToDouble()
        ? item.price.round().toString()
        : item.price.toStringAsFixed(2);
    final dateStr = DateFormat('MMM d, yyyy').format(item.updatedAt);

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
          ref.read(priceBookProvider.notifier).deleteItem(item.id);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} removed from Price Book'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  ref.read(priceBookProvider.notifier).restoreItem(item);
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
          margin: const EdgeInsets.only(bottom: AppConstants.spacingLG),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(itemId: item.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Avatar / Icon
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.name.isNotEmpty ? item.name[0].toUpperCase() : '📦',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMD),

                    // Main Info: Product Name & Last Updated
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXXS),
                          Text(
                            'Updated $dateStr',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Latest Price & Unit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppConstants.defaultCurrencySymbol}$priceStr',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'per ${item.unit}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppConstants.spacingSM),

                    // Edit Button
                    Tooltip(
                      message: 'Edit Product',
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => showAddEditPriceBookModal(context, ref, item: item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ==========================================================================
   2. Empty Price Book State
   ========================================================================== */
class EmptyPriceBookState extends ConsumerWidget {
  const EmptyPriceBookState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppConstants.spacingXL),
          const Text(
            '📦',
            style: TextStyle(fontSize: 72),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'No saved products',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            'Save frequently purchased items to access them quickly.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          ElevatedButton.icon(
            onPressed: () => showAddEditPriceBookModal(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   3. Add / Edit Price Book Modal Bottom Sheet
   ========================================================================== */
void showAddEditPriceBookModal(BuildContext context, WidgetRef ref, {PriceBookItem? item, String? initialPrice}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _AddEditModalContent(item: item, initialPrice: initialPrice, ref: ref);
    },
  );
}

class _AddEditModalContent extends StatefulWidget {
  const _AddEditModalContent({required this.item, required this.initialPrice, required this.ref});

  final PriceBookItem? item;
  final String? initialPrice;
  final WidgetRef ref;

  @override
  State<_AddEditModalContent> createState() => _AddEditModalContentState();
}

class _AddEditModalContentState extends State<_AddEditModalContent> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _unitController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item != null
          ? (item.price == item.price.roundToDouble() ? item.price.round().toString() : item.price.toString())
          : (widget.initialPrice ?? ''),
    );
    _unitController = TextEditingController(text: item?.unit ?? 'kg'); // Default unit: kg
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    final unit = _unitController.text.trim().isEmpty ? 'kg' : _unitController.text.trim();

    if (name.isEmpty) {
      setState(() { _errorText = 'Product Name is required'; });
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      setState(() { _errorText = 'Please enter a valid price'; });
      return;
    }

    final id = widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    widget.ref.read(priceBookProvider.notifier).addOrUpdateItem(
      id: id,
      name: name,
      price: price,
      unit: unit,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item == null ? 'Add Product' : 'Edit Product',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            if (_errorText != null) ...[
              Text(
                _errorText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSM),
            ],

            // Product Name Field
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),

            // Price Field
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Price (${AppConstants.defaultCurrencySymbol})',
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),

            // Unit Field
            TextField(
              controller: _unitController,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Unit (Default: kg)',
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),

            // Action Buttons: Cancel & Save
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                const SizedBox(width: AppConstants.spacingSM),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                  ),
                  onPressed: _save,
                  child: Text(
                    'Save',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSM),
          ],
        ),
      ),
    );
  }
}
