import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/calculator_widgets.dart';

/// Pixel-perfect recreation of the single source of truth Home Screen design.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0, // Generous lateral padding matching design
              vertical: AppConstants.spacingSM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Top App Bar / Header
                CalculatorAppBar(),
                SizedBox(height: AppConstants.spacingLG),

                // Card 1: Enter Price
                EnterPriceCard(),
                SizedBox(height: 28.0),

                // Card 2: Select Weight (Interactive horizontal picker)
                SelectWeightCard(),
                SizedBox(height: 28.0),

                // Card 3: Calculated Price
                CalculatedPriceCard(),
                SizedBox(height: 28.0),

                // Live Comparison Strip (Phase 4)
                LiveComparisonStrip(),
                SizedBox(height: 28.0),

                // Card 4: Base Price & Savings Split Card
                BasePriceAndSavingsCard(),
                SizedBox(height: 28.0),

                // Button: Save to Price Book
                SaveToPriceBookButton(),
                SizedBox(height: AppConstants.spacingXXL), // Bottom breathing room before NavigationBar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
