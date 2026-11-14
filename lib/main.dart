import 'package:flutter/material.dart';

import 'app.dart';
import 'pages/login_page.dart';
import 'pages/pairing_page.dart';
import 'pages/route_list_page.dart';
import 'pages/settings_page.dart';
import 'pages/sync_page.dart';

// ---------------------------------------------------------------------------
// Paleta ASADA — colores corporativos coherentes con el backend Odoo.
// ---------------------------------------------------------------------------

/// Colores de la paleta ASADA.
class AsadaColors {
  /// Primario (botones, navbar, headers).
  static const Color primary = Color(0xFF0B4F6C);

  /// Secundario (detalles, iconos).
  static const Color secondary = Color(0xFF17A398);

  /// Acento (alertas, CTAs).
  static const Color accent = Color(0xFFF18F01);

  /// Fondos suaves.
  static const Color lightBg = Color(0xFFE8F4F8);

  /// Textos, contrastes.
  static const Color dark = Color(0xFF083344);

  /// Fondos principales.
  static const Color white = Color(0xFFFFFFFF);
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

/// Página principal que maneja la navegación según autenticación y pairing.
class HomePage extends StatefulWidget {
  final AppDependencies deps;

  HomePage({required this.deps});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPairing();
  }

  Future<void> _loadPairing() async {
    await widget.deps.pairingService.load();
    // Pasar URL del pairing y database al AuthService
    widget.deps.authService
        .setPairingServerUrl(widget.deps.pairingService.serverUrl);
    widget.deps.authService
        .setPairingDbName(widget.deps.pairingService.dbName);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;

    if (!_loaded) {
      return Scaffold(
        backgroundColor: AsadaColors.lightBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Si NO hay pairing → mostrar pantalla de emparejamiento
    if (!deps.pairingService.isPaired) {
      return PairingPage(
        pairingService: deps.pairingService,
        onPaired: () {
          setState(() {});
        },
      );
    }

    // Si no está autenticado → mostrar login simplificado
    if (!deps.authBloc.isLoggedIn) {
      return LoginPage(authBloc: deps.authBloc, routeBloc: deps.routeBloc);
    }

    // Usuario autenticado — mostrar navegación principal
    return _buildMainNavigation(context, deps);
  }

  Widget _buildMainNavigation(BuildContext context, AppDependencies deps) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASADA App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    pairingService: deps.pairingService,
                    onReset: () {
                      // Limpiar sesión también
                      deps.authBloc.logout();
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ],
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bienvenido, ${deps.authBloc.currentUser?.name ?? "Fontanero"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tiene ${deps.meterService.pendingReadings.length} '
                  'lecturas pendientes de sincronizar.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AsadaColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

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

        const SizedBox(height: 12),

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      pairingService: deps.pairingService,
                      onReset: () {
                        deps.authBloc.logout();
                        setState(() {});
                      },
                    ),
                  ),
                );
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AsadaColors.secondary,
                  ),
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
            icon: const Icon(Icons.home),
            tooltip: 'Inicio',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HomePage(deps: deps)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.route),
            tooltip: 'Rutas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RouteListPage(routeBloc: deps.routeBloc),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
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
            icon: const Icon(Icons.person),
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
