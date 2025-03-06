import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pinboard_app/features/pinboard/presentation/widgets/pin_detail/pin_detail_view.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_window_title_bar.dart';
import '../providers/collection_providers.dart';
import '../providers/pin_providers.dart';
import '../widgets/pin_card.dart';
import '../widgets/pin_create_fab.dart';
import '../widgets/pin_filter_bar.dart';
import '../widgets/pin_search_bar.dart';
import '../widgets/pin_sidebar.dart';
import '../widgets/view_mode_toggle.dart';

/// Main pinboard page
class PinboardPage extends ConsumerWidget {
  /// Constructor
  const PinboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCollectionId = ref.watch(selectedCollectionIdProvider);

    // Determine which pins to display
    final pinsToDisplay = selectedCollectionId != null
        ? ref.watch(filteredPinsInCollectionProvider)
        : ref.watch(filteredPinsProvider);

    // Get selected collection (if any)
    final selectedCollectionAsync = selectedCollectionId != null
        ? ref.watch(collectionByIdProvider(selectedCollectionId))
        : const AsyncData(null);

    final selectedCollection = selectedCollectionAsync.when(
      data: (collection) => collection,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppWindowTitleBar(
                title: selectedCollection != null
                    ? 'Collection: ${selectedCollection.name}'
                    : 'Pinboard',
                showBackButton: selectedCollection != null,
                onBackPressed: selectedCollection != null
                    ? () => ref
                        .read(selectedCollectionIdProvider.notifier)
                        .state = null
                    : null,
                actions: [
                  // View mode toggle
                  const ViewModeToggle(),
                  const SizedBox(width: 16),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    // Sidebar
                    const PinSidebar(),

                    // Main content
                    Expanded(
                      child: Column(
                        children: [
                          // Search and filter bar
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Search bar
                                const Expanded(
                                  child: PinSearchBar(),
                                ),

                                const SizedBox(width: 16),

                                // Theme toggle
                                IconButton(
                                  icon: Icon(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Icons.dark_mode_outlined
                                        : Icons.light_mode_outlined,
                                  ),
                                  onPressed: () {
                                    // Toggle theme
                                    final currentTheme =
                                        ref.read(themeModeProvider);
                                    ref.read(themeModeProvider.notifier).state =
                                        currentTheme == ThemeMode.light
                                            ? ThemeMode.dark
                                            : ThemeMode.light;
                                  },
                                  tooltip: 'Toggle Theme',
                                ),

                                const SizedBox(width: 8),

                                // Settings button
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  onPressed: () => context.go('/settings'),
                                  tooltip: 'Settings',
                                ),
                              ],
                            ),
                          ),

                          // Filter bar (only show if not in a collection)
                          if (selectedCollection == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: PinFilterBar(),
                            ),

                          // Collection description (if in a collection)
                          if (selectedCollection != null &&
                              selectedCollection.description.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  selectedCollection.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Pins grid or list
                          Expanded(
                            child: pinsToDisplay.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          selectedCollection != null
                                              ? Icons.folder_open
                                              : Icons.note_alt_outlined,
                                          size: 64,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          selectedCollection != null
                                              ? 'No pins in this collection'
                                              : 'No pins found',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          selectedCollection != null
                                              ? 'Add pins to this collection to see them here'
                                              : 'Create a new pin to get started',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        if (selectedCollection != null) ...[
                                          const SizedBox(height: 24),
                                          FilledButton.icon(
                                            icon: const Icon(Icons.arrow_back),
                                            label:
                                                const Text('Back to All Pins'),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      selectedCollectionIdProvider
                                                          .notifier)
                                                  .state = null;
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: PinViewModeContainer(
                                      gridViewBuilder: () => _buildGridView(
                                          context,
                                          ref,
                                          pinsToDisplay,
                                          selectedCollection),
                                      listViewBuilder: () =>
                                          Container(), // Placeholder since we're grid-only now
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Pin detail view overlay
          const PinDetailView(),
        ],
      ),
      floatingActionButton: const PinCreateFab(),
    );
  }

  Widget _buildGridView(BuildContext context, WidgetRef ref, List<dynamic> pins,
      dynamic selectedCollection) {
    // Regular grid view (non-draggable)
    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: pins.length,
      itemBuilder: (context, index) {
        final pin = pins[index];
        return PinCard(
          pin: pin,
          inCollection: selectedCollection != null,
          onAddToCollection: selectedCollection == null
              ? () => _showAddToCollectionDialog(context, ref, pin)
              : null,
          onRemoveFromCollection: selectedCollection != null
              ? () => _removeFromCollection(ref, selectedCollection.id, pin.id)
              : null,
        );
      },
    );
  }

  void _showAddToCollectionDialog(
      BuildContext context, WidgetRef ref, dynamic pin) {
    final collectionsAsync = ref.read(allCollectionsProvider);

    collectionsAsync.when(
      data: (collections) {
        if (collections.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No collections available. Create a collection first.'),
            ),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Add to Collection'),
              content: SizedBox(
                width: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return ListTile(
                      leading: Icon(_getIconForCollection(collection.icon)),
                      title: Text(collection.name),
                      onTap: () {
                        ref
                            .read(collectionRepositoryProvider)
                            .addPinToCollection(collection.id, pin.id);
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to ${collection.name}'),
                            action: SnackBarAction(
                              label: 'View',
                              onPressed: () {
                                ref
                                    .read(selectedCollectionIdProvider.notifier)
                                    .state = collection.id;
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void _removeFromCollection(WidgetRef ref, String collectionId, String pinId) {
    ref.read(collectionRepositoryProvider).removePinFromCollection(
          collectionId,
          pinId,
        );

    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Removed from collection'),
      ),
    );
  }

  IconData _getIconForCollection(String icon) {
    switch (icon) {
      case 'folder':
        return Icons.folder;
      case 'work':
        return Icons.work;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'bookmark':
        return Icons.bookmark;
      case 'label':
        return Icons.label;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      default:
        return Icons.folder;
    }
  }
}
