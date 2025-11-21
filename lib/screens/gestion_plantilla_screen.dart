import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';

class GestionPlantillaScreen extends StatefulWidget {
  const GestionPlantillaScreen({super.key});

  @override
  State<GestionPlantillaScreen> createState() => _GestionPlantillaScreenState();
}

class _GestionPlantillaScreenState extends State<GestionPlantillaScreen> {
  final _nameController = TextEditingController();
  bool _esPrimeraLinea = false;
  bool _esFormacion = false;
  bool _sortAsc = true; // Para ordenar

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    // Lógica de ordenación local
    List<Jugador> listaOrdenada = List.from(data.plantilla);
    listaOrdenada.sort((a, b) => _sortAsc 
        ? a.nombre.compareTo(b.nombre) 
        : b.nombre.compareTo(a.nombre));

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('GESTIÓN DE PLANTILLA', style: TextStyle(color: tema.colorPositivo, fontSize: 16)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
        actions: [
          IconButton(
            icon: Icon(_sortAsc ? Icons.sort_by_alpha : Icons.sort, color: tema.colorPositivo),
            onPressed: () => setState(() => _sortAsc = !_sortAsc),
            tooltip: "Ordenar por Nombre",
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FORMULARIO DE CREACIÓN (Sin Dorsal)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tema.bgPanel,
                border: Border.all(color: tema.colorPositivo.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: tema.textoPrincipal),
                    decoration: InputDecoration(
                      labelText: 'Nombre Apellido',
                      labelStyle: TextStyle(color: tema.textoPrincipal.withOpacity(0.5)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: tema.colorPositivo)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text("1a LÍNEA"),
                        selected: _esPrimeraLinea,
                        onSelected: (v) => setState(() => _esPrimeraLinea = v),
                        checkmarkColor: tema.bgPrincipal,
                        selectedColor: tema.colorPositivo,
                        labelStyle: TextStyle(color: _esPrimeraLinea ? tema.bgPrincipal : tema.textoPrincipal),
                      ),
                      const SizedBox(width: 10),
                      FilterChip(
                        label: const Text("FORMACIÓN (F)"),
                        selected: _esFormacion,
                        onSelected: (v) => setState(() => _esFormacion = v),
                        checkmarkColor: tema.bgPrincipal,
                        selectedColor: Colors.orangeAccent,
                        labelStyle: TextStyle(color: _esFormacion ? tema.bgPrincipal : tema.textoPrincipal),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: tema.colorPositivo),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            final nuevo = Jugador(
                              nombre: _nameController.text,
                              // Dorsal se pone a 0 por defecto, se edita en convocatoria
                              dorsal: 0, 
                              esPrimeraLinea: _esPrimeraLinea,
                              esFormacion: _esFormacion,
                            );
                            data.agregarJugador(nuevo);
                            _nameController.clear();
                            setState(() { _esPrimeraLinea = false; _esFormacion = false; });
                          }
                        },
                        child: Text("AÑADIR", style: TextStyle(color: tema.bgPrincipal)),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // LISTA EDITABLE
            Expanded(
              child: ListView.builder(
                itemCount: listaOrdenada.length,
                itemBuilder: (context, index) {
                  final j = listaOrdenada[index];
                  return ListTile(
                    title: Text(j.nombre, style: TextStyle(color: tema.textoPrincipal)),
                    subtitle: Text(j.etiquetas, style: TextStyle(color: tema.colorPositivo, fontSize: 12)),
                    trailing: Icon(Icons.edit, color: Colors.grey, size: 20),
                    onTap: () => _mostrarDialogoEdicion(context, j, data, tema),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEdicion(BuildContext context, Jugador j, DataManager data, dynamic tema) {
    final nameCtrl = TextEditingController(text: j.nombre);
    bool es1a = j.esPrimeraLinea;
    bool esF = j.esFormacion;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDlg) {
          return AlertDialog(
            backgroundColor: tema.bgPanel,
            title: Text("Editar Jugador", style: TextStyle(color: tema.colorPositivo)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: tema.textoPrincipal),
                  decoration: InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    FilterChip(
                      label: const Text("1a"),
                      selected: es1a,
                      onSelected: (v) => setStateDlg(() => es1a = v),
                      selectedColor: tema.colorPositivo,
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: const Text("F"),
                      selected: esF,
                      onSelected: (v) => setStateDlg(() => esF = v),
                      selectedColor: Colors.orangeAccent,
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Borrar jugador
                  Navigator.pop(ctx);
                  data.eliminarJugador(j);
                },
                child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: tema.colorPositivo),
                onPressed: () {
                  // Guardar cambios
                  j.nombre = nameCtrl.text;
                  j.esPrimeraLinea = es1a;
                  j.esFormacion = esF;
                  data.actualizarJugador(); // Guardar en disco
                  Navigator.pop(ctx);
                },
                child: Text("GUARDAR", style: TextStyle(color: tema.bgPrincipal)),
              )
            ],
          );
        }
      ),
    );
  }
}