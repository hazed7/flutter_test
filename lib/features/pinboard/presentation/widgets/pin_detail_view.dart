import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pin_detail/pin_detail_view.dart' as pin_detail;

/// A beautiful detailed view for a pin that appears when a pin is clicked
class PinDetailView extends ConsumerWidget {
  /// Constructor
  const PinDetailView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const pin_detail.PinDetailView();
  }
}
