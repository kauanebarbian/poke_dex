class Stat {
  final String name;
  final int value;

  Stat({required this.name, required this.value});
}

class PokemonEvolution {
  final String name;
  final String imageUrl;

  PokemonEvolution({required this.name, required this.imageUrl});

  factory PokemonEvolution.fromMap(Map<String, dynamic> map) {
    return PokemonEvolution(
      name: map["name"] ?? "Desconhecido",
      imageUrl: map["image_url"] ?? "",
    );
  }
}

class PokemonDetails {
  final int id;
  final String name;
  final String imageUrl;
  final double height;
  final double weight;
  final List<String> abilities;
  final List<String> types;
  final List<String> moves;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final List<Stat> stats;
  final String species;

  PokemonDetails(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.height,
      required this.weight,
      required this.abilities,
      required this.types,
      required this.moves,
      required this.hp,
      required this.attack,
      required this.defense,
      required this.specialAttack,
      required this.specialDefense,
      required this.speed,
      required this.stats,
      required this.species});

  factory PokemonDetails.fromMap(Map<String, dynamic> map) {
    final statsList = (map['stats'] as List).map((stat) {
      return Stat(
        name: stat['stat']['name'],
        value: stat['base_stat'],
      );
    }).toList();

    final hp = statsList.firstWhere((stat) => stat.name == 'hp').value;
    final attack = statsList.firstWhere((stat) => stat.name == 'attack').value;
    final defense =
        statsList.firstWhere((stat) => stat.name == 'defense').value;
    final specialAttack =
        statsList.firstWhere((stat) => stat.name == 'special-attack').value;
    final specialDefense =
        statsList.firstWhere((stat) => stat.name == 'special-defense').value;
    final speed = statsList.firstWhere((stat) => stat.name == 'speed').value;

    return PokemonDetails(
      id: map['id'],
      name: map['name'],
      imageUrl: map['sprites']['other']['official-artwork']['front_default'],
      height: map['height'] / 10,
      weight: map['weight'] / 10,
      abilities: (map['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList(),
      types: (map['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      moves: (map["moves"] as List)
          .map((move) => move["move"]["name"] as String)
          .toList(),
      hp: hp,
      attack: attack,
      defense: defense,
      specialAttack: specialAttack,
      specialDefense: specialDefense,
      speed: speed,
      stats: statsList,
      species: map["species"]["url"],
    );
  }
}
