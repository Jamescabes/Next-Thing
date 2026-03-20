# Mobile Test Results — Next Thing (Calendar App)

**Date:** March 20, 2026
**Tester:** Claude Sonnet 4.6
**Branch:** `claude/thirsty-goldwasser`
**Viewport tested:** 375×812px (iPhone standard)

---

## 1. Descripción de la App

**Next Thing** es una aplicación personal de gestión de eventos con interfaz de **línea de tiempo**. En lugar de un calendario tradicional, presenta los eventos ordenados cronológicamente con un separador `NOW` que divide lo que viene (futuro) de lo que ya ocurrió (pasado). Las tareas futuras se muestran con opacidad completa y las pasadas al 50% (dimmed).

Es una app 100% client-side, sin backend ni autenticación real. Toda la persistencia se hace en el navegador mediante IndexedDB. El diseño es **mobile-first** — los modales son bottom sheets que ocupan 95vh, los botones están dimensionados para touch, y el FAB (Floating Action Button) es el punto de entrada principal para crear eventos.

---

## 2. Tecnologías Usadas

| Capa | Tecnología | Versión |
|---|---|---|
| Framework UI | React | 18.2.0 |
| Build tool | Vite | 5.1.6 |
| Routing | React Router DOM | 6.22.3 |
| Animaciones | Framer Motion | 11.0.8 |
| Base de datos | Dexie (IndexedDB) | 4.3.0 |
| Queries reactivas | dexie-react-hooks | — |
| Iconos | Lucide React | 0.344.0 |
| Manejo de fechas | date-fns | 3.6.0 |
| Estilos | CSS Modules + CSS custom properties | — |

No tiene backend, autenticación real, ni dependencias de red. Todo corre en el navegador del usuario.

---

## 3. Levantamiento de la App y Prueba Móvil

### Levantamiento

**Resultado: exitoso.** El servidor de desarrollo arrancó sin errores:

```
VITE v5.4.21  ready in 859ms
➜  Local: http://localhost:5174/
```

Se creó `.claude/launch.json` para que el Preview MCP pueda levantar el servidor automáticamente en futuras sesiones de Claude Code sin intervención manual.

### Prueba móvil

**Resultado: exitosa con limitaciones.** El viewport fue configurado a **375×812px** (iPhone estándar) mediante el Preview MCP. Se confirmó que el layout responde correctamente a esas dimensiones — el diseño es mobile-first por arquitectura.

Se insertaron **9 tareas de prueba** directamente en IndexedDB para simular un estado de uso real:

- 6 tareas activas (4 futuras, 2 pasadas al momento del test)
- 3 tareas completadas (en historial)

La app cargó y mostró correctamente todas las tareas con el separador NOW en el lugar esperado.

**Limitación — Screenshots:** La herramienta `preview_screenshot` dio timeout (30s) de forma consistente en cada intento, aunque el servidor y la app funcionaban perfectamente (confirmado via eval JavaScript, snapshots de accesibilidad y console logs). Es un problema del renderer headless en este entorno, no de la app. No se tomaron screenshots.

---

## 4. Principales Casos de Uso Identificados

### CU-01: Vista Principal — Timeline

La pantalla de inicio muestra todos los eventos activos en una lista vertical con el marcador `NOW` como separador. Los eventos se ordenan por `[date+time]` de forma descendente.

- Eventos futuros: opacidad 100%, encima del NOW
- Eventos pasados: opacidad 50%, debajo del NOW
- El marcador NOW se actualiza cada 60 segundos via `setInterval`
- Paginación de pasados: muestra 10 por defecto, con botón "Load Events" en lotes de 30

### CU-02: Crear Evento

Al pulsar el FAB `[+ Add]`, se despliega un **bottom sheet** animado (spring animation, `y: 100% → 0`).

Campos disponibles:
- **Título** (requerido — texto 32px bold, el Save queda deshabilitado sin él)
- **Fecha** con shortcuts rápidos: Today, Tomorrow, In 2 Days + input de fecha nativa
- **Hora** (picker de tiempo)
- **Color** — 6 colores preset (Default, Green, Yellow, Red, Blue, Pink) + selector custom
- **Ubicación** — campo de texto (no se persiste, ver Problemas)
- **Notas** — textarea
- **Descripción** — textarea adicional (no se persiste, ver Problemas)

Atajo: pulsar Enter en el campo de título guarda el evento directamente.

### CU-03: Editar Evento

Tocar cualquier tarjeta del timeline abre el mismo bottom sheet con todos los campos pre-poblados. El header muestra "Edit Event" en lugar de "New Event". Los cambios se guardan con el mismo botón Save.

### CU-04: Completar Tarea

Cada tarjeta tiene un botón checkbox `[✓]` en la esquina superior. Al pulsarlo:
1. Se llama `toggleComplete(task)` en el contexto React
2. Se actualiza `isCompleted: true` en IndexedDB
3. La tarea desaparece del timeline con animación `exit: { opacity: 0, scale: 0.98 }`
4. La tarea pasa a ser accesible desde el historial

### CU-05: Panel de Ajustes

Al pulsar el ícono ⚙️ en el TopBar, un panel desliza desde la **izquierda** (`x: -100% → 0`). Contiene:
- Avatar + nombre + email del usuario (hardcodeado)
- Toggle **Dark Mode / Light Mode**
- Botón **Log Out** (sin funcionalidad real aún)

### CU-06: Dark Mode

El toggle de Settings cambia el atributo `data-theme='dark'` en `:root`. El sistema usa CSS custom properties para los colores:

| Variable | Light | Dark |
|---|---|---|
| `--color-bg` | `#fdfdfd` | `#0a0a0a` |
| `--color-text-primary` | `#1a1a1a` | `#f0f0f0` |
| `--color-balloon-bg` | `#ffffff` | `#1a1a1a` |
| `--color-border` | `#e5e5e5` | `#333333` |
| `--color-accent` | `#000000` | `#ffffff` |

### CU-07: Historial — Vista Lista

Modal bottom sheet con todas las tareas ordenadas por fecha descendente, paginadas en lotes de 30. Tocar una tarea abre directamente el modal de edición (el historial se cierra con animación mientras el editor se abre).

### CU-08: Historial — Vista Calendario

Cuadrícula mensual que muestra los días del mes actual. Los días con eventos muestran indicadores de color. Al tocar un día con eventos, se puede acceder y editar esa tarea.

---

## 5. Problemas Encontrados

### Bugs / Funcionalidad incompleta

| # | Problema | Severidad |
|---|---|---|
| P-01 | El campo **Location** del modal no se guarda — no existe en el schema de IndexedDB | Media |
| P-02 | El segundo textarea **Description** del modal no se guarda — campo sin conectar al estado ni a la DB | Media |
| P-03 | **Log Out** en Settings no tiene funcionalidad | Baja |
| P-04 | El perfil muestra `"User Name"` y `"user@example.com"` hardcodeados | Baja |
| P-05 | El calendario del History no tiene botones prev/next para navegar entre meses | Media |
| P-06 | El History muestra **todas** las tareas (activas y completadas), no solo el historial de completadas | Baja |

### Problemas del entorno de prueba

| # | Problema | Causa |
|---|---|---|
| E-01 | `preview_screenshot` dio timeout consistentemente (30s) | Bug del renderer headless del Preview MCP en este entorno Windows — no es problema de la app |
| E-02 | Chrome MCP inaccesible (extensión no respondía) | Extensión de Chrome no activa durante la sesión |

### Screenshots tomados

**No se tomaron screenshots.** El renderer headless del Preview MCP falló en cada intento de captura. La verificación se realizó mediante:
- Accessibility tree snapshots (`preview_snapshot`)
- Evaluación JavaScript directa (`preview_eval`)
- Lectura del código fuente de todos los componentes
- Console logs del servidor

---

## Estructura del Proyecto (referencia)

```
src/
├── pages/
│   └── Home.jsx                  # Página principal — timeline + modales
├── components/
│   ├── BalloonCard/              # Tarjeta de evento (color, tiempo, checkbox)
│   ├── EventCreationModal/       # Bottom sheet crear/editar evento
│   ├── DateTimePicker/           # Selector de fecha y hora con shortcuts
│   ├── ColorPicker/              # Selector de color (6 preset + custom)
│   ├── History/                  # Modal historial (lista + calendario)
│   ├── TopBar/                   # Header (Settings + History + fecha)
│   ├── SidePanel/                # Panel ajustes (dark mode, logout)
│   └── FloatingActionButton/     # FAB [+ Add]
├── context/
│   └── TaskContext.jsx           # Estado global (tareas, tema)
├── db/
│   └── db.js                     # Schema Dexie — tabla `tasks`
└── styles/
    ├── global.css
    └── variables.css             # Tokens de diseño (colores, spacing, radii)
```
