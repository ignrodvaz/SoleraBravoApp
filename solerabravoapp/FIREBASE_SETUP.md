# Sistema de Autenticación con Firebase - Solera Bravo App

## 📋 Descripción

Sistema completo de registro e inicio de sesión con Firebase para usuarios premium en Flutter.

## 🚀 Características

- ✅ Registro de usuarios con email y contraseña
- ✅ Inicio de sesión seguro
- ✅ Gestión de perfil de usuario
- ✅ Soporte para usuarios premium
- ✅ Recuperación de contraseña
- ✅ Almacenamiento en Firestore
- ✅ Estado de autenticación persistente
- ✅ Manejo de errores en español

## 📦 Instalación

### 1. Dependencias instaladas

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.0
cloud_firestore: ^5.5.0
provider: ^6.4.2
flutter_dotenv: ^5.1.0
```

### 2. Configurar Firebase Console

#### a) Crear proyecto en Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Haz clic en "Crear proyecto"
3. Sigue los pasos de configuración

#### b) Configurar autenticación
1. En Firebase Console, ve a **Autenticación**
2. Selecciona la pestaña **Métodos de acceso**
3. Habilita **Email/Contraseña**
4. Habilita **Acceso anónimo** (opcional)

#### c) Configurar Firestore
1. Ve a **Firestore Database**
2. Haz clic en **Crear base de datos**
3. Selecciona **Iniciar en modo de prueba** (para desarrollo)
4. Elige la ubicación

#### d) Crear estructura de Firestore

En Firestore, crea la siguiente estructura:

```
users/
  {uid}/
    uid: string
    email: string
    fullName: string
    isPremium: boolean
    createdAt: timestamp
    updatedAt: timestamp
```

### 3. Configurar FlutterFire

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar el proyecto
flutterfire configure
```

Este comando generará automáticamente:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- Actualizará `firebase_options.dart`

### 4. Actualizar `firebase_options.dart`

El archivo `firebase_options.dart` se genera automáticamente con `flutterfire configure`, pero también puedes configurarlo manualmente con tus credenciales de Firebase.

## 📁 Estructura de archivos

```
lib/
├── main.dart                    # Punto de entrada + AuthWrapper
├── firebase_options.dart        # Configuración de Firebase
├── services/
│   └── auth_service.dart       # Lógica de autenticación
├── providers/
│   └── auth_provider.dart      # Provider para estado de auth
└── pages/
    ├── login_page.dart         # Página de inicio de sesión
    └── register_page.dart      # Página de registro
```

## 🔐 Uso

### 1. Login

```dart
// En tu página, accede al AuthProvider
final authProvider = context.read<AuthProvider>();

// Iniciar sesión
bool success = await authProvider.login(
  email: 'usuario@example.com',
  password: 'password123',
);

if (success) {
  // Usuario autenticado
}
```

### 2. Registro

```dart
bool success = await authProvider.register(
  email: 'nuevo@example.com',
  password: 'password123',
  fullName: 'Juan Pérez',
  isPremium: true, // true para usuarios premium
);

if (success) {
  // Cuenta creada exitosamente
}
```

### 3. Cerrar sesión

```dart
await authProvider.logout();
```

### 4. Verificar si es usuario premium

```dart
bool isPremium = authProvider.isPremium;
if (isPremium) {
  // Mostrar funciones premium
}
```

### 5. Obtener datos del usuario actual

```dart
User? currentUser = authProvider.user;
if (currentUser != null) {
  print(currentUser.email);
  print(currentUser.displayName);
}
```

### 6. Acceso en toda la app

Gracias al `AuthWrapper`, puedes:
- Mostrar `LoginPage` si el usuario no está autenticado
- Mostrar `MainNavigation` si el usuario está autenticado

## 🛡️ Reglas de seguridad en Firestore

Para producción, actualiza las reglas en Firestore:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir que los usuarios solo accedan a sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## 🚨 Solución de problemas

### "El proyecto no está configurado"
- Asegúrate de ejecutar `flutterfire configure`
- Verifica que tus credenciales de Firebase sean correctas

### "Error: MissingPluginException"
- Ejecuta `flutter pub get`
- Ejecuta `flutter clean`
- Reconstruye el proyecto

### "No se puede conectar a Firebase"
- Verifica la conexión a internet
- Comprueba que Firebase esté habilitado en tu proyecto
- Verifica las reglas de seguridad de Firestore

## 📱 Funcionalidades adicionales

### Actualizar perfil
```dart
await authProvider.updateProfile(
  fullName: 'Nuevo Nombre',
  additionalData: {
    'telefono': '+34123456789',
    'ciudad': 'Madrid',
  },
);
```

### Restablecer contraseña
```dart
await authProvider.resetPassword('usuario@example.com');
```

## 🎨 Personalización

Las páginas de login y registro están diseñadas con tema ámbar para coincidir con tu app. Puedes personalizar:

- Colores en `Colors.amber[800]`
- Iconos en `Icon(Icons.xxx)`
- Textos según tus necesidades
- Validaciones de campos

## ⚙️ Variables de entorno

Opcionalmente, puedes usar un archivo `.env`:

```
FIREBASE_API_KEY=tu_clave
FIREBASE_PROJECT_ID=tu_proyecto
```

Y cargarlas en `main.dart`:

```dart
await dotenv.load();
```

## 📚 Documentación oficial

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

## 🤝 Próximos pasos

1. Configura las notificaciones push con Firebase Cloud Messaging
2. Implementa verificación de email
3. Agrega autenticación social (Google, Apple)
4. Crea un panel de administrador para gestionar usuarios premium
5. Implementa suscripciones con RevenueCat o similar

---

**¡Listo!** Tu sistema de autenticación con Firebase está configurado. 🎉
