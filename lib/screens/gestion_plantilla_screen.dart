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
  bool _esFormacion = false; 
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    // Lógica de ordenación
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
            // FORMULARIO DE CREACIÓN
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
                      // ARREGLO VISUAL DEL BOTÓN FORMACIÓN (NEGRO SI NO PULSADO)
                      FilterChip(
                        label: const Text("FORMACIÓN (F)"),
                        selected: _esFormacion,
                        onSelected: (v) => setState(() => _esFormacion = v),
                        checkmarkColor: tema.bgPrincipal,
                        
                        // ESTADO SELECCIONADO (Pulsado)
                        selectedColor: Colors.orangeAccent,
                        
                        // ESTADO NO SELECCIONADO (Sin pulsar)
                        backgroundColor: Colors.transparent, 
                        
                        // Borde: Naranja si pulsado, Color Texto Principal si no
                        side: BorderSide(
                          color: _esFormacion ? Colors.transparent : tema.textoPrincipal.withOpacity(0.5)
                        ),
                        
                        // Texto: Color fondo si pulsado, NEGRO (o contraste fuerte) si no
                        labelStyle: TextStyle(
                          // Aquí forzamos el color del texto no seleccionado
                          // Si quieres que se vea siempre bien, usa el color del texto principal del tema
                          // Si el tema es oscuro, el texto será blanco. Si es claro, será negro.
                          color: _esFormacion ? tema.bgPrincipal : tema.textoPrincipal,
                          fontWeight: _esFormacion ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: tema.colorPositivo),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            final nuevo = Jugador(
                              nombre: _nameController.text,
                              dorsal: 0, 
                              esPrimeraLinea: false, 
                              esFormacion: _esFormacion,
                            );
                            data.agregarJugador(nuevo);
                            _nameController.clear();
                            setState(() { _esFormacion = false; });
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
                    subtitle: j.esFormacion 
                        ? const Text("Formación (F)", style: TextStyle(color: Colors.orangeAccent, fontSize: 12))
                        : null,
                    trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
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
                  decoration: const InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Mismo arreglo visual en el diálogo
                    FilterChip(
                      label: const Text("Formación (F)"),
                      selected: esF,
                      onSelected: (v) => setStateDlg(() => esF = v),
                      checkmarkColor: tema.bgPrincipal,
                      selectedColor: Colors.orangeAccent,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: esF ? Colors.transparent : tema.textoPrincipal.withOpacity(0.5)),
                      labelStyle: TextStyle(
                        color: esF ? tema.bgPrincipal : tema.textoPrincipal,
                        fontWeight: esF ? FontWeight.bold : FontWeight.normal
                      ),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  data.eliminarJugador(j);
                },
                child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: tema.colorPositivo),
                onPressed: () {
                  j.nombre = nameCtrl.text;
                  j.esFormacion = esF;
                  data.actualizarJugador();
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