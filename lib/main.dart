import 'package:flutter/material.dart';
import 'configuraciones/configuraciones.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    await Supabase.initialize(
      url: Configuraciones.supabaseurl,
      anonKey: Configuraciones.supabaseanonKey,
    );
  } catch (e) {
    print('Error inicializando Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 41, 87, 68)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => ListaTareas();
}

class ListaTareas extends State<MyHomePage> {
  String connectionStatus = "Presiona el botón para verificar la conexión";
  final supabase = Supabase.instance.client;
  final _taskController = TextEditingController();

  Future<List<dynamic>> hacerQuery() async {
    //metodo para verificar que recibimos bien la lista de datos
    try {
      final List<dynamic> query = await supabase.from('tareas').select();

      return query;
    } catch (e) {
      print('Error obteniendo tareas: $e');
      throw Exception('Error obteniendo datos: $e');
    }
  }

  Future<void> agregarTarea(String descripcion) async {
    try {
      final query = await supabase.from('tareas').insert([
        {'descripcion': descripcion}
      ]);
      setState(() {}); //actualiza la pantalla
    } catch (e) {
      print('Algo salio mal $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tareas').delete().eq('id', id);
      setState(() {});
    } catch (e) {
      print('Error al eliminar $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                if (supabase != Null) {
                  setState(() {
                    connectionStatus = 'Supabase configurado correctamente.';
                  });
                } else {
                  setState(() {
                    connectionStatus = 'Supabase no está configurado.';
                  });
                }
                print(connectionStatus);
              },
              icon: const Icon(Icons.dataset)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'tarea nueva',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                agregarTarea(_taskController.text);
                _taskController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa una tarea')),
                );
              }
            },
            child: Icon(Icons.add),
          ),
          Expanded(
              child: FutureBuilder<List<dynamic>>(
            future: hacerQuery(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('NO HAY DATOS'));
                  }

                  final tarea = snapshot.data!;
                  return ListView.builder(
                      itemCount: tarea.length,
                      itemBuilder: ((context, index) {
                        final imprimir = tarea[index];
                        return ListTile(
                          title: Text(imprimir['descripcion']),
                          trailing: IconButton(
                              onPressed: () {
                                delete(imprimir['id']);
                              },
                              icon: Icon(Icons.remove)),
                        );
                      }));

                default:
                  return const Center(child: Text('Cargando...'));
              }
            },
          ))
        ],
      ),
    );
  }
}
