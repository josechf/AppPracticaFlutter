import 'package:flutter/material.dart';
import 'configuraciones/configuraciones.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: Configuraciones.supabaseurl,
    anonKey: Configuraciones.supabaseanonKey,
  );
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
  List<String> tareas = ["estudiar", "gym", "comer"];
  final TextEditingController TextoTemporal = TextEditingController();
  String connectionStatus = "Presiona el botón para verificar la conexión";
  final supabase = Supabase.instance.client;

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
            Flexible(
              flex: 2,
              child: ListView.builder(
                itemCount: tareas.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 75, 212, 137),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(tareas[index]),
                      ),
                      trailing: IconButton(
                        //boton de uso secundario, dentro de cada widget
                        onPressed: () {
                          setState(() {
                            tareas.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete),
                        tooltip: "delete",
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextoTemporal,
                      decoration: const InputDecoration(
                        hintText: 'nueva tarea',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Agregar();
                      },
                      child: const Text("agregar")),
                ],
              ),
            ),
          ],
        ));
  }

  void Agregar() {
    if (TextoTemporal.text.isNotEmpty) {
      setState(() {
        tareas.add(TextoTemporal.text);
      });
    }
  }
}
