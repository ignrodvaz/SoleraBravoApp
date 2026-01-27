# 🧪 Instrucciones de Prueba - Overlay en Guardado

## ✅ Pasos Iniciales

### 1. Instalar dependencias
```bash
cd solerabravoapp
flutter pub get
```

### 2. Limpiar build anterior
```bash
flutter clean
```

### 3. Ejecutar app
```bash
flutter run
```

## 🎯 Prueba Completa

### Test 1: Guardar con Overlay Básico

```
1. Abre la app y asegúrate de estar autenticado
2. Ve a "Inicio"
3. Presiona "Tomar foto" o "Desde galería"
4. Selecciona una imagen de un caballo
5. En el editor:
   ✓ Presiona "Análisis Básico" (verde)
   ✓ El overlay verde (hipometro) debe aparecer
   ✓ Mueve el overlay (arrastrando)
   ✓ Amplía/reduce (pinch zoom)
   ✓ Presiona "Guardar análisis"
6. En la pantalla de confirmación:
   ✓ Deberías ver el MENSAJE: "La imagen se combinará con el overlay hipometro"
   ✓ Escribe una nota
   ✓ Presiona "Guardar análisis"
7. Espera a que termine (verás spinner)
8. Si todo funciona → SnackBar verde "Análisis guardado correctamente"
9. Ve a "Mis análisis"
10. El análisis debe aparecer con la imagen + overlay guardados
```

### Test 2: Verificar Overlay Incluido

```
1. En "Mis análisis", presiona "Ver" en el análisis que acabas de guardar
2. Deberías ver la imagen con el overlay dibujado encima
3. NO debe ser solo la foto original
```

### Test 3: Diferentes Tipos de Overlay

Repite el Test 1 pero con cada tipo:

**Triángulo de Fuerza (Naranja):**
```
1. Presiona "Triángulo de fuerza"
2. El overlay naranja debe aparecer
3. Ajusta y guarda
```

**3 Paralelas (Azul):**
```
1. Presiona "3 Paralelas"
2. El overlay azul debe aparecer
3. Ajusta y guarda
```

## 🔍 Verificación en Consola

Cuando presiones "Guardar", en la consola deberías ver:

✅ Correcto - Sin errores:
```
I/flutter: Guardando análisis...
I/flutter: Análisis guardado exitosamente
```

❌ Error - Si ves esto, anota el mensaje:
```
E/flutter: Error al guardar: [mensaje de error]
```

## 📸 Qué Verificar

### En la pantalla de preview (SaveAnalysisPage):

- [ ] Mensaje "La imagen se combinará con el overlay..."
- [ ] Tipo de análisis correcto
- [ ] Fecha correcta
- [ ] Campos para notas

### En "Mis análisis":

- [ ] Miniatura muestra la imagen + overlay
- [ ] NO es solo la foto original
- [ ] Título con fecha
- [ ] Tipo correcto con color
- [ ] Botones "Ver" y "Eliminar" funcionan

### Al presionar "Ver":

- [ ] Se abre diálogo con imagen completa
- [ ] La imagen incluye el overlay
- [ ] Se ve claramente el tipo de análisis
- [ ] Las notas aparecen si las agregaste

## 🐛 Posibles Errores y Soluciones

### Error: "Asset not found: src/hipometro.png"
**Causa**: El archivo PNG del overlay no existe
**Solución**: Verifica que existen estos archivos:
- `src/hipometro.png`
- `src/Triangulo_Fuerza.png`
- `src/Aplomo.png`

### Error: "No se pudo procesar la imagen"
**Causa**: Problema al decodificar la imagen original
**Solución**: Intenta con una foto diferente

### Error: "Error al guardar: Permission denied"
**Causa**: Problema con permisos de Firebase Storage
**Solución**: Verifica las reglas de Firebase (ver `FIREBASE_SECURITY_CONFIG.md`)

### Se queda cargando sin guardar
**Causa**: Múltiples posibles (conexión, Firebase)
**Solución**: 
1. Revisa la consola para ver el error
2. Verifica conexión de internet
3. Verifica credenciales de Firebase

## 📝 Checklist de Testing

| Elemento | Completado | Notas |
|----------|-----------|-------|
| Foto se carga | [ ] | |
| Overlay aparece | [ ] | |
| Overlay se puede mover | [ ] | |
| Overlay se puede escalar | [ ] | |
| Guardar inicia | [ ] | |
| Análisis se guarda | [ ] | |
| Aparece en "Mis análisis" | [ ] | |
| Miniatura con overlay | [ ] | |
| Ver detalles funciona | [ ] | |
| Overlay en detalles | [ ] | |
| Eliminar funciona | [ ] | |

## 🆘 Si Algo Falla

1. **Revisa la consola** - Copia el error completo
2. **Verifica estas dependencias** en pubspec.yaml:
   - `image: ^4.0.0`
   - `path_provider: ^2.1.0`
   - `firebase_storage: ^11.7.0`

3. **Ejecuta estos comandos**:
   ```bash
   flutter clean
   flutter pub get
   flutter pub cache repair
   flutter run
   ```

4. **Si persiste**, revisa:
   - Que Firebase esté configurado
   - Que los archivos PNG en `src/` existan
   - Que la imagen original sea válida

