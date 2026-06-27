import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../history/controllers/history_controller.dart';

/// Immutable state holding all calculator engine inputs and computed values (Phase 3).
class CalculatorState {
  final String pricePerKgText;
  final double selectedPickerWeight; // in grams
  final String manualWeightText; // in grams
  final bool isManualMode;

  const CalculatorState({
    required this.pricePerKgText,
    required this.selectedPickerWeight,
    required this.manualWeightText,
    required this.isManualMode,
  });

  CalculatorState copyWith({
    String? pricePerKgText,
    double? selectedPickerWeight,
    String? manualWeightText,
    bool? isManualMode,
  }) {
    return CalculatorState(
      pricePerKgText: pricePerKgText ?? this.pricePerKgText,
      selectedPickerWeight: selectedPickerWeight ?? this.selectedPickerWeight,
      manualWeightText: manualWeightText ?? this.manualWeightText,
      isManualMode: isManualMode ?? this.isManualMode,
    );
  }

  /// Parses Price per KG. Returns 0.0 if empty, invalid, negative, or zero.
  double get pricePerKg {
    if (pricePerKgText.isEmpty) return 0.0;
    final parsed = double.tryParse(pricePerKgText);
    if (parsed == null || parsed <= 0) return 0.0;
    return parsed;
  }

  /// Returns the active weight depending on Picker vs Manual mode.
  double get activeWeight {
    if (isManualMode) {
      if (manualWeightText.isEmpty) return 0.0;
      final parsed = double.tryParse(manualWeightText);
      if (parsed == null || parsed <= 0) return 0.0;
      return parsed;
    } else {
      return selectedPickerWeight;
    }
  }

  /// Returns true if both inputs are valid and positive.
  bool get isValid => pricePerKg > 0 && activeWeight > 0;

  /// Instant price calculation using: Price = (Price per KG × Weight in grams) / 1000
  double get calculatedPrice {
    if (!isValid) return 0.0;
    return (pricePerKg * activeWeight) / 1000.0;
  }

  /// Formatted helper strings for UI rendering
  String get activeWeightString {
    if (isManualMode) {
      if (manualWeightText.isEmpty) return '0g';
      final parsed = double.tryParse(manualWeightText);
      if (parsed == null || parsed < 0) return 'Invalid';
      return '${parsed == parsed.roundToDouble() ? parsed.round() : parsed}g';
    } else {
      return selectedPickerWeight == 1000 ? '1kg' : '${selectedPickerWeight.round()}g';
    }
  }
}

/// Riverpod StateNotifier managing calculator engine logic and debounced history auto-saving.
class CalculatorController extends StateNotifier<CalculatorState> {
  final Ref ref;
  Timer? _debounceTimer;

  CalculatorController(this.ref)
      : super(const CalculatorState(
          pricePerKgText: '250',
          selectedPickerWeight: 250.0,
          manualWeightText: '',
          isManualMode: false,
        )) {
    // Automatically save initial successful calculation after launch
    _scheduleAutoSave();
  }

  void updatePricePerKg(String text) {
    state = state.copyWith(pricePerKgText: text);
    _scheduleAutoSave();
  }

  void updatePickerWeight(double weight) {
    state = state.copyWith(selectedPickerWeight: weight);
    _scheduleAutoSave();
  }

  void updateManualWeight(String text) {
    state = state.copyWith(manualWeightText: text);
    _scheduleAutoSave();
  }

  void setManualMode(bool isManual) {
    state = state.copyWith(isManualMode: isManual);
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (state.isValid && state.calculatedPrice > 0) {
        ref.read(historyProvider.notifier).addCalculation(
          pricePerKg: state.pricePerKg,
          activeWeight: state.activeWeight,
          calculatedPrice: state.calculatedPrice,
          isManualMode: state.isManualMode,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorController, CalculatorState>((ref) {
  return CalculatorController(ref);
});
