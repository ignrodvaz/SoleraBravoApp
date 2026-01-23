# Configuración de Google Sign-In

Este documento describe los pasos necesarios para configurar Google Sign-In en la aplicación.

## 1. Firebase Console Setup

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto "Solera Bravo"
3. Ve a **Authentication** > **Sign-in method**
4. Habilita **Google** como proveedor de Sign-in

## 2. Configuración de Android

### 2.1 SHA-1 Certificate Fingerprint

1. En la terminal, ejecuta:
```bash
cd android
./gradlew signingReport
```

2. Copia el valor de SHA-1 para el build type "debug"

3. Ve a [Firebase Console](https://console.firebase.google.com)
4. En tu proyecto, ve a **Project Settings** (rueda de engranaje) > **Your apps**
5. Haz clic en tu app de Android
6. Desplázate a **SHA certificate fingerprints**
7. Haz clic en **Add fingerprint**
8. Pega el SHA-1 que copiaste

### 2.2 Descarga el archivo google-services.json

1. En Firebase Console, descarga el archivo `google-services.json`
2. Colócalo en `android/app/google-services.json` (ya debería estar allí)

## 3. Configuración de iOS

### 3.1 Info.plist

El plugin `google_sign_in` requiere configuración en `ios/Runner/Info.plist`:

1. Abre `ios/Runner/Info.plist`
2. Añade la siguiente configuración:

```xml
<key>GIDClientID</key>
<string>TU_GOOGLE_CLIENT_ID.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.TU_GOOGLE_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Para obtener tu `GOOGLE_CLIENT_ID`:
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Ve a **Project Settings** > **Service Accounts**
3. Descarga la clave privada JSON
4. Busca el campo `client_id` en el JSON

## 4. Prueba de Google Sign-In

1. Ejecuta la app:
```bash
flutter run
```

2. En la pantalla de login, haz clic en "Iniciar sesión con Google"
3. Se abrirá el diálogo de Google Sign-In
4. Selecciona una cuenta de Google
5. La app debería autenticarte y llevarte a la pantalla principal

## Solución de problemas

### Error: "The request for this plugin could not be satisfied"
- Ejecuta `flutter clean` y luego `flutter pub get`

### Error: "SHA-1 certificate fingerprint not found"
- Asegúrate de que el SHA-1 esté configurado correctamente en Firebase Console
- Para release builds, necesitarás configurar el SHA-1 de tu certificado de firma

### Error: "Google Sign-In configuration error"
- Verifica que `google-services.json` esté en `android/app/`
- Para iOS, verifica que `Info.plist` tenga la configuración correcta

## Notas

- El Google Sign-In automáticamente crea un usuario en Firestore si es nuevo
- Los datos del perfil (nombre, foto, email) se sincronizarán con Firestore
- El usuario será marcado como no-premium por defecto
