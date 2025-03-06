import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poke_dex/models/poke_model.dart';
import 'package:poke_dex/models/pokemon_list_model.dart';
import 'package:poke_dex/pages/pokemon_details.dart';
import 'package:poke_dex/models/pokemon_details_model.dart';
import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final List<StatItem> stats;

  const StatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Column(
          children: stats.map((stat) => _buildStatRow(stat)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatRow(StatItem stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              stat.label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: stat.value,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getStatColor(stat.value),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${stat.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(int value) {
    if (value < 40) return Colors.red;
    if (value < 70) return Colors.orange;
    return Colors.green;
  }
}

class StatItem {
  final String label;
  final int value;

  StatItem({required this.label, required this.value});
}

// Modelo atualizado para integração com a PokeAPI
class PokemonDetails {
  // ... outras propriedades

  List<StatItem> get stats => [
        StatItem(label: 'HP', value: hp),
        StatItem(label: 'ATK', value: attack),
        StatItem(label: 'DEF', value: defense),
        StatItem(label: 'STK', value: specialAttack),
        StatItem(label: 'SEF', value: specialDefense),
        StatItem(label: 'SPD', value: speed),
      ];
}

class PokeHomePage extends StatefulWidget {
  const PokeHomePage({Key? key}) : super(key: key);

  @override
  State<PokeHomePage> createState() => _PokeHomePageState();
}

class _PokeHomePageState extends State<PokeHomePage> {
  List<Pokemon> _pokemonList = [];
  List<Pokemon> _filteredPokemonList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
  }

  // Função para buscar os Pokémons
  Future<void> _fetchPokemons() async {
    final dio = Dio();
    try {
      final response = await dio
          .get('https://pokeapi.co/api/v2/pokemon?limit=1000&offset=0');
      var model = PokemonListModel.fromMap(response.data);
      setState(() {
        _pokemonList = model.results;
        _filteredPokemonList =
            _pokemonList; // Inicialmente, lista filtrada é igual à lista completa
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar Pokémon: $e";
        _isLoading = false;
      });
    }
  }

  // Função que retorna a cor do tipo
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

  // Função para exibir o Grid de Pokémons
  Widget _buildPokemonGrid(List<Pokemon> pokemonList) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.5, // 0.5 de espaçamento entre os cards
        mainAxisSpacing: 5,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var pokemon = pokemonList[index];
          return _buildPokemonCard(pokemon);
        },
        childCount: pokemonList.length,
      ),
    );
  }

  // Função para construir o Card do Pokémon
  Widget _buildPokemonCard(Pokemon pokemon) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchPokemonDetails(pokemon.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          var details = snapshot.data;
          if (details == null) {
            return const Center(child: Text("Detalhes não encontrados!"));
          }

          var imageUrl = details['sprites']['front_default'];
          var name = pokemon.name;
          var types = details['types']
              .map((typeDetail) => typeDetail['type']['name'] as String)
              .toList();
          var color = _getColorForType(types[0]);

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              // side: BorderSide(
              //   color: const Color.fromARGB(255, 100, 99, 99),
              //   width: 2,
              // ), // Borda preta
            ),
            color: color,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PokemonDetailPage(pokemonUrl: pokemon.url),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Image.network(
                    imageUrl,
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (var type in types)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: _getColorForType(type)),
                              child: Text(
                                type,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Exibindo os tipos do Pokémon abaixo do nome
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Função para buscar os detalhes do Pokémon
  Future<Map<String, dynamic>> _fetchPokemonDetails(String url) async {
    final dio = Dio();
    final response = await dio.get(url);
    return response.data;
  }

  // Função para filtrar a lista de Pokémons pela pesquisa
  void _filterPokemons(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPokemonList = _pokemonList;
      });
    } else {
      setState(() {
        _filteredPokemonList = _pokemonList
            .where((pokemon) =>
                pokemon.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding:
                      const EdgeInsets.all(8.0), // Adicionando padding ao redor
                  child: CustomScrollView(
                    slivers: [
                      // Barra de pesquisa
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              _filterPokemons(
                                  query); // Filtro dinâmico de Pokémons
                            },
                            decoration: InputDecoration(
                              labelText: 'Pesquise um Pokémon...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Grid de Pokémon
                      _buildPokemonGrid(_filteredPokemonList),
                    ],
                  ),
                ),
    );
  }
}
