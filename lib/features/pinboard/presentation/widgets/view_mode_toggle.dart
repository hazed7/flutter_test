import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pin_providers.dart';

/// Widget for toggling between grid and list view modes
/// This widget is now hidden as per user request
class ViewModeToggle extends ConsumerWidget {
  /// Constructor
  const ViewModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide the grid view icon completely
    return const SizedBox.shrink(); // Returns an empty widget
  }
}

/// Widget for displaying pins in grid view
class PinViewModeContainer extends ConsumerWidget {
  /// Constructor
  const PinViewModeContainer({
    super.key,
    required this.gridViewBuilder,
    required this.listViewBuilder, // Keep parameter for backward compatibility
  });

  /// Builder for grid view
  final Widget Function() gridViewBuilder;

  /// Builder for list view (kept for backward compatibility but not used)
  final Widget Function() listViewBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always use grid view
    return gridViewBuilder();
  }
}
