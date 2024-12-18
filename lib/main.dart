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
  final _future = Supabase.instance.client.from('tareas').select();
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
        body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final tarea = snapshot.data!;
              return ListView.builder(
                  itemCount: tarea.length,
                  itemBuilder: ((context, index) {
                    final imprimir = tarea[index];
                    return ListTile(
                      title: Text(imprimir['descripcion']),
                    );
                  }));
            }));
  }
}
