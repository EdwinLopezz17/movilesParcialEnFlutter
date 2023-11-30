import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoritosView extends StatefulWidget {
  @override
  _FavoritosViewState createState() => _FavoritosViewState();
}

class _FavoritosViewState extends State<FavoritosView> {
  List<Map<String, dynamic>> favoritosList = [];
  FavoritosHelper favoritosHelper = FavoritosHelper();

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final favoritos = await favoritosHelper.getFavoritos();
    setState(() {
      favoritosList = List<Map<String, dynamic>>.from(favoritos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favoritos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: favoritosList.isEmpty
            ? Center(
          child: Text("No hay usuarios favoritos."),
        )
            : ListView.builder(
          itemCount: favoritosList.length,
          itemBuilder: (context, index) {
            final persona = favoritosList[index];
            return ListTile(
              title: Text(
                'Title: ${persona['title']}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${persona['name']}'),
                  Text('Género: ${persona['gender']}'),
                  Text('Ciudad: ${persona['city']}'),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(persona['foto']),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _eliminarDeFavoritos(persona['id']);
                },
              ),
            );
          },
        ),
      ),
    );
  }
  void _eliminarDeFavoritos(int id) async {
    await favoritosHelper.eliminarDeFavoritos(id);
    _cargarFavoritos();
  }

}


class FavoritosHelper {
  Database? _database;

  Future<void> open() async {
    if (_database == null) {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'favoritos.db');
      _database = await openDatabase(path, version: 1);
    }
  }

  Future<List<Map<String, dynamic>>> getFavoritos() async {
    await open();
    return await _database!.query('favoritos');
  }

  Future<void> eliminarDeFavoritos(int id) async {
    await open();
    await _database!.delete('favoritos', where: 'id = ?', whereArgs: [id]);
  }
}