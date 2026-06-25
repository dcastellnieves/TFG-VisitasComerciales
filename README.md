# TFG-VisitasComerciales

Repositorio del código de Clara.

## Descripción

Este proyecto está desarrollado principalmente con **Dart** (ecosistema Flutter), e integra componentes nativos y de soporte en otros lenguajes (JavaScript, CMake, C++, HTML y Swift) para compilación y despliegue en distintas plataformas.

## Tecnologías utilizadas

Según la composición del repositorio:

- **Dart** (~77.2%)
- **JavaScript** (~9.6%)
- **CMake** (~5.7%)
- **C++** (~3.7%)
- **HTML** (~1.8%)
- **Swift** (~1.4%)
- **Otros** (~0.6%)

Tecnologías clave del proyecto:

- **Flutter / Dart SDK**
- **Android SDK** (para despliegue Android)
- **Xcode + Swift** (para despliegue iOS, en macOS)
- **Toolchain nativa** (CMake/C++) para dependencias o plugins con código nativo
- **Node.js / npm** (si se usan scripts o utilidades JS del proyecto)

---

## Requisitos previos para despliegue

> Recomendación: usar versiones estables y actualizadas de cada herramienta.

### 1) Sistema operativo

- **Windows / Linux / macOS** para desarrollo general.
- **macOS obligatorio** para compilar/desplegar en **iOS**.

### 2) Flutter y Dart

- Flutter SDK instalado y configurado en el `PATH`.
- Dart SDK (normalmente incluido con Flutter).
- Verificación:
  ```bash
  flutter --version
  dart --version
  flutter doctor
  ```

### 3) Git

- Git instalado para clonar y gestionar el código.
  ```bash
  git --version
  ```

### 4) Android (si aplica)

- Android Studio (o SDK/Command-line tools).
- Android SDK Platform + Build Tools.
- Emulador o dispositivo físico con depuración USB.

Verifica con:
```bash
flutter doctor --android-licenses
flutter doctor
```

### 5) iOS (si aplica)

- **Xcode** instalado (última versión compatible).
- CocoaPods instalado:
  ```bash
  sudo gem install cocoapods
  pod --version
  ```
- Certificados/perfiles aprovisionamiento para despliegue real en dispositivos o App Store.

### 6) Toolchain nativa (CMake/C++)

En caso de módulos nativos:

- **CMake** instalado.
- Compilador C/C++ (clang/gcc/msvc según plataforma).

Comprobación:
```bash
cmake --version
```

### 7) Node.js (si aplica)

Si hay scripts auxiliares en JavaScript:

```bash
node --version
npm --version
```

---

## Puesta en marcha (entorno local)

1. Clonar repositorio:
   ```bash
   git clone https://github.com/dcastellnieves/TFG-VisitasComerciales.git
   cd TFG-VisitasComerciales
   ```

2. Instalar dependencias de Flutter:
   ```bash
   flutter pub get
   ```

3. Verificar entorno:
   ```bash
   flutter doctor
   ```

4. Ejecutar en modo desarrollo:
   ```bash
   flutter run
   ```

---

## Build y despliegue

### Android (APK)

```bash
flutter build apk --release
```

Salida habitual:
`build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle)

```bash
flutter build appbundle --release
```

Salida habitual:
`build/app/outputs/bundle/release/app-release.aab`

### iOS (desde macOS)

```bash
flutter build ios --release
```

Luego abrir `ios/Runner.xcworkspace` en Xcode para firma y publicación.

### Web (si está habilitado en el proyecto)

```bash
flutter build web --release
```

Salida habitual:
`build/web/`

---

## Variables de entorno y configuración

Si el proyecto usa configuración por entorno, se recomienda:

- Definir variables en `.env` o mediante `--dart-define`.
- No versionar secretos (tokens, claves privadas).
- Mantener un archivo de ejemplo (`.env.example`) con placeholders.

Ejemplo:
```bash
flutter run --dart-define=API_BASE_URL=https://api.midominio.com
```

---

## Checklist de despliegue

- [ ] `flutter doctor` sin errores críticos
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Firma de aplicación configurada (Android/iOS)
- [ ] Variables de entorno de producción definidas
- [ ] Build release generado sin errores
- [ ] Pruebas básicas de humo realizadas en dispositivo real

---

## Resolución de problemas comunes

1. **Dependencias rotas o caché corrupta**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Problemas con Pods en iOS**
   ```bash
   cd ios
   pod repo update
   pod install
   cd ..
   ```

3. **Licencias Android pendientes**
   ```bash
   flutter doctor --android-licenses
   ```

---

## Autoría

Proyecto: **TFG-VisitasComerciales**  
Repositorio: https://github.com/dcastellnieves/TFG-VisitasComerciales
