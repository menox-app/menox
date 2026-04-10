import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_core/core/apis/app/interfaces/pokemon.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';

class PokemonListPage extends HookConsumerWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final apiClient = ref.watch(apiClientProvider).pokemon;

    // Search state with debounce
    final searchController = useTextEditingController();
    final debouncedSearch = useState('');

    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 500), () {
        debouncedSearch.value = searchController.text;
      });
      return timer.cancel;
    }, [searchController.text]);

    final query = useInfiniteQuery<List<Pokemon>, dynamic, int>(
      ['pokemon-list', debouncedSearch.value],
      (context) async {
        final response = await apiClient.getAll(
          BasePaginationRequest(
            page: context.pageParam,
            limit: 20,
            extraParams: debouncedSearch.value,
          ),
        );
        return response.data;
      },
      initialPageParam: 1,
      nextPageParamBuilder: (data) {
        final lastPage = data.pages.last;
        return lastPage.length == 20 ? data.pages.length + 1 : null;
      },
    );

    return CupertinoPageScaffold(
      backgroundColor: ShadcnColors.secondary,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Pokédex'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, size: 24),
          onPressed: () => _showAddPokemonDialog(context, ref),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: searchController,
                placeholder: 'Search Pokemon...',
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (query.status == QueryStatus.pending && query.pages.isEmpty) {
                    return _LoadingGrid();
                  }
                  if (query.isRefetching) {
                    return _LoadingGrid();
                  }
                  if (query.status == QueryStatus.error && query.pages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${query.error}', style: theme.textTheme.textStyle),
                          const SizedBox(height: 16),
                          AppButton(
                            text: 'Retry',
                            onPressed: () => query.refetch(),
                          ),
                        ],
                      ),
                    );
                  }

                  final allPokemon = query.pages.expand((page) => page).toList();

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: () async => await query.refetch(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < allPokemon.length) {
                                return _PokemonCard(pokemon: allPokemon[index]);
                              } else {
                                // Trigger load more
                                if (query.status != QueryStatus.pending) {
                                  Future.microtask(() => query.fetchNextPage());
                                }
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }
                            },
                            childCount: allPokemon.length + (query.hasNextPage ? 1 : 0),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPokemonDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add Pokemon (Simulated)'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: nameController,
            placeholder: 'Name',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigation handled by GoRouter or Navigator
      },
      child: Container(
        decoration: BoxDecoration(
          color: ShadcnColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ShadcnColors.border, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl ?? '',
                          height: 80,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: ShadcnColors.muted,
                            highlightColor: ShadcnColors.background,
                            child: Container(color: CupertinoColors.white),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pokemon.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: ShadcnColors.muted,
        highlightColor: ShadcnColors.background,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
