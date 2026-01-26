# ⚡ PASOS RÁPIDOS: Ejecutar la App

## 🎯 SOLO 3 PASOS

### Paso 1: Abre la terminal PowerShell
```powershell
cd "c:\Users\juanc\OneDrive\Escritorio\SoleraBravoApp\SoleraBravoApp\solerabravoapp"
```

### Paso 2: Inicia el emulador (o conecta dispositivo)
```powershell
# OPCIÓN A: Si tienes emulador
emulator @nombre_del_emulador

# OPCIÓN B: Si tienes dispositivo Android conectado por USB
# (asegúrate de que esté en modo desarrollador)
```

### Paso 3: Ejecuta la app
```powershell
flutter run
```

---

## 📱 Qué Verás

1. **"Inicializando..."** (2-3 segundos)
2. **Pantalla de Login** si NO tienes sesión
3. **Página Principal** si YA estabas autenticado

---

## 🔐 Para Probar Google Sign-In

1. Toca **"Iniciar sesión con Google"**
2. Selecciona tu cuenta de Google
3. Deberías ver **"¡Bienvenido!"**
4. Irás a la **Página Principal**

---

## ❌ Si Falla

Ejecuta con logs:
```powershell
flutter run -v
```

Y **comparte los mensajes de error** que veas.

---

## 💡 Problemas Comunes

| Problema | Solución |
|----------|----------|
| Pantalla blanca | Espera 5 segundos, debería cargar |
| No hay dispositivos | Inicia emulador o conecta teléfono |
| Error de Firebase | Verifica conexión a internet |
| Google Sign-In no funciona | Emulador necesita Google Play Services |
| Puerto 5037 en uso | Ejecuta: `adb kill-server` |

---

## ✅ Done!

¡Tu app está lista! 🚀
