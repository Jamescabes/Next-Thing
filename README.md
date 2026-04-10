# Next Thing — Mobile (Flutter)

App de gestión de eventos con timeline para iOS y Android, replicando fielmente la versión web.

---

## Requisitos previos

- Flutter 3.x instalado y en PATH
- Dart SDK 3.3+
- Android Studio o Xcode (para iOS)
- Cuenta de Firebase

---

## 🚀 Setup en 5 pasos

### 1. Instalar Flutter
```bash
# Si aún no tienes Flutter, descárgalo de:
# https://docs.flutter.dev/get-started/install

flutter --version  # Debe ser 3.x
```

### 2. Crear proyecto Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. **Crear nuevo proyecto** → llámalo `next-thing-mobile` (o el nombre que prefieras)
3. Habilita **Authentication** → Email/Password
4. Habilita **Cloud Firestore** → Modo producción

**Reglas de Firestore** (Configuration > Rules):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Configurar Firebase con FlutterFire CLI

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Dentro del directorio del proyecto:
cd NextThing-Mobile

# Instalar dependencias primero
flutter pub get

# Configurar Firebase (esto sobreescribe firebase_options.dart con los valores reales)
flutterfire configure --project=TU_PROJECT_ID

# Selecciona android e ios cuando te lo pida
```

> **Alternativa manual**: En Firebase Console, descarga `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) y colócalos en sus carpetas correspondientes, luego edita `firebase_options.dart` con los valores de tu proyecto.

### 4. Agregar archivos de configuración Firebase

**Android** — descarga `google-services.json` de Firebase Console y colócalo en:
```
android/app/google-services.json
```

**iOS** — descarga `GoogleService-Info.plist` y colócalo en:
```
ios/Runner/GoogleService-Info.plist
```

### 5. Ejecutar la app

```bash
# Android
flutter run -d android

# iOS (requiere macOS + Xcode)
cd ios && pod install && cd ..
flutter run -d ios

# Ver dispositivos disponibles
flutter devices
```

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart                    # Entrada + providers + router
├── firebase_options.dart        # Config Firebase (generado por FlutterFire)
├── models/
│   └── task_model.dart          # Modelo TaskModel + NotificationOffset
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper
│   ├── firestore_service.dart   # CRUD Firestore
│   └── notification_service.dart # flutter_local_notifications
├── providers/
│   ├── auth_provider.dart       # Estado de autenticación
│   ├── task_provider.dart       # Lista de tareas + stream Firestore
│   ├── theme_provider.dart      # Dark/Light mode
│   └── notification_provider.dart # Preferencias de notificaciones
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   └── home/
│       └── home_screen.dart     # Timeline principal
├── widgets/
│   ├── task_card.dart           # Tarjeta de evento con colores
│   ├── time_indicator.dart      # Separador "AHORA" parpadeante
│   ├── event_bottom_sheet.dart  # Crear/editar evento
│   ├── color_picker_widget.dart # Selector de 6 colores preset
│   ├── date_time_picker_widget.dart # Picker fecha+hora tipo drum
│   ├── side_panel.dart          # Panel lateral izquierdo
│   ├── history_bottom_sheet.dart # Historial lista + calendario
│   └── notification_settings_sheet.dart
└── theme/
    └── app_theme.dart           # ThemeData light/dark + colores
```

---

## ✨ Funcionalidades implementadas

| Feature | Estado |
|---------|--------|
| Login / Sign Up con Firebase Auth | ✅ |
| Timeline con separador AHORA | ✅ |
| Crear / Editar evento (bottom sheet) | ✅ |
| 6 colores preset + dark mode equivalent | ✅ |
| Completar tarea (checkbox) | ✅ |
| Side panel con perfil y settings | ✅ |
| Dark / Light mode (persistido) | ✅ |
| Historial — vista Lista | ✅ |
| Historial — vista Calendario | ✅ |
| Notificaciones locales programables | ✅ |
| Paginación de eventos pasados | ✅ |
| Animaciones fluidas (spring, fade, slide) | ✅ |
| Datos por usuario (Firestore) | ✅ |
| Cerrar sesión / Eliminar cuenta | ✅ |

---

## 🎨 Design System

Los colores replican exactamente la web:

| Color | Light | Dark |
|-------|-------|------|
| Fondo | #FDFDFD | #0A0A0A |
| Texto | #1A1A1A | #F0F0F0 |
| Verde | #E0F2F1 | #1B5E20 |
| Amarillo | #FFF9C4 | #F57F17 |
| Rojo | #FFCDD2 | #B71C1C |
| Azul | #E3F2FD | #0D47A1 |
| Rosa | #F8BBD0 | #880E4F |

Fuente: **Inter** via `google_fonts`

---

## 🔧 Dependencias principales

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
provider: ^6.1.2
flutter_local_notifications: ^17.2.4
google_fonts: ^6.2.1
intl: ^0.19.0
shared_preferences: ^2.3.2
timezone: ^0.9.4
```
