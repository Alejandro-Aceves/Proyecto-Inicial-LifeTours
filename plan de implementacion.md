# 📋 Plan de Implementación: **LifeTours** (Flutter/Dart + Firebase)
> *Aplicación multiplataforma para agendar tours. Documento de planificación técnica y procedimental. Sin código.*

---

## 🛠️ 1. Herramientas y Configuración del Entorno
| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| **SDK & Lenguaje** | Flutter SDK (última versión estable), Dart SDK | Desarrollo multiplataforma |
| **IDE** | Visual Studio Code | Editor principal |
| **Extensiones VS Code** | `Flutter`, `Dart`, `Firebase`, `GitLens`, `Error Lens`, `Pubspec Assist`, `Flutter Riverpod/Provider Snippets` (opcional) | Productividad y diagnóstico |
| **CLI & Cloud** | Firebase CLI, `flutterfire` CLI, `git` | Configuración de servicios y versionado |
| **Plataforma Nativa** | Android Studio (SDK/Emuladores), Xcode (macOS/iOS) | Compilación y pruebas nativas |
| **Diseño** | Figma / Adobe XD | Prototipado UI/UX y especificaciones |
| **Control de Calidad** | `flutter test`, Firebase Emulator Suite, Postman/Insomnia (si hay APIs externas) | Validación y simulación |

✅ **Pre-requisitos de Configuración:**
- Instalar Flutter y validar con `flutter doctor`
- Configurar cuenta Firebase y proyecto `LifeTours`
- Ejecutar `flutterfire configure` para generar `firebase_options.dart`
- Configurar repositorio Git con rama `main` (producción) y `develop`

---

## 🎨 2. Principios UI/UX y Flujo de Usuario
### 📐 Principios de Diseño
- **Minimalismo funcional:** Priorizar claridad sobre decoración. Espacios en blanco, tipografía legible, paleta coherente.
- **Jerarquía visual:** Títulos > Descripción > CTA (Call to Action). Botones primarios destacados, secundarios discretos.
- **Accesibilidad:** Contraste WCAG AA, tamaños de toque ≥ 44x44dp, soporte para lectores de pantalla.
- **Feedback inmediato:** Estados de carga, éxito, error y offline visibles en todo momento.

### 🔄 Flujo de Usuario Esperado
1. `Splash` → 2. `Onboarding` (opcional) → 3. `Auth` (Login/Registro) → 4. `Home` (Tours destacados) → 5. `Detalle de Tour` → 6. `Agendar/Reservar` → 7. `Confirmación` → 8. `Perfil & Mis Reservas`

### 📱 Pantallas Clave
| Pantalla | Elementos Críticos |
|----------|-------------------|
| Autenticación | Email, Contraseña, Validación en tiempo real, Recuperación |
| Home | Lista/Grid de tours, Filtros (fecha, categoría, precio), Búsqueda |
| Detalle | Galería, Descripción, Itinerario, Precio, Disponibilidad, CTA |
| Agendar | Selector de fecha/hora, Número de personas, Resumen, Pago (placeholder o integrado) |
| Perfil | Datos usuario, Historial de reservas, Configuración, Cierre de sesión |

---

## 🏗️ 3. Arquitectura y Gestión de Estado
- **Patrón:** Feature-First + Capas (Presentation, Domain/Logic, Data)
- **Estado:** `provider` con `ChangeNotifier` por feature (`AuthProvider`, `TourProvider`, `BookingProvider`)
- **Navegación:** `Navigator 2.0` o `go_router` (recomendado para deep linking y protección de rutas)
- **Datos Remotos:** Firebase Auth (email/password), Cloud Firestore (tours, usuarios, reservas)
- **Local/Cache:** `shared_preferences` (settings básicos), `cached_network_image` (imágenes), estrategia offline básica para listas

🔒 **Seguridad de Datos:**
- Reglas de Firestore por colección: `users` (solo propio), `tours` (lectura pública/escritura admin), `bookings` (solo creador)
- Validación de formularios antes de enviar a Firebase
- Manejo centralizado de errores (`FirebaseAuthException`, `FirebaseException`)

---

## 📦 4. Dependencias Clave (`pubspec.yaml`)
*(Versiones placeholders, ajustar a la última estable al momento de implementación)*

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  provider: ^latest
  go_router: ^latest          # Navegación declarativa y protección de rutas
  cached_network_image: ^latest
  intl: ^latest               # Formato de fechas y monedas
  flutter_svg: ^latest        # Iconos/illustraciones SVG
  shared_preferences: ^latest
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^latest
  mockito: ^latest            # Testing
  build_runner: ^latest
```

📌 **Notas:**
- Mantener `pubspec.yaml` limpio: agrupar por funcionalidad, comentar secciones.
- Usar `flutter pub get` y `flutter pub upgrade` regularmente.
- Considerar `freezed` + `json_serializable` si los modelos crecen en complejidad.

---

## 🗺️ 5. Procedimiento Paso a Paso (Sin Código)

### 🔹 Fase 0: Preparación y Configuración
1. Crear proyecto Flutter: `flutter create life_tours`
2. Configurar Firebase: crear proyecto, habilitar Auth (Email/Password) y Firestore
3. Ejecutar `flutterfire configure` y vincular Android/iOS/Web
4. Configurar Git, ramas, `.gitignore` y `README.md`
5. Validar ejecución en emuladores iOS/Android y en dispositivo físico

✅ *Entregable:* Proyecto compilable, Firebase conectado, estructura Git lista.

---

### 🔹 Fase 1: Diseño y Prototipado
1. Definir paleta, tipografía y componentes base en Figma
2. Crear wireframes → mockups de alta fidelidad de las 5-6 pantallas clave
3. Exportar assets (logos, íconos, placeholders) y definir rutas en `assets/`
4. Documentar estados UI: vacío, carga, éxito, error, sin conexión

✅ *Entregable:* Guía de estilo, prototipo navegable, assets organizados.

---

### 🔹 Fase 2: Estructura del Proyecto y Arquitectura
1. Crear carpetas base: `lib/core/`, `lib/features/`, `lib/shared/`
2. Definir tema global (`ThemeData`), constantes (`app_colors`, `app_strings`), utilidades
3. Crear modelo de datos conceptual: `User`, `Tour`, `Booking`
4. Implementar proveedores base vacíos (`AuthProvider`, `TourProvider`, `BookingProvider`)
5. Configurar enrutador y proteger rutas autenticadas

✅ *Entregable:* Esqueleto navegable, tema aplicado, proveedores inicializados.

---

### 🔹 Fase 3: Integración Firebase y Autenticación
1. Inicializar `FirebaseCore` y `FirebaseAuth` en `main.dart`
2. Implementar lógica de registro/login/logout en `AuthProvider`
3. Crear UI de login/registro con validación básica
4. Manejar estados de sesión: listener de `authStateChanges`
5. Implementar recuperación de contraseña y verificación de email (opcional Fase 7)

✅ *Entregable:* Flujo de autenticación completo, sesión persistente, protección de rutas.

---

### 🔹 Fase 4: Base de Datos Firestore y Modelo de Tours
1. Diseñar colecciones: `tours`, `users`, `bookings`
2. Crear reglas de seguridad en Firebase Console
3. Implementar `TourProvider` con operaciones: `fetchTours`, `getTourById`, `filterTours`
4. Manejar snapshots, paginación y estados de carga/error
5. Validar estructura de documentos con datos de prueba

✅ *Entregable:* Lectura/escritura segura de tours, UI reflejando datos en tiempo real.

---

### 🔹 Fase 5: Funcionalidades Core (Agendar y Perfil)
1. Implementar `BookingProvider`: crear reserva, validar disponibilidad, asociar a usuario
2. UI de selección de fecha/hora, cantidad de personas, confirmación
3. Pantalla de perfil: datos usuario, historial de reservas, cierre de sesión
4. Sincronizar estado entre proveedores (ej: booking actualiza lista de usuario)
5. Implementar feedback visual (snackbars, diálogos de confirmación, loading)

✅ *Entregable:* Flujo completo de reserva, perfil funcional, estado sincronizado.

---

### 🔹 Fase 6: Pulido UI/UX y Optimización
1. Aplicar animaciones sutiles (transiciones, microinteracciones)
2. Optimizar imágenes (caché, tamaños responsivos, placeholders)
3. Implementar manejo de errores global y estados offline básicos
4. Accesibilidad: labels, contraste, escalado de texto
5. Revisión de rendimiento: evitar rebuilds innecesarios, usar `const`, `Provider.of(context, listen: false)`

✅ *Entregable:* Experiencia fluida, lista para pruebas de usuario.

---

### 🔹 Fase 7: Pruebas y Validación
1. Pruebas unitarias: validación de formularios, lógica de proveedores
2. Pruebas de widget: componentes clave, estados de carga/error
3. Pruebas de integración: flujo login → tour → reserva → perfil
4. Simular Firebase con Emulator Suite para pruebas locales
5. Documentar casos de prueba y corregir bugs críticos

✅ *Entregable:* Suite de pruebas, reporte de estabilidad, código libre de errores conocidos.

---

### 🔹 Fase 8: Preparación para Despliegue
1. Generar íconos y splash screen multiplataforma
2. Configurar `android/app/build.gradle` y `ios/Runner` (versiones, permisos, nombres)
3. Firmar apps (keystore Android, provisioning profile iOS)
4. Ejecutar builds: `flutter build apk/appbundle`, `flutter build ipa`
5. Preparar metadatos para Google Play Console y App Store Connect
6. Configurar CI/CD opcional (GitHub Actions, Codemagic)

✅ *Entregable:* Binarios firmados, metadatos listos, pipeline de despliegue definido.

---

## 📁 6. Estructura de Directorios Sugerida
```
life_tours/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── errors/
│   ├── features/
│   │   ├── auth/
│   │   ├── tours/
│   │   ├── booking/
│   │   └── profile/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── providers/
│   ├── routes.dart
│   └── main.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
├── pubspec.yaml
└── README.md
```

---

## ✅ 7. Checklist de Validación por Fase
- [ ] `flutter doctor` limpio y emuladores funcionando
- [ ] Firebase vinculado y `firebase_options.dart` generado
- [ ] Reglas de Firestore publicadas y probadas
- [ ] Autenticación funciona (registro, login, logout, persistencia)
- [ ] Tours se cargan, filtran y muestran sin errores
- [ ] Reserva se guarda en Firestore y aparece en perfil
- [ ] UI responde a estados: loading, empty, error, success
- [ ] Build Android/iOS genera sin warnings críticos
- [ ] Tests unitarios/widget cubren lógica crítica (>60% cobertura recomendada)

---
