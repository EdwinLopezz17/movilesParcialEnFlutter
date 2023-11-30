import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Personas extends StatefulWidget {
  @override
  _PersonasState createState() => _PersonasState();
}

class _PersonasState extends State<Personas> {
  final TextEditingController _cantidadController = TextEditingController();
  List<Map<String, dynamic>> personasList = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'favoritos.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE favoritos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            name TEXT,
            gender TEXT,
            city TEXT,
            foto TEXT
          )
        ''');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de Personas',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _mostrarPersonas();
              },
              child: Text('Mostrar Personas'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: personasList.length,
                itemBuilder: (context, index) {
                  final persona = personasList[index];
                  return ListTile(
                    title: Text('Nombre: ${persona['name']['first']} ${persona['name']['last']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${persona['email']}'),
                        Text('Celular: ${persona['cell']}'),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(persona['picture']['thumbnail']),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite),
                      onPressed: () {
                        _agregarAFavoritos(persona);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarPersonas() async {
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;

    if (cantidad > 0) {
      final response = await http.get(Uri.parse('https://randomuser.me/api/?results=$cantidad'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('results')) {
          setState(() {
            personasList = List<Map<String, dynamic>>.from(data['results']);
          });
        }
      } else {
        throw Exception('Failed to load personas');
      }
    } else {
      print('Ingrese una cantidad válida de personas');
    }
  }

  Future<void> _agregarAFavoritos(Map<String, dynamic> persona) async {
    await _database?.insert(
      'favoritos',
      {
        'title': persona['name']['title'],
        'name': persona['name']['first'],
        'gender': persona['gender'],
        'city': persona['location']['city'],
        'foto': persona['picture']['thumbnail'],
      },
    );
  }

}
