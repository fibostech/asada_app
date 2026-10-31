import 'package:flutter/material.dart';

import 'app.dart';
import 'pages/login_page.dart';
import 'pages/route_list_page.dart';
import 'pages/sync_page.dart';

// ---------------------------------------------------------------------------
// Paleta ASADA — colores corporativos coherentes con el backend Odoo.
// ---------------------------------------------------------------------------

/// Colores de la paleta ASADA.
class AsadaColors {
  /// Primario (botones, navbar, headers).
  static const Color primary = const Color(0xFF0B4F6C);

  /// Secundario (detalles, iconos).
  static const Color secondary = const Color(0xFF17A398);

  /// Acento (alertas, CTAs).
  static const Color accent = const Color(0xFFF18F01);

  /// Fondos suaves.
  static const Color lightBg = const Color(0xFFE8F4F8);

  /// Textos, contrastes.
  static const Color dark = const Color(0xFF083344);

  /// Fondos principales.
  static const Color white = const Color(0xFFFFFFFF);
}

// ---------------------------------------------------------------------------
// Punto de entrada de la aplicación.
// ---------------------------------------------------------------------------

void main() {
  runApp(AsadaApp());
}

/// Widget raíz de la aplicación ASADA.
class AsadaApp extends StatelessWidget {
  AsadaApp();

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies();

    return MaterialApp(
      title: 'ASADA App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AsadaColors.primary),
        useMaterial3: true,
      ),
      home: HomePage(deps: deps),
    );
  }
}

/// Página principal que maneja la navegación según autenticación.
class HomePage extends StatefulWidget {
  final AppDependencies deps;

  HomePage({required this.deps});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;

    // Si no está autenticado, mostrar login
    if (!deps.authBloc.isLoggedIn) {
      return LoginPage(authBloc: deps.authBloc, routeBloc: deps.routeBloc);
    }

    // Usuario autenticado — mostrar navegación principal
    return _buildMainNavigation(context, deps);
  }

  Widget _buildMainNavigation(BuildContext context, AppDependencies deps) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ASADA App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildDashboard(context, deps),
      bottomNavigationBar: _buildBottomNav(context, deps),
    );
  }

  Widget _buildDashboard(BuildContext context, AppDependencies deps) {
    return Column(
      children: [
        // Bienvenida
        Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bienvenido, ${deps.authBloc.currentUser?.name ?? "Fontanero"}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tiene ${deps.meterService.pendingReadings.length} '
                  'lecturas pendientes de sincronizar.',
                  style: TextStyle(fontSize: 14, color: AsadaColors.secondary),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Accesos rápidos
        Row(
          children: [
            _quickAccessCard(
              context,
              Icons.route,
              'Rutas',
              'Ver mis rutas asignadas',
              AsadaColors.primary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RouteListPage(routeBloc: deps.routeBloc),
                  ),
                );
              },
            ),
            _quickAccessCard(
              context,
              Icons.sync,
              'Sincronizar',
              'Enviar lecturas pendientes',
              AsadaColors.secondary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SyncPage(syncBloc: deps.syncBloc),
                  ),
                );
              },
            ),
          ],
        ),

        SizedBox(height: 12),

        Row(
          children: [
            _quickAccessCard(
              context,
              Icons.history,
              'Historial',
              'Lecturas anteriores',
              AsadaColors.dark,
              () {
                // Navegar a historial
              },
            ),
            _quickAccessCard(
              context,
              Icons.settings,
              'Ajustes',
              'Configuración de la app',
              AsadaColors.secondary,
              () {
                // Navegar a ajustes
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAccessCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: () => onTap(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: AsadaColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppDependencies deps) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Inicio',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomePage(deps: deps)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.route),
            tooltip: 'Rutas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RouteListPage(routeBloc: deps.routeBloc),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SyncPage(syncBloc: deps.syncBloc),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              // Perfil / Cerrar sesión
            },
          ),
        ],
      ),
    );
  }
}