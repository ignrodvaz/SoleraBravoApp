# 🚀 Guía Rápida de Implementación - Firebase Auth

## ✅ Lo que ya está hecho

Tu sistema de autenticación ya contiene:

### 📁 Archivos creados:
- `lib/services/auth_service.dart` - Lógica de Firebase
- `lib/providers/auth_provider.dart` - Gestión de estado
- `lib/pages/login_page.dart` - Página de login
- `lib/pages/register_page.dart` - Página de registro
- `lib/pages/auth_integration_example.dart` - Ejemplo de uso
- `lib/utils/auth_utils.dart` - Utilidades y widgets

### 🔧 Cambios en archivos existentes:
- `lib/main.dart` - Integrado Firebase y Provider
- `pubspec.yaml` - Dependencias añadidas

## 🔑 Pasos siguientes (IMPORTANTE)

### 1. Configurar Firebase Console

**⚠️ ESTO ES OBLIGATORIO PARA QUE FUNCIONE**

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar el proyecto (en la carpeta raíz de la app)
cd solerabravoapp
flutterfire configure
```

Este comando:
- ✅ Creará `google-services.json` para Android
- ✅ Creará `GoogleService-Info.plist` para iOS
- ✅ Actualizará automáticamente `firebase_options.dart`

### 2. Crear proyecto en Firebase

1. Ve a https://console.firebase.google.com
2. Crea un nuevo proyecto
3. Habilita **Autenticación** → **Email/Contraseña**
4. Crea **Firestore Database** en modo de prueba

### 3. Ejecutar el proyecto

```bash
flutter pub get
flutter run
```

## 📱 Cómo usar en tu app

### Opción A: Pantalla de login (automática)
Ya está integrada. Si el usuario no está autenticado, ve a `LoginPage`.

### Opción B: Verificar premium en un componente

```dart
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/auth_utils.dart';

// En tu widget
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    if (auth.isPremium) {
      return Text('¡Eres premium! ${auth.user?.displayName}');
    }
    return const Text('Usuario regular');
  },
)
```

### Opción C: Proteger una función solo para premium

```dart
import 'utils/auth_utils.dart';

PremiumOnly(
  child: MyPremiumFeature(),
  fallback: Text('Compra premium para usar esto'),
)
```

### Opción D: Acceso rápido a datos

```dart
// Dentro de cualquier widget
String? email = context.userEmail;
bool isPremium = context.isPremium;
String? userId = context.userId;
```

## 🎯 Flujo de autenticación

```
App inicia
    ↓
Firebase.initializeApp()
    ↓
AuthProvider escucha cambios
    ↓
¿Usuario autenticado?
    ├─ NO  → Muestra LoginPage
    └─ SÍ  → Muestra MainNavigation (tu app actual)
```

## 🧪 Probar sin configurar Firebase (temporal)

Si necesitas probar sin Firebase aún:

```dart
// En lib/main.dart, comenta esta línea temporalmente
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );

// Esto permitirá ver la UI, pero la autenticación no funcionará
```

## 🔐 Estructura de datos en Firestore

Cuando un usuario se registra, se crea en Firestore:

```
firestore/
└── users/
    └── {uid}/
        ├── uid: "abc123..."
        ├── email: "usuario@example.com"
        ├── fullName: "Juan Pérez"
        ├── isPremium: true/false
        ├── createdAt: 2025-01-22T10:30:00Z
        └── updatedAt: 2025-01-22T10:30:00Z
```

## 💡 Ejemplos de uso común

### Mostrar nombre del usuario
```dart
Text(context.userName ?? 'Usuario')
```

### Hacer logout
```dart
context.read<AuthProvider>().logout();
```

### Actualizar perfil
```dart
await context.read<AuthProvider>().updateProfile(
  fullName: 'Juan Nuevo',
  additionalData: {'telefono': '123456'},
);
```

### Mostrar solo si es premium
```dart
if (context.isPremium) {
  // Mostrar función premium
}
```

## 🐛 Errores comunes

### "Firebase not initialized"
→ Ejecuta `flutterfire configure` nuevamente

### "Error en login"
→ Verifica que autenticación esté habilitada en Firebase Console

### "Firestore permission denied"
→ Las reglas de seguridad están en modo prueba. En producción, actualiza:
```firestore
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

## 📚 Estructura final de carpetas

```
lib/
├── main.dart
├── firebase_options.dart
├── services/
│   └── auth_service.dart
├── providers/
│   └── auth_provider.dart
├── pages/
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── auth_integration_example.dart
│   ├── image_editor.dart
│   └── ... (tus otras páginas)
├── utils/
│   └── auth_utils.dart
└── ... (resto de tu app)
```

## 🎉 Próximas funcionalidades opcionales

- [ ] Autenticación con Google/Apple
- [ ] Notificaciones por email
- [ ] Panel de administrador
- [ ] Sistema de suscripción
- [ ] Recuperación de cuenta
- [ ] 2FA (autenticación de dos factores)

## 📞 Soporte

Si necesitas ayuda:
1. Revisa [Firebase Docs](https://firebase.flutter.dev/)
2. Comprueba la consola de Firebase
3. Verifica que `firebase_options.dart` tenga datos correctos

---

**¡Listo para usar!** Ejecuta `flutter run` y disfruta de tu sistema de autenticación. 🚀
