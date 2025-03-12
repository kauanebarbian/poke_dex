import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/pokemon_details_model.dart';

class PokemonDetailPage extends StatefulWidget {
  final String pokemonUrl;

  const PokemonDetailPage({super.key, required this.pokemonUrl});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late PokemonDetails _pokemonDetails;
  bool _isLoading = true;
  String _selectedTab = "info";
  Map<String, dynamic> evolution = {};

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetails();
  }

  Future<void> _fetchPokemonDetails() async {
    final dio = Dio();
    final response = await dio.get(widget.pokemonUrl);
    await Future.delayed(Duration(milliseconds: 100));
    _pokemonDetails = PokemonDetails.fromMap(response.data);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: _isLoading
          ? Colors.white
          : _getColorForType(_pokemonDetails.types[0]),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: 1,
                  left: 20,
                  child: Text(
                    _pokemonDetails.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 45,
                  left: 20,
                  child: Row(
                    children: _pokemonDetails.types.map((type) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _getColorForType(type),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Text(
                          type,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.network(
                      _pokemonDetails.imageUrl,
                      height: 180,
                      width: 180,
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.68,
                  minChildSize: 0.55,
                  maxChildSize: 0.68,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTabButton("info", "Informações"),
                                _buildTabButton("moves", "Movimentos"),
                                _buildTabButton("evolution", "Evolução"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              child: _buildTabContent(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String id, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = id;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedTab == id ? Colors.black : Colors.grey,
            ),
          ),
          if (_selectedTab == id)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 3,
              width: 50,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case "moves":
        return _buildHabilidades(_pokemonDetails);
      case "evolution":
        return buildEvolucao(_pokemonDetails);
      case "info":
      default:
        return _buildInformacoesBasicas(_pokemonDetails);
    }
  }

  Widget _buildHabilidades(PokemonDetails pokemon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ataques",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0, // Espaçamento horizontal entre os itens
            runSpacing: 8.0, // Espaçamento vertical entre as linhas
            children: pokemon.moves
                .map((move) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "$move",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    IconData icon;

    // Escolha o ícone com base no rótulo da estatística
    switch (label.toLowerCase()) {
      case 'hp':
        icon = FontAwesomeIcons.heart;
        break;
      case 'ataque':
        icon = FontAwesomeIcons.fistRaised;
        break;
      case 'defesa':
        icon = FontAwesomeIcons.shieldAlt;
        break;
      case 'ataque especial':
        icon = FontAwesomeIcons.wandSparkles;
        break;
      case 'defesa especial':
        icon = FontAwesomeIcons.shieldHeart;
        break;
      case 'velocidade':
        icon = FontAwesomeIcons.tachometerAlt;
        break;
      default:
        icon = Icons.help_outline; // Ícone padrão caso não seja encontrado
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícone da estatística
          Icon(
            icon,
            color: _getColorForStat(value), // Cor do ícone
            size: 20,
          ),
          const SizedBox(width: 8), // Espaçamento entre o ícone e o texto
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black, // Texto branco para contraste
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[300],
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getColorForStat(value)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Texto branco para contraste
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacoesBasicas(PokemonDetails pokemon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard(
              title: "Informações",
              content: [
                "Altura: ${pokemon.height} m",
                "Peso: ${pokemon.weight} kg",
              ],
            ),
            _buildInfoCard(
              title: "Habilidades",
              content: pokemon.abilities,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatsSection(pokemon),
      ],
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<String> content}) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...content.map(
              (text) => Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(PokemonDetails pokemon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estatísticas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow("HP", pokemon.hp),
          _buildStatRow("Ataque", pokemon.attack),
          _buildStatRow("Defesa", pokemon.defense),
          _buildStatRow("Ataque Especial", pokemon.specialAttack),
          _buildStatRow("Defesa Especial", pokemon.specialDefense),
          _buildStatRow("Velocidade", pokemon.speed),
        ],
      ),
    );
  }

  Future<List<PokemonEvolution>> evolutionsFuture(String species) async {
    var speciesData = await Dio().get(species);
    var chainEvolutionUrl = speciesData.data["evolution_chain"]["url"];

    var chainEvolutionData = await Dio().get(chainEvolutionUrl);

    ///"evolves_to": list<>
    ///"species": item
    var listEvolution = <PokemonEvolution>[];

    var chain = chainEvolutionData.data["chain"];

    var splitedUrl = (chain["species"]["url"] as String).split("/");
    var id = splitedUrl[splitedUrl.length - 2];
    var imageUrl =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png";

    listEvolution.add(
        PokemonEvolution(name: chain["species"]["name"], imageUrl: imageUrl));

    var listEvolvChain = chain["evolves_to"] as List<dynamic>;

    _buildEvolveList(listEvolvChain, listEvolution);

    return listEvolution;
  }

  void _buildEvolveList(
      List<dynamic> listEvolvChain, List<PokemonEvolution> listEvolution) {
    for (var item in listEvolvChain) {
      var splitedUrl = (item['species']["url"] as String).split("/");
      var id = splitedUrl[splitedUrl.length - 2];
      var imageUrl =
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png";

      listEvolution.add(
          PokemonEvolution(name: item["species"]["name"], imageUrl: imageUrl));

      if ((item["evolves_to"] as List<dynamic>).isNotEmpty) {
        _buildEvolveList(item["evolves_to"], listEvolution);
      }
    }
  }

  Widget buildEvolucao(PokemonDetails pokemonDetails) {
    return FutureBuilder<List<PokemonEvolution>>(
      future: evolutionsFuture(pokemonDetails.species),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar as evoluções.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Este Pokémon não possui evoluções.");
        } else {
          final evolutions = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: evolutions.map((evolution) {
                    return Column(
                      children: [
                        Image.network(
                          evolution.imageUrl,
                          height: 100,
                          width: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                        Text(
                          evolution.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

Color _getColorForType(String type) {
  switch (type) {
    case 'grass':
      return const Color.fromARGB(255, 99, 196, 102);
    case 'fire':
      return const Color.fromARGB(235, 240, 63, 32);
    case 'water':
      return const Color.fromARGB(255, 61, 136, 248);
    case 'electric':
      return const Color.fromARGB(255, 233, 217, 71);
    case 'poison':
      return const Color.fromARGB(255, 230, 107, 252);
    case 'bug':
      return const Color.fromARGB(255, 159, 218, 92);
    case 'flying':
      return Colors.lightBlue;
    case 'normal':
      return Colors.grey;
    case 'fighting':
      return Colors.brown;
    case 'rock':
      return Colors.brown.shade700;
    case 'ground':
      return const Color.fromARGB(206, 255, 169, 41);
    case 'psychic':
      return const Color.fromARGB(255, 197, 42, 94);
    case 'fairy':
      return const Color.fromARGB(255, 253, 76, 135);
    case 'ghost':
      return Colors.deepPurple;
    case 'dragon':
      return Colors.indigo;
    case 'ice':
      return Colors.cyan;
    default:
      return Colors.grey;
  }
}

Color _getColorForStat(int value) {
  if (value >= 80) {
    return Colors.green;
  } else if (value >= 50) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
