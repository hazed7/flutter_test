import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pin_providers.dart';

/// Provider for the search bar focus node
final searchBarFocusNodeProvider = Provider<FocusNode>((ref) {
  final focusNode = FocusNode();
  ref.onDispose(() {
    focusNode.dispose();
  });
  return focusNode;
});

/// Search bar for filtering pins
class PinSearchBar extends ConsumerWidget {
  /// Constructor
  const PinSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Theme.of(context);
    final searchQuery = ref.watch(searchQueryProvider);
    final focusNode = ref.watch(searchBarFocusNodeProvider);

    return TextField(
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: 'Search pins...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      textInputAction: TextInputAction.search,
    );
  }
}
