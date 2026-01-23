# 🔧 Solución: Error de Autenticación con Google

## Problema
Aunque Google Sign-In está habilitado en Firebase, sigue apareciendo error de autenticación.

## Solución Paso a Paso

### 1️⃣ Descarga el google-services.json CORRECTO

Este es el paso más importante. Es probable que tu `google-services.json` sea antiguo.

**En Firebase Console:**
1. Ve a [console.firebase.google.com](https://console.firebase.google.com)
2. Selecciona tu proyecto: **solerabravo-3d35f**
3. Ve a **Project Settings** (ícono de engranaje)
4. Ve a la pestaña **Your apps**
5. Busca tu app Android: **com.solerabravo.hipometroaureo**
6. Haz clic en el botón **Download google-services.json**
7. **Reemplaza** el archivo en: `android/app/google-services.json`

### 2️⃣ Verifica el SHA-1 en Firebase Console

**En Firebase Console:**
1. En **Project Settings** → **Your apps**
2. Busca tu app Android
3. Ve a **SHA certificate fingerprints**
4. Deberías ver este SHA-1: `7F:3C:14:89:97:D2:11:10:7F:BC:AB:F9:19:77:86:5B:E4:0D:F9:D9`
5. **Si NO está**, haz clic en **Add fingerprint** y pégalo

### 3️⃣ Verifica la Configuración de OAuth en Google Cloud

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto
3. Ve a **APIs & Services** → **Credentials**
4. Busca tu **OAuth 2.0 Client ID** (de tipo Android)
5. Si no existe, debes crearlo:
   - Haz clic en **Create Credentials** → **OAuth client ID**
   - Selecciona **Android**
   - Package name: `com.solerabravo.hipometroaureo`
   - SHA-1 Certificate Fingerprint: `7F:3C:14:89:97:D2:11:10:7F:BC:AB:F9:19:77:86:5B:E4:0D:F9:D9`
   - Haz clic en **Create**

### 4️⃣ Limpia y Reconstruye

```bash
flutter clean
flutter pub get
flutter run
```

## ✅ Verificación Final

Después de descargue el nuevo `google-services.json`:

1. Abre el archivo: `android/app/google-services.json`
2. Verifica que contenga:
   - Tu project ID: `solerabravo-3d35f`
   - Tu package name: `com.solerabravo.hipometroaureo`
   - El SHA-1 correcto en `certificate_hash`

## 🆘 Si Aún No Funciona

Por favor, comparte:
1. El **error exacto** que ves en pantalla
2. Los **logs de la consola** (VS Code)
3. Una captura de pantalla de Firebase Console mostrando que Google esté habilitado
