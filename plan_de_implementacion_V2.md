# 📋 Plan de Implementación: LifeTours
> Aplicación multiplataforma Flutter/Dart + Firebase Firestore para agendar tours.  
> Alcance: académico, completamente funcional. Sin notificaciones. Con panel de administrador.

---

## 📌 Nota sobre la Base de Datos

**Firebase Firestore (versión Spark — gratuita) es una buena elección para este proyecto**, con las siguientes consideraciones:

| Aspecto | Firestore (Spark) | Alternativa: Supabase (PostgreSQL) |
|---|---|---|
| Costo | Gratuito con límites generosos | Gratuito (tier free) |
| Integración Flutter | Excelente (FlutterFire oficial) | Buena (cliente Dart disponible) |
| Modelo de datos | Documentos/colecciones (NoSQL) | Tablas relacionales (SQL) |
| Auth incluida | Sí (Firebase Auth) | Sí (Supabase Auth) |
| Consultas complejas | Limitadas (sin JOINs) | Completas (SQL completo) |
| Tiempo real | Sí nativo | Sí (websockets) |
| Curva de aprendizaje | Baja | Media |

**Recomendación:** Continuar con **Firestore** dado que el plan ya está estructurado sobre él, la integración con Flutter es la más madura del ecosistema, y para fines académicos su modelo de documentos es más visual e intuitivo. El único cuidado es diseñar bien las colecciones para evitar lecturas costosas. No habilitar Google Analytics es correcto; no se necesita para el funcionamiento de la app.

---

## 🛠️ 1. Herramientas y Configuración del Entorno

| Categoría | Herramienta | Propósito |
|---|---|---|
| SDK & Lenguaje | Flutter SDK (última estable), Dart SDK | Desarrollo multiplataforma |
| IDE | Visual Studio Code | Editor principal |
| Extensiones VS Code | Flutter, Dart, Firebase, GitLens, Error Lens, Pubspec Assist | Productividad y diagnóstico |
| CLI & Cloud | Firebase CLI, flutterfire CLI, git | Configuración de servicios y versionado |
| Plataforma nativa | Android Studio (SDK/emuladores) | Compilación y pruebas en Android |
| Diseño | Figma | Prototipado UI/UX |
| Pruebas | flutter test, Firebase Emulator Suite | Validación local sin costos |

### Pre-requisitos de configuración

1. Instalar Flutter y validar con `flutter doctor` (sin errores críticos).
2. Crear cuenta Firebase → nuevo proyecto `life-tours` → **deshabilitar Google Analytics**.
3. Habilitar **Firebase Auth** (proveedor: Email/Password).
4. Crear base de datos **Cloud Firestore** en modo producción (reglas se configuran en Fase 4).
5. Ejecutar `flutterfire configure` para generar `firebase_options.dart`.
6. Inicializar repositorio Git con ramas `main` (producción) y `develop` (trabajo activo).

---

## 🎨 2. Principios UI/UX y Flujo de Usuario

### Principios de diseño

- **Minimalismo funcional:** Claridad sobre decoración. Espacios en blanco, tipografía legible, paleta coherente.
- **Jerarquía visual:** Título > Descripción > Acción principal. Botones primarios destacados.
- **Accesibilidad:** Contraste WCAG AA, áreas de toque ≥ 44×44 dp, soporte para lectores de pantalla.
- **Feedback inmediato:** Estados de carga, éxito, error y sin conexión visibles siempre.
- **Roles diferenciados:** La experiencia visual del administrador es distinta (acceso a panel CRUD); la del turista es el flujo de exploración y reserva.

### Flujo de usuario — Turista

```
Splash → Auth (Login/Registro) → Home (Catálogo de tours)
  → Detalle de Tour → Agendar (fecha, personas) → Confirmación → Mis Reservas
```

### Flujo de usuario — Administrador

```
Splash → Auth (Login admin) → Panel Admin
  → Gestión de Tours (CRUD) → Gestión de Usuarios → Gestión de Reservaciones
  → Gestión de Guías → Gestión de Disponibilidad
```

### Pantallas clave

| Pantalla | Elementos críticos |
|---|---|
| Autenticación | Email, contraseña, validación en tiempo real, recuperación de contraseña |
| Home | Grid/lista de tours, filtros (categoría, precio, fecha), buscador |
| Detalle de Tour | Galería de imágenes, descripción, itinerario, precio, disponibilidades, CTA reservar |
| Agendar | Selector de fecha/hora (de disponibilidades reales), número de personas, resumen de pago, confirmación |
| Mis Reservas | Historial del usuario con estado de cada reservación |
| Perfil | Datos del usuario, historial, cerrar sesión |
| Panel Admin — Lista | Tabla de registros por colección con paginación |
| Panel Admin — Formulario | Formulario de creación/edición por entidad |

---

## 🏗️ 3. Arquitectura y Gestión de Estado

- **Patrón:** Feature-First con capas (Presentation → Domain/Logic → Data).
- **Estado:** `provider` con `ChangeNotifier` por feature. Un provider por módulo funcional.
- **Navegación:** `go_router` con protección de rutas según rol (turista vs. administrador).
- **Datos remotos:** Firebase Auth (sesión), Cloud Firestore (todas las colecciones).
- **Cache local:** `cached_network_image` para imágenes de tours, `shared_preferences` para preferencias básicas.

### Providers necesarios

| Provider | Responsabilidad |
|---|---|
| `AuthProvider` | Sesión, registro, login, logout, rol del usuario |
| `TourProvider` | Listado, filtros, detalle de tour, búsqueda |
| `DisponibilidadProvider` | Fechas/horas disponibles por tour |
| `ReservacionProvider` | Crear reserva, validar cupos, historial del usuario |
| `AdminProvider` | Operaciones CRUD para el panel de administrador |
| `CategoriaProvider` | Listado de categorías (para filtros y formularios admin) |
| `GuiaProvider` | Listado de guías (para asociar a tours desde admin) |

### Seguridad en Firestore (reglas por colección)

| Colección | Lectura | Escritura |
|---|---|---|
| `tours` | Pública (cualquier autenticado) | Solo admin |
| `usuarios` | Solo el propio documento | Solo el propio documento |
| `guias` | Autenticados | Solo admin |
| `categorias` | Pública | Solo admin |
| `disponibilidad` | Autenticados | Solo admin |
| `reservaciones` | Solo el creador | Solo el creador (crear) / admin (modificar) |
| `itinerario` | Autenticados | Solo admin |
| `media` | Pública | Solo admin |
| `resenas` | Autenticados | Solo creador |

El rol de administrador se almacena en el documento del usuario en Firestore (`rol: "admin"`) y se valida tanto en el cliente (para navegación) como en las reglas de Firestore (para seguridad real).

---

## 📦 4. Dependencias — `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest

  # Estado y navegación
  provider: ^latest
  go_router: ^latest

  # UI y utilidades
  cached_network_image: ^latest
  intl: ^latest                  # Formato de fechas y monedas (MXN, USD)
  flutter_svg: ^latest           # Íconos e ilustraciones SVG
  image_picker: ^latest          # Subida de imágenes desde admin (media de tours)

  # Almacenamiento local
  shared_preferences: ^latest

  # Internacionalización
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^latest
  mockito: ^latest
  build_runner: ^latest
```

> **Notas:**
> - Usar `flutter pub get` tras cada modificación al archivo.
> - Considerar agregar `freezed` + `json_serializable` si los modelos de datos crecen en complejidad.
> - `image_picker` es necesario para que el administrador pueda cargar fotos de tours. Requiere permisos en `AndroidManifest.xml` e `Info.plist`.
> - No se agrega ningún paquete de notificaciones (`firebase_messaging`) ya que está fuera del alcance.

---

## 🗂️ 5. Modelo de Datos en Firestore

Firestore organiza los datos en **colecciones de documentos**. A continuación el mapeo de las entidades relacionales al modelo de documentos:

### Colecciones principales

```
/usuarios/{uid}
/guias/{guiaId}
/categorias/{categoriaId}
/tours/{tourId}
/disponibilidad/{dispId}
/reservaciones/{reservaId}
/itinerario/{itemId}          ← subcolección también válida: /tours/{tourId}/itinerario
/media/{mediaId}              ← subcolección también válida: /tours/{tourId}/media
/resenas/{resenaId}
```

### Campos clave por colección

**usuarios**
```
uid (string, PK = Firebase Auth UID)
nombre (string)
email (string)
telefono (string)
fotoUrl (string)
rol (string: "turista" | "admin")
activo (bool)
createdAt (timestamp)
```

**tours**
```
id (string, auto)
guiaId (string, ref → guias)
categoriaId (string, ref → categorias)
nombre (string)
descripcion (string)
duracionMinutos (int)
precio (number)
moneda (string: "MXN")
capacidadMaxima (int)
ubicacion (string)
latitud (number)
longitud (number)
estado (string: "borrador" | "activo" | "pausado")
createdAt (timestamp)
```

**disponibilidad**
```
id (string, auto)
tourId (string, ref → tours)
fecha (timestamp)
horaInicio (string: "HH:mm")
cuposDisponibles (int)
precioEspecial (number | null)
estado (string: "abierto" | "lleno" | "cancelado")
```

**reservaciones**
```
id (string, auto)
usuarioId (string, ref → usuarios)
disponibilidadId (string, ref → disponibilidad)
tourId (string)            ← desnormalizado para consultas de historial
numPersonas (int)
montoTotal (number)
codigoConfirmacion (string)
estado (string: "pendiente" | "confirmada" | "cancelada" | "completada")
createdAt (timestamp)
```

**resenas**
```
id (string, auto)
reservacionId (string, ref → reservaciones)
usuarioId (string, ref → usuarios)
calificacion (int: 1–5)
comentario (string)
respuestaGuia (string | null)
createdAt (timestamp)
```

> **Desnormalización controlada:** En Firestore es válido y recomendado copiar campos frecuentemente consultados (como `tourId` en reservaciones, o `nombreTour` en reseñas) para evitar lecturas adicionales. Aplicar con criterio.

---

## 📁 6. Estructura de Directorios del Proyecto

```
life_tours/
├── android/
├── ios/
├── assets/
│   ├── images/
│   │   └── logo.png
│   ├── icons/
│   └── fonts/
├── lib/
│   ├── main.dart                        ← Inicialización Firebase, runApp
│   ├── routes.dart                      ← Definición de rutas con go_router
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_sizes.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart           ← ThemeData global
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   ├── currency_formatter.dart
│   │   │   └── validators.dart          ← Validaciones de formularios
│   │   └── errors/
│   │       └── app_exceptions.dart      ← Manejo centralizado de errores
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_message.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── tour_card.dart           ← Card reutilizable para listados
│   │   │   └── confirm_dialog.dart
│   │   └── models/
│   │       ├── usuario_model.dart
│   │       ├── tour_model.dart
│   │       ├── guia_model.dart
│   │       ├── categoria_model.dart
│   │       ├── disponibilidad_model.dart
│   │       ├── reservacion_model.dart
│   │       ├── itinerario_model.dart
│   │       ├── media_model.dart
│   │       └── resena_model.dart
│   │
│   ├── features/
│   │   │
│   │   ├── auth/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   └── widgets/
│   │   │       └── auth_form_field.dart
│   │   │
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tour_filter_bar.dart
│   │   │       └── featured_tour_banner.dart
│   │   │
│   │   ├── tours/
│   │   │   ├── providers/
│   │   │   │   ├── tour_provider.dart
│   │   │   │   └── disponibilidad_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── tour_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tour_gallery.dart
│   │   │       ├── itinerario_list.dart
│   │   │       └── disponibilidad_picker.dart
│   │   │
│   │   ├── booking/
│   │   │   ├── providers/
│   │   │   │   └── reservacion_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── agendar_screen.dart
│   │   │   │   └── confirmacion_screen.dart
│   │   │   └── widgets/
│   │   │       └── booking_summary_card.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── screens/
│   │   │   │   └── profile_screen.dart
│   │   │   └── widgets/
│   │   │       ├── mis_reservas_list.dart
│   │   │       └── resena_form.dart
│   │   │
│   │   └── admin/
│   │       ├── providers/
│   │       │   └── admin_provider.dart
│   │       ├── screens/
│   │       │   ├── admin_dashboard_screen.dart
│   │       │   ├── admin_tours_screen.dart
│   │       │   ├── admin_tour_form_screen.dart
│   │       │   ├── admin_usuarios_screen.dart
│   │       │   ├── admin_guias_screen.dart
│   │       │   ├── admin_guia_form_screen.dart
│   │       │   ├── admin_categorias_screen.dart
│   │       │   ├── admin_disponibilidad_screen.dart
│   │       │   └── admin_reservaciones_screen.dart
│   │       └── widgets/
│   │           ├── admin_data_table.dart  ← Tabla genérica con paginación
│   │           └── admin_nav_drawer.dart
│   │
├── test/
│   ├── unit/
│   │   ├── validators_test.dart
│   │   └── tour_provider_test.dart
│   └── widget/
│       └── tour_card_test.dart
├── pubspec.yaml
└── README.md
```

---

## 🗺️ 7. Procedimiento Paso a Paso

---

### Fase 0 — Preparación y Configuración

1. Crear proyecto Flutter: `flutter create life_tours --org com.lifetours`
2. En Firebase Console: crear proyecto `life-tours`, **sin Analytics**, habilitar Auth (Email/Password), crear Firestore en modo producción.
3. Ejecutar `flutterfire configure` → seleccionar plataformas Android e iOS.
4. Verificar que `firebase_options.dart` fue generado en `lib/`.
5. Inicializar Git, crear `.gitignore` adecuado para Flutter (incluir `google-services.json` opcionalmente según el equipo), crear `README.md`.
6. Validar ejecución limpia en emulador con `flutter run`.

**Entregable:** Proyecto compilable, Firebase conectado, estructura Git lista.

---

### Fase 1 — Diseño y Prototipado

1. Definir en Figma: paleta de colores, tipografía, espaciados, componentes base (botones, inputs, cards).
2. Diseñar wireframes de las pantallas clave (Home, Detalle, Agendar, Perfil, Panel Admin).
3. Exportar assets a `assets/images/`, `assets/icons/`, `assets/fonts/`.
4. Documentar estados de UI por pantalla: vacío, cargando, éxito, error, sin conexión.
5. Definir paleta en `app_colors.dart` y tipografía en `app_theme.dart`.

**Entregable:** Guía de estilo, prototipo navegable en Figma, assets organizados.

---

### Fase 2 — Estructura del Proyecto y Arquitectura

1. Crear toda la estructura de carpetas definida en la Sección 6.
2. Implementar `app_theme.dart` con `ThemeData` (colores, fuentes, estilos de texto y botones).
3. Crear todos los modelos en `shared/models/` con métodos `fromMap()` y `toMap()` para Firestore.
4. Implementar providers vacíos (con estado inicial y sin lógica aún) para cada feature.
5. Configurar `go_router` en `routes.dart` con rutas protegidas según rol.
6. Implementar widgets genéricos reutilizables: `LoadingIndicator`, `ErrorMessage`, `EmptyState`.

**Entregable:** Esqueleto navegable, tema aplicado, modelos definidos, providers inicializados.

---

### Fase 3 — Autenticación

1. Inicializar `FirebaseCore` y `FirebaseAuth` en `main.dart`.
2. Implementar en `AuthProvider`: `register()`, `login()`, `logout()`, listener de `authStateChanges`.
3. Al registrar un usuario, crear su documento en Firestore (`/usuarios/{uid}`) con `rol: "turista"`.
4. Crear UI de Login y Registro con validación en tiempo real usando `validators.dart`.
5. Implementar pantalla de recuperación de contraseña (`sendPasswordResetEmail`).
6. Configurar `go_router` para redirigir según estado de sesión y rol:
   - Sin sesión → `/login`
   - Turista autenticado → `/home`
   - Admin autenticado → `/admin`

**Entregable:** Flujo de autenticación completo, sesión persistente, rutas protegidas por rol.

---

### Fase 4 — Base de Datos Firestore y Catálogo de Tours

1. Publicar reglas de seguridad de Firestore (ver Sección 3).
2. Crear datos de prueba en Firestore: 2–3 categorías, 2 guías, 4–5 tours con disponibilidades e itinerarios.
3. Implementar `TourProvider`: `fetchTours()`, `getTourById()`, `filterByCategoria()`, `searchByNombre()`.
4. Implementar `DisponibilidadProvider`: `fetchDisponibilidades(tourId)`, validación de cupos.
5. Construir `HomeScreen`: grid de tours con filtros y buscador conectado al provider.
6. Construir `TourDetailScreen`: galería, itinerario, disponibilidades y botón de reservar.

**Entregable:** Catálogo de tours funcional, datos reales desde Firestore, filtros operativos.

---

### Fase 5 — Reservaciones y Perfil de Usuario

1. Implementar `ReservacionProvider`:
   - `crearReservacion()`: valida cupos, crea documento en Firestore, decrementa `cuposDisponibles` (usar transacción de Firestore para evitar condiciones de carrera).
   - `fetchMisReservaciones(uid)`: historial del usuario.
   - `cancelarReservacion(id)`: cambia estado a `"cancelada"` y devuelve cupos.
2. Construir `AgendarScreen`: selector de disponibilidad, número de personas, resumen de monto y confirmación.
3. Construir `ConfirmacionScreen`: muestra código de confirmación y detalles.
4. Construir `ProfileScreen`: datos del usuario, lista de reservaciones con estado, opción de reseña en reservaciones completadas, logout.
5. Implementar `ResenaForm` para calificar un tour desde una reservación completada.

**Entregable:** Flujo completo de reserva, historial en perfil, reseñas funcionales.

---

### Fase 6 — Panel de Administrador

El panel de administrador permite gestionar todas las colecciones mediante operaciones CRUD. Es accesible únicamente con `rol: "admin"`.

**Colecciones gestionadas desde el panel:**

| Módulo Admin | Operaciones |
|---|---|
| Tours | Crear, leer (lista + detalle), editar, eliminar, cambiar estado |
| Guías | Crear, leer, editar, eliminar |
| Categorías | Crear, leer, editar, eliminar |
| Disponibilidades | Crear por tour, editar cupos/estado, eliminar |
| Reservaciones | Leer (todas), cambiar estado (confirmar, cancelar, completar) |
| Usuarios | Leer (lista), cambiar rol, desactivar cuenta |

**Implementación:**

1. Implementar `AdminProvider` con métodos genéricos por colección: `create()`, `update()`, `delete()`, `fetchAll()`.
2. Construir `AdminDashboardScreen` con accesos directos a cada módulo (tarjetas de resumen con conteos).
3. Construir `AdminDataTable` como widget genérico reutilizable: columnas configurables, paginación, botones de acción por fila.
4. Construir formularios específicos por entidad (usar `TextFormField`, `DropdownButton`, `DatePicker` según el campo).
5. Validar permisos en cada operación tanto en el cliente como en las reglas de Firestore.
6. Implementar diálogos de confirmación antes de eliminar registros.

**Entregable:** Panel admin completamente funcional con CRUD para todas las entidades.

---

### Fase 7 — Pulido UI/UX y Optimización

1. Aplicar transiciones de página con `go_router` (fade, slide).
2. Optimizar imágenes: `cached_network_image` con placeholder y manejo de error.
3. Implementar estado offline básico: detectar conectividad y mostrar aviso con `SnackBar`.
4. Revisar accesibilidad: `Semantics`, contrastes, escalado de fuentes.
5. Revisar rendimiento: usar `const` constructors, `Consumer` granular en lugar de `ChangeNotifierProvider` en el árbol completo.

**Entregable:** Experiencia fluida, lista para pruebas de usuario.

---

### Fase 8 — Pruebas y Validación

1. Pruebas unitarias: validadores de formularios, lógica de providers (mockear Firestore con `mockito`).
2. Pruebas de widget: `TourCard`, `BookingSummaryCard`, formularios con estados de error.
3. Prueba de integración manual: flujo login → explorar tours → agendar → ver en perfil.
4. Flujo admin: login admin → crear tour → agregar disponibilidad → ver reservación → cambiar estado.
5. Usar **Firebase Emulator Suite** para pruebas de Firestore sin afectar datos reales.
6. Documentar bugs encontrados y resolverlos antes de la Fase 9.

**Entregable:** Pruebas documentadas, flujos validados, app estable.

---

### Fase 9 — Preparación para Presentación / Despliegue

1. Generar ícono de app y splash screen con `flutter_launcher_icons` y `flutter_native_splash`.
2. Configurar nombre de la app, versión y permisos en `AndroidManifest.xml` (permisos de internet, cámara para `image_picker`).
3. Ejecutar `flutter build apk --release` para generar el APK de presentación.
4. Revisar que la app funciona correctamente con datos reales en Firestore (no emulador).
5. Preparar demostración: usuario turista de prueba + cuenta administrador de prueba con datos cargados.

**Entregable:** APK firmado en debug/release, demo lista, datos de prueba cargados.

---

## ✅ 8. Checklist de Validación por Fase

- [ ] `flutter doctor` limpio, emulador Android corriendo
- [ ] Firebase vinculado, `firebase_options.dart` generado, Analytics deshabilitado
- [ ] Auth: registro, login, logout y persistencia de sesión funcionando
- [ ] Roles funcionando: turista → `/home`, admin → `/admin`, sin sesión → `/login`
- [ ] Firestore: reglas de seguridad publicadas y probadas con el emulador
- [ ] Tours se cargan, filtran y muestran correctamente desde Firestore
- [ ] Disponibilidades se consultan por tour y reflejan cupos reales
- [ ] Reserva se crea, descuenta cupos y aparece en el perfil del usuario
- [ ] Cancelación restaura los cupos (transacción atómica verificada)
- [ ] Panel admin: CRUD completo para todas las colecciones funciona sin errores
- [ ] Formularios admin validan campos requeridos antes de escribir en Firestore
- [ ] UI responde a estados: loading, empty, error, success en todas las pantallas
- [ ] No existen crasheos en el flujo principal turista ni en el flujo admin
- [ ] Build APK release genera sin warnings críticos
- [ ] Datos de prueba cargados: categorías, guías, tours, disponibilidades

---

## 📎 9. Decisiones de Diseño Resumidas

| Decisión | Elección | Justificación |
|---|---|---|
| Base de datos | Firebase Firestore (Spark) | Integración nativa con Flutter, gratuito, tiempo real |
| Analytics | Deshabilitado | No requerido para el alcance académico |
| Gestión de estado | Provider + ChangeNotifier | Suficiente para el tamaño del proyecto, bien documentado |
| Navegación | go_router | Protección de rutas por rol, deep linking, patrón oficial de Flutter |
| Autenticación | Firebase Auth (Email/Password) | Simple, segura, sin necesidad de OAuth externo |
| Notificaciones | No incluidas | Fuera del alcance definido |
| Pagos | No incluidos | La reserva es digital; el cobro es presencial y ajeno a la app |
| Internacionalización | intl (español como idioma base) | Formato de fechas y moneda MXN |
