import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetails();
  }

  Future<void> _fetchPokemonDetails() async {
    final dio = Dio();
    final response = await dio.get(widget.pokemonUrl);
    _pokemonDetails = PokemonDetails.fromMap(response.data);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: 80,
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
                  top: 130,
                  left: 20,
                  child: Row(
                    children: _pokemonDetails.types.map((type) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                  top: 180,
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
                  initialChildSize: 0.55,
                  minChildSize: 0.55,
                  maxChildSize: 0.85,
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
                              padding: EdgeInsets.all(40),
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
        return Text("Informações de evolução aqui");
      case "info":
      default:
        return _buildInformacoesBasicas(_pokemonDetails);
    }
  }

  Card _buildHabilidades(PokemonDetails pokemon) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Container(
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
            ...pokemon.abilities
                .map((ability) => Text(
                      "- $ability",
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Card _buildInformacoesBasicas(PokemonDetails pokemon) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              "Informações",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text("Altura: ${pokemon.height} m"),
            Text("Peso: ${pokemon.weight} kg"),
          ],
        ),
      ),
    );
  }
}
