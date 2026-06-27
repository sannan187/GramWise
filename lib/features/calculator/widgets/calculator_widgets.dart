import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/calculator_controller.dart';
import '../../price_book/widgets/price_book_widgets.dart';

/* ==========================================================================
   1. Calculator App Bar
   ========================================================================== */
class CalculatorAppBar extends StatelessWidget {
  const CalculatorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.scale_rounded,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacingXS),
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 26,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              // Navigation is handled via NavigationBar; keep UI consistent
            },
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   2. Enter Price Card
   ========================================================================== */
class EnterPriceCard extends ConsumerStatefulWidget {
  const EnterPriceCard({super.key});

  @override
  ConsumerState<EnterPriceCard> createState() => _EnterPriceCardState();
}

class _EnterPriceCardState extends ConsumerState<EnterPriceCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialText = ref.read(calculatorProvider).pricePerKgText;
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ENTER PRICE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 3.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppConstants.defaultCurrencySymbol,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppConstants.spacingXS),
              IntrinsicWidth(
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updatePricePerKg(value);
                  },
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   3. Select Weight Card (Premium Horizontal Wheel Picker & Manual Entry)
   ========================================================================== */
class SelectWeightCard extends ConsumerStatefulWidget {
  const SelectWeightCard({super.key});

  @override
  ConsumerState<SelectWeightCard> createState() => _SelectWeightCardState();
}

class _SelectWeightCardState extends ConsumerState<SelectWeightCard> {
  // 50g increments from 50g to 1000g (20 items)
  final List<int> _weights = List.generate(20, (index) => (index + 1) * 50);
  late PageController _pageController;
  late TextEditingController _manualWeightController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final state = ref.read(calculatorProvider);
    int initialIndex = _weights.indexOf(state.selectedPickerWeight.round());
    if (initialIndex == -1) initialIndex = 4; // 250g default
    _pageController = PageController(initialPage: initialIndex, viewportFraction: 0.22);
    _manualWeightController = TextEditingController(text: state.manualWeightText);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _manualWeightController.dispose();
    super.dispose();
  }

  void _validateManualInput(String value) {
    if (value.isEmpty) {
      setState(() { _errorText = null; });
      ref.read(calculatorProvider.notifier).updateManualWeight('');
      return;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      setState(() { _errorText = 'Please enter a valid number'; });
      ref.read(calculatorProvider.notifier).updateManualWeight(value);
    } else if (parsed < 0) {
      setState(() { _errorText = 'Weight cannot be negative'; });
      ref.read(calculatorProvider.notifier).updateManualWeight(value);
    } else if (parsed == 0) {
      setState(() { _errorText = 'Weight must be greater than zero'; });
      ref.read(calculatorProvider.notifier).updateManualWeight(value);
    } else {
      setState(() { _errorText = null; });
      ref.read(calculatorProvider.notifier).updateManualWeight(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calcState = ref.watch(calculatorProvider);
    final activeWeightDisplay = calcState.activeWeightString;
    final selectedMode = calcState.isManualMode ? 'Manual' : 'Picker';
    final int currentIndex = _weights.indexOf(calcState.selectedPickerWeight.round());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SELECT WEIGHT',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                activeWeightDisplay,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXL),
          
          // Dynamic View: Horizontal Picker OR Manual Input
          AnimatedSwitcher(
            duration: AppConstants.durationNormal,
            child: selectedMode == 'Picker'
                ? SizedBox(
                    key: const ValueKey('picker'),
                    height: 60, // Proper height for scaled up text and premium scrolling
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        ref.read(calculatorProvider.notifier).updatePickerWeight(_weights[index].toDouble());
                      },
                      itemCount: _weights.length,
                      itemBuilder: (context, index) {
                        final weight = _weights[index];
                        final weightStr = weight == 1000 ? '1kg' : '${weight}g';
                        final int diff = (index - currentIndex).abs();

                        // Selected weight scales up, side items fade gradually
                        final bool isSelected = index == currentIndex;
                        final double scale = isSelected ? 1.0 : (diff == 1 ? 0.8 : 0.65);
                        final double opacity = isSelected ? 1.0 : (diff == 1 ? 0.5 : 0.25);

                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: AppConstants.durationNormal,
                              curve: AppConstants.curveStandard,
                            );
                          },
                          child: Center(
                            child: AnimatedContainer(
                              duration: AppConstants.durationQuick,
                              curve: AppConstants.curveStandard,
                              transform: Matrix4.identity()..scale(scale),
                              transformAlignment: Alignment.center,
                              child: Text(
                                weightStr,
                                style: TextStyle(
                                  fontSize: isSelected ? 26.0 : 22.0,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.onSurfaceVariant.withOpacity(opacity),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Column(
                    key: const ValueKey('manual'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _manualWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        onChanged: _validateManualInput,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter custom weight',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          suffixText: 'g',
                          suffixStyle: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                          helperText: 'Use this to calculate custom weights.',
                          helperStyle: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          errorText: _errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMD,
                            vertical: AppConstants.spacingMD,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Segmented Control (Picker / Manual)
          Center(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'Picker',
                  label: Text('Picker'),
                  icon: Icon(Icons.linear_scale_rounded),
                ),
                ButtonSegment<String>(
                  value: 'Manual',
                  label: Text('Manual'),
                  icon: Icon(Icons.keyboard_alt_outlined),
                ),
              ],
              selected: {selectedMode},
              onSelectionChanged: (Set<String> newSelection) {
                final mode = newSelection.first;
                ref.read(calculatorProvider.notifier).setManualMode(mode == 'Manual');
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                selectedForegroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   4. Calculated Price Card (Instant Riverpod Result Card)
   ========================================================================== */
class CalculatedPriceCard extends ConsumerWidget {
  const CalculatedPriceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calcState = ref.watch(calculatorProvider);

    // Instant calculations and formatting
    final price = calcState.calculatedPrice;
    final priceStr = price == price.roundToDouble() ? price.round().toString() : price.toStringAsFixed(2);
    final weightStr = calcState.activeWeightString;
    final pricePerKg = calcState.pricePerKg;
    final pricePerKgStr = pricePerKg == pricePerKg.roundToDouble() ? pricePerKg.round().toString() : pricePerKg.toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CALCULATED PRICE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.85),
              letterSpacing: 3.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${AppConstants.defaultCurrencySymbol}$priceStr',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppConstants.spacingXS),
              Text(
                '/ $weightStr',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            '(${AppConstants.defaultCurrencySymbol}$pricePerKgStr / kg)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   5. Base Price & Savings Card
   ========================================================================== */
class BasePriceAndSavingsCard extends StatelessWidget {
  const BasePriceAndSavingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          // Left Side: Base Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BASE PRICE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${AppConstants.defaultCurrencySymbol}500',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingXXS),
                    Text(
                      '/ 1kg',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Vertical Divider
          Container(
            height: 32,
            width: 1,
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          
          // Right Side: Savings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'SAVINGS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppConstants.spacingXXS),
                    Text(
                      '${AppConstants.defaultCurrencySymbol}20',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================================================================
   6. Save to Price Book Button
   ========================================================================== */
class SaveToPriceBookButton extends ConsumerWidget {
  const SaveToPriceBookButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          elevation: 0,
        ),
        onPressed: () {
          final initialPrice = ref.read(calculatorProvider).pricePerKgText;
          showAddEditPriceBookModal(context, ref, initialPrice: initialPrice);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: AppConstants.spacingSM),
            Text(
              'Save to Price Book',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ==========================================================================
   7. Live Comparison Strip (Phase 4)
   ========================================================================== */
class LiveComparisonStrip extends ConsumerWidget {
  const LiveComparisonStrip({super.key});

  final List<double> _comparisonWeights = const [100.0, 250.0, 500.0, 750.0, 1000.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calcState = ref.watch(calculatorProvider);
    final pricePerKg = calcState.pricePerKg;
    final isManualMode = calcState.isManualMode;
    final selectedPickerWeight = calcState.selectedPickerWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIVE COMPARISON',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 3.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _comparisonWeights.length,
            itemBuilder: (context, index) {
              final weight = _comparisonWeights[index];
              final weightLabel = weight == 1000.0 ? '1kg' : '${weight.round()}g';
              
              // Calculate price instantly
              final calculatedPrice = (pricePerKg * weight) / 1000.0;
              final priceDisplay = calculatedPrice.toStringAsFixed(2);

              // Highlight the currently selected weight from the picker (only if NOT in manual mode)
              final isHighlighted = !isManualMode && selectedPickerWeight == weight;

              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingMD),
                child: AnimatedContainer(
                  duration: AppConstants.durationNormal,
                  curve: AppConstants.curveStandard,
                  width: 130,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: isHighlighted ? theme.colorScheme.primary.withOpacity(0.15) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(
                      color: isHighlighted ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                      width: isHighlighted ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (!isHighlighted)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        weightLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isHighlighted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: AppConstants.durationQuick,
                        child: Text(
                          '${AppConstants.defaultCurrencySymbol}$priceDisplay',
                          key: ValueKey(priceDisplay),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isHighlighted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
