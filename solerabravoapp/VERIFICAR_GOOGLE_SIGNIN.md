# 🔍 Checklist de Verificación - Google Sign-In

Sigue estos pasos en orden para asegurar que todo esté configurado correctamente:

## Paso 1: Verifica Firebase Console ✓

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto: **solerabravo-3d35f**
3. Ve a **Authentication** (Autenticación en la barra izquierda)
4. Haz clic en **Sign-in method**
5. **IMPORTANTE**: Busca a "Google" en la lista
   - Si el botón está **gris/OFF**: Haz clic en él
   - Si el botón está **azul/ON**: Ya está habilitado ✓
6. En la pantalla de configuración de Google:
   - **Project ID**: Debe estar pre-rellenado
   - **Support email**: Selecciona un email
   - Haz clic en **Save**
7. Verifica que el botón de Google esté **azul/ON**

## Paso 2: Verifica el SHA-1 en Firebase Console ✓

1. En la misma consola de Firebase
2. Ve a **Project settings** (ícono de engranaje en la esquina superior)
3. Ve a la pestaña **Your apps**
4. Busca tu app de Android (debe ser **"com.solerabravo.hipometroaureo"**)
5. Haz clic en ella
6. Desplázate a **SHA certificate fingerprints**
7. Verifica que esté el SHA-1: `7F:3C:14:89:97:D2:11:10:7F:BC:AB:F9:19:77:86:5B:E4:0D:F9:D9`
8. Si no está, haz clic en **Add fingerprint** y pégalo

## Paso 3: Verifica el google-services.json ✓

El archivo fue actualizado automáticamente. Para verificar:

1. Abre: `android/app/google-services.json`
2. Busca la sección `certificate_hash`
3. Debe decir: `7f3c148997d211107fbcabf9197786 5be40df9d9` (sin dos puntos)

## Paso 4: Limpia y reconstruye ✓

En la terminal, ejecuta:
```bash
flutter clean
flutter pub get
flutter run
```

## Paso 5: Prueba el Google Sign-In ✓

1. En la pantalla de login, haz clic en **"Iniciar sesión con Google"**
2. Se abrirá un diálogo de selección de cuenta
3. Selecciona tu cuenta de Google

## 🔎 Mira los Logs

Mientras se ejecuta la app, **abre la consola de Flutter** (en VS Code).

Deberías ver mensajes como:
```
📱 Iniciando Google Sign-In...
✅ Usuario de Google seleccionado: tu@email.com
✅ Tokens obtenidos
✅ Credenciales de Firebase creadas
✅ Usuario autenticado en Firebase: tu@email.com
```

Si ves algún error, **copia el mensaje de error completo** (especialmente los que empiezan con `❌`).

## ❌ Errores Comunes

### Error: "User interaction required"
- **Causa**: Google Sign-In está deshabilitado en Firebase Console
- **Solución**: Ve al Paso 1 y habilita Google en "Sign-in method"

### Error: "INVALID_CLIENT"
- **Causa**: El SHA-1 no coincide
- **Solución**: Verifica el Paso 2 y asegúrate de que el SHA-1 sea correcto en Firebase Console

### Error: "SERVER_ERROR"
- **Causa**: Configuración de Firebase incompleta
- **Solución**: Ve a Firebase Console y asegúrate de que:
  - Google esté habilitado
  - Haya un email de soporte configurado

### Error: "CONFIGURATION_NOT_FOUND"
- **Causa**: El `google-services.json` no está correctamente configurado
- **Solución**: Descarga el archivo nuevamente desde Firebase Console

## 📞 Si Aún Tienes Problemas

1. **Copia los logs** de la consola de Flutter (especialmente los mensajes con 📱, ✅, ❌)
2. **Comparte**:
   - El mensaje de error exacto
   - Los logs que ves en VS Code
3. Voy a ayudarte a diagnosticar el problema específico
