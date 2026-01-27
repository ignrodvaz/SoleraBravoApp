# 🔐 Configuración de Seguridad en Firebase

## 1. Reglas de Firestore

Ve a Firebase Console → Tu Proyecto → Firestore Database → Rules

Reemplaza con estas reglas:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura/escritura de datos de usuario solo al propietario
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Permitir lectura/escritura de análisis solo al propietario
      match /analyses/{analysisId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

## 2. Reglas de Storage

Ve a Firebase Console → Tu Proyecto → Storage → Rules

Reemplaza con estas reglas:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir lectura/escritura en la carpeta personal de análisis
    match /users/{userId}/analyses/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Negar acceso a todo lo demás
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## 3. Verificar Configuración

### Paso 1: Firestore Rules
1. Abre Firebase Console
2. Ve a Firestore Database
3. Haz clic en Rules
4. Copia y pega las reglas de Firestore arriba
5. Haz clic en Publish

### Paso 2: Storage Rules
1. Ve a Storage
2. Haz clic en Rules
3. Copia y pega las reglas de Storage arriba
4. Haz clic en Publish

### Paso 3: Probar en Desarrollo
Opcional - Si quieres probar sin autenticación:

```
// ⚠️ SOLO PARA DESARROLLO - NUNCA EN PRODUCCIÓN
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## 4. Configuración de Autenticación

En Firebase Console → Authentication:

1. ✅ Email/Password - Ya está configurado
2. ✅ Google Sign-In - Ya está configurado
3. Verifica que los métodos estén habilitados

## 5. Estructura de Datos Esperada

Cuando se cree el primer análisis, se verá así en Firestore:

```
Firestore
└── users
    └── {userId} (ejemplo: tVJ7K2pGfhF9sK3pL2m8)
        ├── email: "usuario@email.com"
        ├── fullName: "Juan Carlos"
        ├── isPremium: true
        └── analyses
            └── {analysisId1} (ejemplo: abc123def456)
                ├── title: "Análisis - 27/1/2026"
                ├── type: "Análisis Básico"
                ├── imageUrl: "https://firebasestorage.googleapis.com/..."
                ├── createdAt: Timestamp (27 de enero 2026)
                └── notes: "Caballo en posición de lado"
```

Storage:
```
users/{userId}/analyses/analisis_{userId}_{timestamp}.png
```

## ✅ Checklist

- [ ] Reglas de Firestore configuradas
- [ ] Reglas de Storage configuradas
- [ ] Autenticación habilitada
- [ ] Usuario registrado y autenticado
- [ ] Probaste a guardar un análisis
- [ ] Verificaste que solo ves tus análisis
- [ ] Probaste eliminar un análisis

