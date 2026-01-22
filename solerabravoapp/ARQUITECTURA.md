# 🏗️ Arquitectura del Sistema de Autenticación

## Diagrama de Flujo General

```
┌────────────────────────────────────────────────────────────────┐
│                      SOLERA BRAVO APP                          │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   main.dart      │
                    │  (punto entrada) │
                    └─────────┬────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
        ┌─────────────┐ ┌──────────┐ ┌────────────┐
        │Firebase.    │ │ Multi    │ │ AuthWrapper│
        │initializeApp│ │Provider  │ │            │
        └─────────────┘ └────┬─────┘ └────┬───────┘
                             │             │
                    ┌────────┴─────────┐   │
                    │                  │   │
                    ▼                  ▼   ▼
            ┌──────────────────┐   ┌──────────────┐
            │  AuthProvider    │   │ LoginPage/   │
            │  (ChangeNotifier)│   │ RegisterPage │
            └────────┬─────────┘   └──────┬───────┘
                     │                     │
                     └──────────┬──────────┘
                                │
                    ┌───────────▼─────────────┐
                    │   AuthService          │
                    │  (Firebase Auth/Store) │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼─────────────┐
                    │   Firebase             │
                    │ (Auth + Firestore)     │
                    └───────────────────────┘
```

---

## Estructura de Capas

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTACIÓN (UI)                        │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ LoginPage   │  │RegisterPage  │  │MainNavigation    │   │
│  │             │  │              │  │(AuthWrapper)     │   │
│  └──────┬──────┘  └────────┬─────┘  └────────┬─────────┘   │
│         │                  │                  │             │
├─────────┼──────────────────┼──────────────────┼─────────────┤
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                │
│                    ESTADO (Provider)                        │
│              ┌─────────────▼──────────────┐                 │
│              │    AuthProvider            │                 │
│              │  (ChangeNotifier)          │                 │
│              │  - user                    │                 │
│              │  - isPremium               │                 │
│              │  - isLoading               │                 │
│              │  - errorMessage            │                 │
│              └─────────────┬──────────────┘                 │
│                            │                                │
├────────────────────────────┼────────────────────────────────┤
│                            │                                │
│                    LÓGICA (Service)                         │
│              ┌─────────────▼──────────────┐                 │
│              │    AuthService             │                 │
│              │  - registerWithEmail()     │                 │
│              │  - signInWithEmail()       │                 │
│              │  - signOut()               │                 │
│              │  - updateUserProfile()    │                 │
│              │  - resetPassword()         │                 │
│              └─────────────┬──────────────┘                 │
│                            │                                │
├────────────────────────────┼────────────────────────────────┤
│                            │                                │
│                  BACKEND (Firebase)                         │
│              ┌─────────────▼──────────────┐                 │
│              │  Firebase Auth             │                 │
│              │  + Cloud Firestore         │                 │
│              └────────────────────────────┘                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Flujo de Autenticación - Registro

```
Usuario
   │
   │ (Ingresa datos)
   ▼
┌──────────────────┐
│  RegisterPage    │
│  Valida campos   │
└────────┬─────────┘
         │
         │ (Llama register())
         ▼
┌──────────────────┐
│  AuthProvider    │
│  Inicia carga    │
└────────┬─────────┘
         │
         │ (Llama authService)
         ▼
┌──────────────────┐
│  AuthService     │
│  createUser()    │
└────────┬─────────┘
         │
         │ (Conecta a)
         ▼
┌──────────────────┐
│  Firebase Auth   │
│  Crea usuario    │
└────────┬─────────┘
         │
         │ (Guarda datos)
         ▼
┌──────────────────┐
│  Firestore DB    │
│  users/{uid}     │
└────────┬─────────┘
         │
         │ (Retorna éxito)
         ▼
┌──────────────────┐
│  AuthProvider    │
│  Actualiza state │
│  notifyListeners │
└────────┬─────────┘
         │
         │ (UI se reconstruye)
         ▼
┌──────────────────┐
│  MainNavigation  │
│  (App principal) │
└──────────────────┘
```

---

## Flujo de Autenticación - Login

```
Usuario                  AuthProvider           AuthService          Firebase
   │                          │                      │                   │
   ├─ Ingresa email/pass ─────▶│                      │                   │
   │                          │                      │                   │
   │                          ├─ signInWith Email ──▶│                   │
   │                          │                      ├─ Auth Firebase ───▶│
   │                          │                      │                   │
   │                          │                      │◀─ Token JWT ───────┤
   │                          │◀─ UserCredential ────┤                   │
   │                          │                      │                   │
   │                          ├─ Escucha cambios ────────────────────────▶│
   │                          │                      │                   │
   │                          │◀──────── user stream ────────────────────│
   │                          │                      │                   │
   │                          ├─ isPremium ─────────▶│                   │
   │                          │                      ├─ Query Firestore ▶│
   │                          │                      │                   │
   │                          │◀─ isPremium ────────┤◀─ Datos usuario ──┤
   │                          │                      │                   │
   │                    notifyListeners              │                   │
   │◀─────── Redibuja UI ─────┤                      │                   │
   │                          │                      │                   │
   ▼                          │                      │                   │
MainNavigation              │                      │                   │
   │                          │                      │                   │
   ✓ Autenticado              │                      │                   │
```

---

## Estructura de Datos - Usuario

```
Authentication (Firebase Auth)
├── UID: "abc123xyz..."
├── Email: "usuario@example.com"
├── Password: "***.hasheada***"
└── Verificado: false/true

Firestore Database
└── users/
    └── abc123xyz.../
        ├── uid: "abc123xyz..."
        ├── email: "usuario@example.com"
        ├── fullName: "Juan Pérez García"
        ├── isPremium: true/false
        ├── createdAt: Timestamp(2025-01-22)
        ├── updatedAt: Timestamp(2025-01-22)
        └── [campos adicionales opcionales]
```

---

## Gestión de Estado - AuthProvider

```
┌─────────────────────────────────────┐
│       AuthProvider                  │
│   (ChangeNotifier)                  │
├─────────────────────────────────────┤
│  ESTADO                             │
│  ├─ _user: User?                    │
│  ├─ _isLoading: bool                │
│  ├─ _errorMessage: String?          │
│  ├─ _isPremium: bool                │
│  ├─ _firebaseAuth: FirebaseAuth     │
│  └─ _firestore: Firestore           │
├─────────────────────────────────────┤
│  MÉTODOS                            │
│  ├─ register()                      │
│  ├─ login()                         │
│  ├─ logout()                        │
│  ├─ updateProfile()                 │
│  ├─ resetPassword()                 │
│  └─ clearError()                    │
├─────────────────────────────────────┤
│  GETTERS                            │
│  ├─ user                            │
│  ├─ isLoading                       │
│  ├─ errorMessage                    │
│  ├─ isPremium                       │
│  └─ isAuthenticated                 │
├─────────────────────────────────────┤
│  LISTENERS                          │
│  └─ authStateChanges() stream       │
│     (escucha cambios de Firebase)   │
└─────────────────────────────────────┘
```

---

## Componentes UI

```
LoginPage
├── Header con gradiente
├── Formulario
│   ├── TextField email
│   ├── TextField contraseña
│   ├── Link "Olvide contraseña"
│   └── Validaciones
├── Botón de login
├── Link a registro
└── Manejo de errores

RegisterPage
├── Header con gradiente
├── Formulario
│   ├── TextField nombre
│   ├── TextField email
│   ├── TextField contraseña
│   ├── TextField confirmar contraseña
│   ├── CheckBox "Registrar como Premium"
│   └── CheckBox "Aceptar términos"
├── Botón de registro
├── Link a login
└── Manejo de errores

AuthWrapper
└── Consumer<AuthProvider>
    ├── Si autenticado → MainNavigation
    └── Si no → LoginPage
```

---

## Flujo de Seguridad

```
┌──────────────────┐
│ Usuario ingresa  │
│ datos            │
└────────┬─────────┘
         │
         ▼
┌────────────────────────┐
│ Validación en Cliente  │
│ - Email válido         │
│ - Password >= 6 chars  │
│ - Campos requeridos    │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│ Envía a Firebase Auth  │
│ (HTTPS)                │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│ Firebase valida        │
│ - Email formato        │
│ - Password strength    │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│ Hash Password          │
│ bcrypt + salt          │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│ Genera JWT Token       │
│ Expira en 1 hora       │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│ Retorna a Cliente      │
│ Token + User Data      │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│ LocalStorage (seguro)  │
│ Persiste sesión        │
└────────────────────────┘
```

---

## Comunicación entre Capas

```
UI Layer (Pages)
    ↑ setState / Consumer
    │
    ├─ widgets.build()
    │
    └──▶ context.read<AuthProvider>()
             │
             ▼
Provider Layer
    ├─ register(email, pass, name, isPremium)
    ├─ login(email, password)
    ├─ logout()
    ├─ updateProfile(name, data)
    │
    └──▶ _authService.method()
             │
             ▼
Service Layer
    ├─ _firebaseAuth.createUserWithEmailAndPassword()
    ├─ _firebaseAuth.signInWithEmailAndPassword()
    ├─ _firebaseAuth.signOut()
    ├─ _firestore.collection('users').doc(uid).set()
    │
    └──▶ Firebase Backend
             │
             ▼
Backend (Firebase)
    ├─ Firebase Auth
    │   └─ users, passwords, sessions
    │
    └─ Firestore DB
        └─ users collection
```

---

## Patrón de Manejo de Errores

```
FirebaseAuthException
        │
        ├─ email-already-in-use
        │   └─ "El email ya está registrado"
        │
        ├─ invalid-email
        │   └─ "Email inválido"
        │
        ├─ weak-password
        │   └─ "La contraseña es muy débil"
        │
        ├─ user-not-found
        │   └─ "Usuario no encontrado"
        │
        ├─ wrong-password
        │   └─ "Contraseña incorrecta"
        │
        └─ too-many-requests
            └─ "Demasiados intentos fallidos"

                ↓
            _getErrorMessage()
                ↓
        authProvider.errorMessage
                ↓
        Mostrado en UI
```

---

## Integración en la App

```
main.dart
├── MultiProvider
│   ├── ChangeNotifierProvider(AuthProvider)
│   └── (otros providers)
│
└── MaterialApp
    └── home: AuthWrapper
        ├── Consumer<AuthProvider>
        │   ├── Si !isAuthenticated
        │   │   └─ LoginPage
        │   │
        │   └─ Si isAuthenticated
        │       └─ MainNavigation
        │           ├─ HomePage
        │           ├─ MisAnalisisPage
        │           └─ PerfilPage
        │
        └── (disponible en toda la app)
            └── context.read<AuthProvider>()
```

---

**Esta arquitectura asegura:**
- ✅ Separación de responsabilidades
- ✅ Facilidad de testing
- ✅ Reutilización de código
- ✅ Escalabilidad
- ✅ Mantenibilidad
