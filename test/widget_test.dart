import 'package:flutter_test/flutter_test.dart';
// IMPORTANTE: Asegúrate de que este nombre coincida con el 'name:' de tu archivo pubspec.yaml
// Si en tu pubspec.yaml dice "name: gestion_trobada", cambia la línea de abajo a:
// import 'package:gestion_trobada/main.dart';
import 'package:gestor_equipo_rugby/main.dart'; 

void main() {
  testWidgets('La pantalla de inicio carga correctamente', (WidgetTester tester) async {
    // 1. Construimos la app y esperamos a que cargue
    await tester.pumpWidget(const MyApp());

    // 2. Verificamos que aparece el título "INICIO"
    expect(find.text('INICIO'), findsOneWidget);

    // 3. Verificamos que aparecen tus botones del menú
    expect(find.text('Editar Plantilla'), findsOneWidget);
    expect(find.text('Empezar Trobada'), findsOneWidget);
    
    // 4. Verificamos que NO hay un contador (prueba de sanidad)
    expect(find.text('0'), findsNothing);
  });
}