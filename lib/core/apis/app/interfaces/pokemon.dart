import 'package:flutter_core/core/apis/base/interfaces/record.dart';

class Pokemon extends BaseRecord<int> {
  final String name;
  final String? imageUrl;
  final List<String> types;
  final int? height;
  final int? weight;
  final List<PokemonStat>? stats;

  Pokemon({
    required super.id,
    required this.name,
    this.imageUrl,
    this.types = const [],
    this.height,
    this.weight,
    this.stats,
    super.createdAt,
    super.updatedAt,
    super.extraData,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? _extractIdFromUrl(json['url'] ?? '');
    
    return Pokemon(
      id: id,
      name: json['name'],
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default'] ?? 
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      types: (json['types'] as List?)
              ?.map((t) => t['type']['name'] as String)
              .toList() ?? [],
      height: json['height'],
      weight: json['weight'],
      stats: (json['stats'] as List?)
              ?.map((s) => PokemonStat.fromJson(s))
              .toList(),
      extraData: json,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      ...extraData,
    };
  }

  static int _extractIdFromUrl(String url) {
    if (url.isEmpty) return 0;
    final parts = url.split('/');
    // Remove empty strings from ends if trailing slash exists
    final filtered = parts.where((p) => p.isNotEmpty).toList();
    return int.tryParse(filtered.last) ?? 0;
  }
}

class PokemonStat {
  final String name;
  final int value;

  PokemonStat({required this.name, required this.value});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'],
      value: json['base_stat'],
    );
  }
}
