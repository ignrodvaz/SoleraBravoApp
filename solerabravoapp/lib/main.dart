import 'package:flutter/material.dart';

void main() {
  runApp(const SoleraBravoApp());
}

class SoleraBravoApp extends StatelessWidget {
  const SoleraBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solera Bravo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        scaffoldBackgroundColor: const Color(0xfff9fafc),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MisAnalisisPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Mis análisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

//
// ---------- HOME PAGE (pestaña Inicio) ----------
//
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildAnalysisCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xff0c1931),
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              "Solera Bravo App",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Premium",
                  style: TextStyle(color: Colors.black, fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Capturar imagen",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text("Tomar foto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0c1931),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.image_outlined),
                label: const Text("Desde galería"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xffd0d4da)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Text("Tipos de análisis",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          buildAnalysisCard(
            title: "Análisis Básico",
            subtitle: "Medición básica de proporciones",
            icon: Icons.bar_chart,
            color: Colors.green,
            label: "Gratis",
          ),
          buildAnalysisCard(
            title: "Análisis Avanzado",
            subtitle: "Medición detallada con IA",
            icon: Icons.analytics_outlined,
            color: Colors.orange,
            label: "Premium",
          ),
          buildAnalysisCard(
            title: "Comparación Histórica",
            subtitle: "Compara con análisis anteriores",
            icon: Icons.history_toggle_off,
            color: Colors.blue,
            label: "Premium",
          ),
          buildAnalysisCard(
            title: "Reporte Premium",
            subtitle: "Informe completo profesional",
            icon: Icons.assignment_outlined,
            color: Colors.purple,
            label: "Premium",
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: const [
              Icon(Icons.lightbulb_outline, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Toma la foto de perfil del caballo con buena iluminación y separado de su entorno.",
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

//
// ---------- MIS ANALISIS PAGE (pestaña) ----------
//
class MisAnalisisPage extends StatelessWidget {
  const MisAnalisisPage({super.key});

  Widget buildAnalysisItem({
    required String title,
    required String date,
    required ImageProvider image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text("Ver"),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text("Descargar"),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text("Compartir"),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyses = [
      {"title": "Análisis #1", "date": "15 ene 2024 · 14:30"},
      {"title": "Análisis #2", "date": "14 ene 2024 · 16:45"},
      {"title": "Análisis #3", "date": "12 ene 2024 · 10:20"},
      {"title": "Análisis #4", "date": "10 ene 2024 · 12:15"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1931),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Si usas la navegación por pestañas, mejor cambiar de índice.
            // Aquí hacemos un pop simple por si se abrió mediante Navigator.
            Navigator.maybePop(context);
          },
        ),
        title: const Text("Mis análisis",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("${analyses.length} análisis guardados",
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: [
              Text("${analyses.length}",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              const Text("Análisis guardados", style: TextStyle(color: Colors.black54)),
            ]),
          ),
          const SizedBox(height: 20),
          for (var a in analyses)
            buildAnalysisItem(
              title: a["title"]!,
              date: a["date"]!,
              image: const AssetImage('assets/images/horse.jpg'),
            ),
        ]),
      ),
    );
  }
}

//
// ---------- PERFIL PAGE (pestaña Perfil) ----------
//
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0,4))],
      ),
      child: Column(children: [
        Icon(icon, color: Colors.amber[700]),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Notar: no BottomNavigationBar aquí (solo en MainNavigation)
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B2A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            width: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              SizedBox(height: 6),
              Text("Mi perfil", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Configuración de cuenta", style: TextStyle(color: Colors.white70)),
            ]),
          ),

          const SizedBox(height: 20),

          // Card usuario
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,4))],
            ),
            child: Row(children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.amber[200], child: const Text("MG", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                SizedBox(height: 2),
                Text("María González", style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text("maria.gonzalez@email.com", style: TextStyle(color: Colors.black54)),
                SizedBox(height: 4),
                Text("Miembro desde junio de 2023", style: TextStyle(fontSize: 12, color: Colors.black45)),
              ])),
              IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
            ]),
          ),

          const SizedBox(height: 20),

          // Estadísticas
          Row(children: [
            Expanded(child: _buildStatCard("45", "Análisis realizados", Icons.bar_chart)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard("4.8", "Calificación promedio", Icons.star)),
          ]),

          const SizedBox(height: 20),

          // Plan premium
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.workspace_premium, color: Colors.amber),
                SizedBox(width: 8),
                Text("Plan Premium", style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              const Text("Disfruta de análisis ilimitados y funciones avanzadas.", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              const Text("Renovación: 15 Feb 2024", style: TextStyle(fontSize: 12, color: Colors.black45)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("Gestionar plan"),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // Configuración
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 6, offset: const Offset(0,4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Configuración", style: TextStyle(fontWeight: FontWeight.w600)),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text("Cambiar contraseña"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text("Notificaciones"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Cerrar sesión", style: TextStyle(color: Colors.redAccent)),
                onTap: () {},
              ),
            ]),
          ),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}