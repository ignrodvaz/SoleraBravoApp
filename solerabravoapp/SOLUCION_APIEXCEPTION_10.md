# 🔧 Solución para ApiException: 10

## Problema
Error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)`

**Código 10 = DEVELOPER_ERROR**: Problema de configuración con el certificado o el package name.

## Soluciones (en orden)

### Opción 1: Descargar google-services.json nuevamente (RECOMENDADO)

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto: **solerabravo-3d35f**
3. Ve a **Project Settings** (ícono de engranaje)
4. Ve a la pestaña **Your apps**
5. Busca tu app Android: **com.solerabravo.hipometroaureo**
6. Haz clic en **Download google-services.json**
7. **Reemplaza** el archivo en: `android/app/google-services.json`

### Opción 2: Verificar en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto: **solerabravo-3d35f**
3. Ve a **APIs & Services** → **Credentials**
4. Busca tu **OAuth 2.0 Client ID** (de tipo Android)
5. Verifica que tenga:
   - **Package name**: `com.solerabravo.hipometroaureo` ✓
   - **SHA-1 Certificate Fingerprint**: `7F:3C:14:89:97:D2:11:10:7F:BC:AB:F9:19:77:86:5B:E4:0D:F9:D9` ✓

### Opción 3: Método alternativo con Web Client ID

Si las opciones anteriores no funcionan, podemos usar el Web Client ID en lugar del método automático:

1. En Google Cloud Console, copia tu **Web Client ID** (OAuth 2.0 de tipo Web)
2. Modifica el `GoogleSignIn` en `lib/services/auth_service.dart` para usar:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'TU_WEB_CLIENT_ID.apps.googleusercontent.com',
);
```

## Pasos Inmediatos

1. Ejecuta:
```bash
cd android
./gradlew.bat clean
cd ..
flutter clean
flutter pub get
```

2. Descarga el `google-services.json` nuevamente desde Firebase

3. Reemplaza el archivo en `android/app/google-services.json`

4. Ejecuta:
```bash
flutter run
```

## Verificación Final

Comparte:
- El contenido de tu `google-services.json` (las primeras 30 líneas)
- Captura de pantalla de Google Cloud Console mostrando el OAuth Client ID de Android
