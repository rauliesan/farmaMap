import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farmacia.dart';
import '../providers/location_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_shimmer.dart';

/// Search screen with real-time debounced search
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double? _distanceTo(Farmacia farmacia) {
    final userPos = ref.read(currentPositionProvider);
    if (userPos == null) return null;
    return NumExtensions.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      farmacia.lat,
      farmacia.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: _buildSearchField(),
        titleSpacing: 0,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: _buildBody(searchState, history),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o dirección...',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: Colors.transparent,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      style: context.textTheme.bodyMedium,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        ref.read(searchProvider.notifier).updateQuery(value);
        setState(() {});
      },
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          ref.read(searchHistoryProvider.notifier).add(value);
        }
      },
    );
  }

  Widget _buildBody(SearchState searchState, List<String> history) {
    // Show search history when query is empty
    if (searchState.query.isEmpty) {
      return _buildHistory(history);
    }

    // Loading state
    if (searchState.isLoading) {
      return const LoadingShimmer(itemCount: 5);
    }

    // Error state
    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                searchState.error!,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // No results
    if (searchState.hasSearched && searchState.results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'Sin resultados',
        subtitle: 'No se encontraron farmacias para "${searchState.query}"',
      );
    }

    // Results list
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final farmacia = searchState.results[index];
        final distance = _distanceTo(farmacia);

        return _SearchResultItem(
          farmacia: farmacia,
          query: searchState.query,
          distanceMeters: distance,
          index: index,
          onTap: () {
            // Save to history
            ref.read(searchHistoryProvider.notifier).add(searchState.query);
            context.push('/detail/${farmacia.id}', extra: farmacia);
          },
        );
      },
    );
  }

  Widget _buildHistory(List<String> history) {
    if (history.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history_rounded,
        title: 'Sin búsquedas recientes',
        subtitle: 'Busca farmacias por nombre o dirección',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Búsquedas recientes',
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchHistoryProvider.notifier).clearAll();
                },
                child: const Text('Borrar todo'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final term = history[index];
              return ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  color: context.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(term, style: context.textTheme.bodyMedium),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).remove(term);
                  },
                ),
                onTap: () {
                  _searchController.text = term;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: term.length),
                  );
                  ref.read(searchProvider.notifier).updateQuery(term);
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Search result item with text highlighting
class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({
    required this.farmacia,
    required this.query,
    this.distanceMeters,
    required this.index,
    this.onTap,
  });

  final Farmacia farmacia;
  final String query;
  final double? distanceMeters;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: farmacia.displayNombre,
                      query: query,
                      style: context.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _HighlightedText(
                      text: farmacia.shortDireccion,
                      query: query,
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (distanceMeters != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceMeters!.toDistanceString(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 250.ms,
          delay: (40 * index).ms,
        )
        .slideX(
          begin: 0.03,
          end: 0,
          duration: 250.ms,
          delay: (40 * index).ms,
        );
  }
}

/// Text widget that highlights matching query substring
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
  });

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final endIndex = startIndex + query.length;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, startIndex), style: style),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: style.copyWith(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(endIndex), style: style),
        ],
      ),
    );
  }
}
