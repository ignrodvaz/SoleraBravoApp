# 🧪 Guía de Testing - Sistema de Análisis

## 🎯 Casos de Prueba

### 1. **Guardar Análisis**

#### Test 1.1: Guardar análisis sin notas
```
1. Inicia sesión en la app
2. Ve a "Inicio"
3. Presiona "Tomar foto" o "Desde galería"
4. Se abre el editor
5. Selecciona "Análisis Básico" (verde)
6. Presiona "Guardar análisis"
7. Se abre la pantalla de confirmación
8. Presiona "Guardar análisis" sin escribir notas
✅ Esperado: Análisis guardado, SnackBar verde de confirmación
```

#### Test 1.2: Guardar análisis con notas
```
1. Repite pasos 1-6 de Test 1.1
2. En la pantalla de confirmación, escribe una nota
3. Presiona "Guardar análisis"
✅ Esperado: Análisis guardado con notas, confirmación visible
```

#### Test 1.3: Cambiar tipo de análisis
```
1. En el editor, presiona "Triángulo de fuerza"
2. El overlay naranja debe aparecer
3. Presiona "3 Paralelas"
4. El overlay azul debe aparecer
5. Presiona "Análisis Básico"
6. El overlay verde debe aparecer
7. Presiona "Guardar análisis"
✅ Esperado: Análisis guardado con tipo "Análisis Básico"
```

#### Test 1.4: Transformar overlay
```
1. Abre editor y selecciona un tipo
2. Pinch/zoom para escalar el overlay
3. Arrastra para mover
4. Rota el overlay
5. Presiona "Guardar análisis"
✅ Esperado: Transformaciones se aplican, análisis se guarda
```

#### Test 1.5: Sin seleccionar tipo
```
1. Abre editor
2. NO selecciones ningún tipo
3. Presiona "Guardar análisis"
✅ Esperado: SnackBar naranja diciendo "Por favor selecciona un tipo de análisis"
```

### 2. **Ver Análisis Guardados**

#### Test 2.1: Listar análisis
```
1. Guarda 3 análisis diferentes
2. Ve a "Mis análisis"
✅ Esperado: Se muestran todos los 3 análisis en orden inverso (más reciente primero)
```

#### Test 2.2: Datos mostrados correctamente
```
1. Ve a "Mis análisis"
2. Para cada análisis, verifica:
   - Miniatura correcta
   - Título con fecha
   - Tipo con color correcto (verde/naranja/azul)
   - Fecha legible
✅ Esperado: Todos los datos correctos
```

#### Test 2.3: Contador de análisis
```
1. Guarda 5 análisis
2. Ve a "Mis análisis"
✅ Esperado: Muestra "5 Análisis guardados" en la tarjeta superior
```

#### Test 2.4: Sin análisis
```
1. Usuario nuevo que no ha guardado análisis
2. Ve a "Mis análisis"
✅ Esperado: Muestra icono de carpeta vacía y mensaje "No tienes análisis guardados"
```

### 3. **Ver Detalles de Análisis**

#### Test 3.1: Abrir detalles
```
1. Ve a "Mis análisis"
2. Presiona "Ver" en un análisis
✅ Esperado: Se abre diálogo con imagen grande, tipo, fecha y notas
```

#### Test 3.2: Cerrar detalles
```
1. Abre detalles de un análisis
2. Presiona el X en la esquina superior derecha
✅ Esperado: Se cierra el diálogo
```

#### Test 3.3: Detalles con notas
```
1. Guarda un análisis CON notas
2. Ve a "Mis análisis"
3. Presiona "Ver"
✅ Esperado: Las notas se muestran en el diálogo
```

### 4. **Eliminar Análisis**

#### Test 4.1: Eliminar con confirmación
```
1. Ve a "Mis análisis"
2. Presiona "Eliminar" en un análisis
3. Se abre diálogo de confirmación
4. Presiona "Eliminar"
✅ Esperado: Análisis desaparece, SnackBar verde de confirmación
```

#### Test 4.2: Cancelar eliminación
```
1. Ve a "Mis análisis"
2. Presiona "Eliminar"
3. Se abre diálogo de confirmación
4. Presiona "Cancelar"
✅ Esperado: Diálogo se cierra, análisis permanece
```

#### Test 4.3: Eliminar múltiples análisis
```
1. Guarda 5 análisis
2. Elimina 3 de ellos
3. Verifica contador
✅ Esperado: Contador actualizado, solo 2 análisis quedan
```

### 5. **Seguridad y Datos**

#### Test 5.1: Datos por usuario
```
1. Usuario A guarda 3 análisis
2. Cierra sesión
3. Inicia sesión como Usuario B
4. Ve a "Mis análisis"
✅ Esperado: Usuario B NO ve análisis de Usuario A, lista vacía
```

#### Test 5.2: Persistencia
```
1. Guarda un análisis como Usuario A
2. Cierra app
3. Abre app
4. Ve a "Mis análisis"
✅ Esperado: El análisis todavía está allí (cargado desde Firebase)
```

#### Test 5.3: Sincronización en tiempo real
```
1. Abre app en teléfono 1
2. Guarda análisis desde teléfono 2
3. En teléfono 1, ve a "Mis análisis"
✅ Esperado: El análisis aparece automáticamente sin recargar
```

### 6. **Formato de Imágenes**

#### Test 6.1: Imagen PNG
```
1. Guarda un análisis
2. Ve a Firebase Storage
3. Descarga la imagen
✅ Esperado: La imagen es PNG (verifica extensión y formato)
```

#### Test 6.2: Calidad de imagen
```
1. Toma foto en 4K/Alta calidad
2. Guarda análisis
3. Ve la miniatura en "Mis análisis"
✅ Esperado: Miniatura clara y legible
```

### 7. **Manejo de Errores**

#### Test 7.1: Sin conexión al guardar
```
1. Desactiva internet
2. Intenta guardar análisis
✅ Esperado: Error visible, posibilidad de reintentar
```

#### Test 7.2: Error de almacenamiento
```
1. Intenta guardar análisis muy grandes
✅ Esperado: Mensaje de error apropiado
```

## 📊 Matriz de Testing

| Caso | Descripción | Estado | Notas |
|------|-------------|--------|-------|
| 1.1 | Guardar sin notas | [ ] | |
| 1.2 | Guardar con notas | [ ] | |
| 1.3 | Cambiar tipo | [ ] | |
| 1.4 | Transformar | [ ] | |
| 1.5 | Sin tipo | [ ] | |
| 2.1 | Listar | [ ] | |
| 2.2 | Datos correctos | [ ] | |
| 2.3 | Contador | [ ] | |
| 2.4 | Vacío | [ ] | |
| 3.1 | Ver detalles | [ ] | |
| 3.2 | Cerrar | [ ] | |
| 3.3 | Con notas | [ ] | |
| 4.1 | Eliminar | [ ] | |
| 4.2 | Cancelar | [ ] | |
| 4.3 | Múltiples | [ ] | |
| 5.1 | Por usuario | [ ] | |
| 5.2 | Persistencia | [ ] | |
| 5.3 | Tiempo real | [ ] | |
| 6.1 | PNG | [ ] | |
| 6.2 | Calidad | [ ] | |
| 7.1 | Sin conexión | [ ] | |
| 7.2 | Error | [ ] | |

## 🐛 Errores Comunes

### Error: "Usuario no autenticado"
**Causa**: Usuario no ha iniciado sesión
**Solución**: Inicia sesión primero

### Error: "No se puede subir imagen"
**Causa**: Reglas de Firebase no configuradas
**Solución**: Ver `FIREBASE_SECURITY_CONFIG.md`

### Error: "La imagen no aparece en "Mis análisis""
**Causa**: Demora en carga desde Storage
**Solución**: Espera unos segundos y recarga

### Diálogo de detalles vacío
**Causa**: La imagen aún se está cargando
**Solución**: Normal, espera a que cargue

