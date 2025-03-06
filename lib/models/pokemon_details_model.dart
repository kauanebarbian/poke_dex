class PokemonDetails {
  final int id;
  final String name;
  final String imageUrl;
  final double height;
  final double weight;
  final List<String> abilities;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  PokemonDetails({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  factory PokemonDetails.fromMap(Map<String, dynamic> map) {
    // Extraindo as estatísticas da lista 'stats'
    final stats = map['stats'] as List;
    final hp =
        stats.firstWhere((stat) => stat['stat']['name'] == 'hp')['base_stat'];
    final attack = stats
        .firstWhere((stat) => stat['stat']['name'] == 'attack')['base_stat'];
    final defense = stats
        .firstWhere((stat) => stat['stat']['name'] == 'defense')['base_stat'];
    final specialAttack = stats.firstWhere(
        (stat) => stat['stat']['name'] == 'special-attack')['base_stat'];
    final specialDefense = stats.firstWhere(
        (stat) => stat['stat']['name'] == 'special-defense')['base_stat'];
    final speed = stats
        .firstWhere((stat) => stat['stat']['name'] == 'speed')['base_stat'];

    return PokemonDetails(
      id: map['id'],
      name: map['name'],
      imageUrl: map['sprites']['other']['official-artwork']['front_default'],
      height: map['height'] / 10, // Convertendo de decímetros para metros
      weight: map['weight'] / 10, // Convertendo de hectogramas para quilogramas
      abilities: (map['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList(),
      types: (map['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      hp: hp,
      attack: attack,
      defense: defense,
      specialAttack: specialAttack,
      specialDefense: specialDefense,
      speed: speed,
    );
  }
}
