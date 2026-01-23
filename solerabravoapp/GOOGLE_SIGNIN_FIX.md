# Solución: Error de Autenticación con Google

## ✅ Cambios Realizados

He actualizado el SHA-1 certificate hash en `google-services.json` para que coincida con tu debug keystore.

### Cambio realizado:
- **Anterior**: `88ee1a9b1d40ec99a6c8fe1733ed0df4c360d518`
- **Nuevo**: `7f3c148997d211107fbcabf9197786 5be40df9d9` (tu certificado de debug)

## 🔧 Pasos para completar la configuración:

### 1. Verificar que Google Sign-In esté habilitado en Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto "solerabravo-3d35f"
3. Ve a **Authentication** (Autenticación)
4. Haz clic en **Sign-in method** (Método de inicio de sesión)
5. **ASEGÚRATE de que Google esté habilitado** (botón azul/verde)
   - Si no está habilitado, haz clic en Google
   - Selecciona tu proyecto en la lista
   - Haz clic en **Save** (Guardar)

### 2. Verificar el email de soporte
- En la misma pantalla de "Sign-in method", asegúrate de que haya un email de soporte configurado

### 3. Limpiar build anterior
```bash
flutter clean
flutter pub get
```

### 4. Recompilar y probar
```bash
flutter run
```

## 🧪 Prueba del Google Sign-In

1. Abre la app
2. Haz clic en **"Iniciar sesión con Google"**
3. Selecciona una cuenta de Google
4. Deberías ver el mensaje "¡Bienvenido!"

## ❌ Si aún hay error, revisa:

1. **Revisa la consola** de Flutter para ver el mensaje de error exacto
2. **Asegúrate de que Google esté enabled** en Firebase Console
3. **Verifica que el package name sea correcto**: `com.solerabravo.hipometroaureo`
4. **Para release builds**, necesitarás actualizar el SHA-1 de tu certificado de firma de release

## 📝 SHA-1 de tus keystores:

- **Debug**: `7F:3C:14:89:97:D2:11:10:7F:BC:AB:F9:19:77:86:5B:E4:0D:F9:D9` ✓ (actualizado)
- **Release**: Si necesitas compilar para release, deberás obtener el SHA-1 del keystore de release
