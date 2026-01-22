# 📝 Ejemplos de Integración en Páginas Existentes

## 1. Agregar badge Premium en PerfilPage

```dart
// En perfil_page.dart, dentro del build:

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

@override
Widget build(BuildContext context) {
  return Consumer<AuthProvider>(
    builder: (context, authProvider, _) {
      if (!authProvider.isAuthenticated) {
        return const Center(child: Text('No autenticado'));
      }

      return Column(
        children: [
          // Tu contenido actual...
          
          // Agregar esto:
          if (authProvider.isPremium)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber[800], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
```

## 2. Proteger función solo para Premium en ImageEditor

```dart
// En pages/image_editor.dart:

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/auth_utils.dart';

// Envuelve características premium con:
if (context.read<AuthProvider>().isPremium)
  ElevatedButton(
    onPressed: () {
      // Función solo para premium
    },
    child: const Text('Filtros Avanzados (Premium)'),
  )
else
  GestureDetector(
    onTap: () => showPremiumRequiredDialog(context),
    child: const Text('Filtros Avanzados (Premium)'),
  )
```

## 3. Mostrar nombre del usuario en HomePage

```dart
// En main.dart, en la HomePage:

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          children: [
            // Saludo personalizado
            Text(
              'Hola, ${authProvider.user?.displayName ?? 'Usuario'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Tu contenido...
          ],
        );
      },
    );
  }
}
```

## 4. Restricción de acceso a análisis para Premium

```dart
// En mis_analisis_page.dart:

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/auth_utils.dart';

class MisAnalisisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PremiumOnly(
      child: _buildAnalisisContent(),
      fallback: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Análisis Premium'),
            const SizedBox(height: 8),
            const Text('Actualiza tu cuenta para ver tus análisis'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showPremiumRequiredDialog(context),
              child: const Text('Ir a Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalisisContent() {
    // Tu contenido de análisis actual
    return const Text('Tu contenido de análisis');
  }
}
```

## 5. Agregar botón de Logout en PerfilPage

```dart
// En perfil_page.dart:

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

FloatingActionButton(
  onPressed: () async {
    await context.read<AuthProvider>().logout();
  },
  child: const Icon(Icons.logout),
)

// O un botón normal:
ElevatedButton(
  onPressed: () async {
    await context.read<AuthProvider>().logout();
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: const Text('Cerrar sesión'),
)
```

## 6. Usar extensiones de auth en cualquier lado

```dart
// En cualquier widget:
import 'utils/auth_utils.dart';

// Rápido acceso:
String? email = context.userEmail;
String? name = context.userName;
String? userId = context.userId;
bool isPremium = context.isPremium;
bool isAuth = context.isAuthenticated;

// Ejemplos:
Text('Email: ${context.userEmail}')
Text('Usuario: ${context.userName}')

if (context.isPremium) {
  // Mostrar contenido premium
}
```

## 7. Mostrar datos del usuario en un drawer

```dart
// En main.dart, agregar a MainNavigation:

Drawer(
  child: Consumer<AuthProvider>(
    builder: (context, authProvider, _) {
      return ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(authProvider.user?.displayName ?? 'Usuario'),
            accountEmail: Text(authProvider.user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              child: Text(
                authProvider.user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Mi suscripción'),
            subtitle: Text(
              authProvider.isPremium ? 'Premium' : 'Regular',
              style: TextStyle(
                color: authProvider.isPremium ? Colors.amber[800] : null,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await authProvider.logout();
            },
          ),
        ],
      );
    },
  ),
)
```

## 8. Actualizar perfil del usuario

```dart
// En perfil_page.dart, agregar un formulario:

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

TextFormField(
  initialValue: context.read<AuthProvider>().user?.displayName,
  onSaved: (value) async {
    await context.read<AuthProvider>().updateProfile(
      fullName: value ?? '',
    );
  },
)

// O más completo:
ElevatedButton(
  onPressed: () async {
    bool success = await context.read<AuthProvider>().updateProfile(
      fullName: 'Nuevo Nombre',
      additionalData: {
        'ciudad': 'Madrid',
        'telefono': '123456789',
      },
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  },
  child: const Text('Guardar cambios'),
)
```

## 9. Condición basada en premium en MainNavigation

```dart
// En main.dart, puedes agregar tabs diferentes según el rol:

class _MainNavigationState extends State<MainNavigation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          // ... items base
          bottomNavigationBar: BottomNavigationBar(
            items: [
              // Items siempre visibles
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              // Solo si es premium
              if (authProvider.isPremium)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: 'Analytics',
                ),
              // ... más items
            ],
          ),
        );
      },
    );
  }
}
```

## 10. Snackbars personalizados

```dart
// Usa las funciones de utils:
import 'utils/auth_utils.dart';

// En el botón de logout:
showAuthMessage(context, 'Sesión cerrada');

// Error:
showAuthMessage(context, 'Error al guardar', isError: true);
```

---

**Tip:** Importa siempre:
```dart
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/auth_utils.dart';
```

¡Ahora puedes integrar autenticación en toda tu app! 🎉
