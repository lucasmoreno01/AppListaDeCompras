import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'items_list.dart';

class MainListView extends StatefulWidget {
  const MainListView({super.key});

  @override
  State<MainListView> createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  final List<Map<String, dynamic>> _listasDeCompras = [];
  double _somaPrecoLista = 0.0;

  @override
  void initState() {
    super.initState();
    _loadListasDeCompras();
  }

  Future<void> _loadListasDeCompras() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? listasDeComprasString =
        prefs.getStringList('listasDeCompras');
    if (listasDeComprasString != null) {
      setState(() {
        _listasDeCompras.addAll(listasDeComprasString.map((item) {
          final parts = item.split(';');
          return {
            'nome': parts[0],
            'preco': double.parse(parts[1]),
          };
        }).toList());
        _updateSomaPrecoLista(); // Atualiza _somaPrecoLista ao carregar as listas de compras
      });
    }
  }

  void _updateSomaPrecoLista() {
    double total = 0;
    for (var lista in _listasDeCompras) {
      total += lista['preco'];
    }
    setState(() {
      _somaPrecoLista = total;
    });
  }

  Future<void> _saveListasDeCompras() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> listasDeComprasString = _listasDeCompras.map((item) {
      return '${item['nome']};${item['preco']}';
    }).toList();
    prefs.setStringList('listasDeCompras', listasDeComprasString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2F8D6),
      appBar: AppBar(
        title: const Text(
          "Listas",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffD2F8D6),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _listasDeCompras.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    key: Key(_listasDeCompras[index].toString()),
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(
                                0,
                                2,
                              ),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            "Lista ${index + 1}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.black26,
                                  fontSize: 14,
                                ),
                              ),
                              const Divider(),
                              Text(
                                '\$ ${_listasDeCompras[index]['preco'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.red[900],
                              size: 35,
                            ),
                            onPressed: () {
                              setState(() {
                                _listasDeCompras.removeAt(index);
                                _saveListasDeCompras();
                                _updateSomaPrecoLista(); // Atualiza _somaPrecoLista ao remover uma lista
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemsList(
                                  nomeLista: _listasDeCompras[index]['nome'],
                                  precoLista: _listasDeCompras[index]['preco']
                                      .toString(),
                                  somaPrecoLista: _somaPrecoLista,
                                  updateSomaPrecoLista: (double novoTotal) {
                                    setState(() {
                                      _listasDeCompras[index]['preco'] =
                                          novoTotal;
                                      _saveListasDeCompras();
                                      _updateSomaPrecoLista();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF11E333),
              shape: const CircleBorder(),
              onPressed: () {
                setState(() {
                  _listasDeCompras.add({
                    'nome': 'Lista ${_listasDeCompras.length + 1}',
                    'preco': 0.0,
                  });
                  _saveListasDeCompras();
                  _updateSomaPrecoLista(); // Atualiza _somaPrecoLista ao adicionar uma lista
                });
              },
              child: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
