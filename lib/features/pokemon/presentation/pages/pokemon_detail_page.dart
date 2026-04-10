import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:flutter_core/core/apis/app/interfaces/pokemon.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';

class PokemonDetailPage extends HookConsumerWidget {
  final int id;
  const PokemonDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.watch(apiClientProvider).pokemon;

    final query = useQuery<Pokemon, dynamic>(['pokemon', 'detail', id], (
      context,
    ) async {
      final response = await apiClient.getById(
        BaseGetByIdRequest(id: id.toString()),
      );
      return response.data;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (query.data == null) {
            if (query.status == QueryStatus.error) {
              return Center(child: Text('Error: ${query.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final pokemon = query.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl ?? '',
                      height: 300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemon.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatInfo(
                            label: 'Height',
                            value: '${(pokemon.height ?? 0) / 10} m',
                          ),
                          const SizedBox(width: 24),
                          _StatInfo(
                            label: 'Weight',
                            value: '${(pokemon.weight ?? 0) / 10} kg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Base Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...?(pokemon.stats?.map(
                        (s) => _StatBar(stat: s.name, value: s.value),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatInfo extends StatelessWidget {
  final String label;
  final String value;
  const _StatInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  final String stat;
  final int value;
  const _StatBar({required this.stat, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 150,
            backgroundColor: Colors.grey[200],
            color: _getStatColor(stat),
            borderRadius: BorderRadius.circular(10),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  Color _getStatColor(String stat) {
    if (stat.contains('hp')) return Colors.red;
    if (stat.contains('attack')) return Colors.orange;
    if (stat.contains('defense')) return Colors.blue;
    if (stat.contains('speed')) return Colors.amber;
    return Colors.green;
  }
}
