# FarmaMap Sevilla 🏥

Aplicación Flutter multiplataforma para localizar farmacias en la provincia de Sevilla, con mapa interactivo, búsqueda en tiempo real y navegación GPS.

## Stack Técnico

- **Flutter** 3.41+ con null safety
- **Supabase** (PostgreSQL) como backend
- **flutter_map** + OpenStreetMap (sin API key)
- **Riverpod** para gestión de estado
- **GoRouter** para navegación
- **Freezed** + json_serializable para modelos
- **Clean Architecture** (data → domain → presentation)

---

## 🚀 Setup Paso a Paso

### 1. Crear proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto (región: EU West recomendado)
3. Anota tu **Project URL** y **anon public key** (Settings → API)

### 2. Ejecutar el SQL de creación de tabla

1. En Supabase, ve a **SQL Editor**
2. Copia y pega el contenido de [`supabase/schema.sql`](supabase/schema.sql)
3. Ejecuta el script — esto crea:
   - La tabla `farmacias`
   - Índices geoespaciales
   - La función `farmacias_cercanas()` para búsquedas por radio
   - Política RLS de lectura pública

### 3. Poblar la base de datos (Seed)

#### Opción A: Script Dart (recomendado)

```bash
# Instalar dependencias del script
dart pub add supabase --directory=tools 2>/dev/null || true

# Ejecutar el seed
dart run tools/seed_farmacias.dart <TU_SUPABASE_URL> <TU_SUPABASE_ANON_KEY>
```

El script lee `data/farmacias_sevilla.json`, filtra registros sin coordenadas válidas, y los inserta en lotes de 50.

#### Opción B: Importar manualmente

1. En Supabase → Table Editor → farmacias
2. Usa la opción "Import data from CSV"
3. Convierte el JSON a CSV previamente

### 4. Configurar credenciales

Las credenciales de Supabase se pasan via `--dart-define` al ejecutar la app:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```

**⚠️ Nunca hardcodees las claves en el código fuente.**

### 5. Instalar dependencias y generar código

```bash
# Instalar dependencias
flutter pub get

# Generar código de freezed y json_serializable
dart run build_runner build --delete-conflicting-outputs
```

### 6. Ejecutar la app

```bash
# Android
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key

# iOS (requiere macOS + Xcode)
flutter run --target-platform ios \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```

---

## 📱 Pantallas

| Pantalla | Descripción |
|----------|-------------|
| **MapScreen** | Mapa interactivo con marcadores de farmacias, ubicación del usuario, y selector de radio |
| **ListScreen** | Lista paginada ordenada por distancia con pull-to-refresh |
| **SearchScreen** | Búsqueda en tiempo real con debounce, historial y highlighting |
| **DetailScreen** | Detalle con mini-mapa, dirección, distancia y navegación GPS |
| **FavoritosScreen** | Farmacias guardadas como favoritas (persistidas localmente) |

---

## 🏗 Arquitectura

```
lib/
├── core/
│   ├── theme/          # AppTheme, colores, tipografía
│   ├── router/         # GoRouter config
│   ├── constants/      # Constantes globales y de Supabase
│   └── extensions/     # Extensions útiles
├── data/
│   ├── models/         # Farmacia (freezed)
│   ├── repositories/   # Interfaz + implementación Supabase
│   └── datasources/    # SupabaseFarmaciasDatasource
├── domain/
│   └── usecases/       # GetFarmaciasCercanas, SearchFarmacias, GetAllFarmacias
├── presentation/
│   ├── providers/      # Riverpod providers
│   ├── screens/        # 5 pantallas completas
│   └── widgets/        # Widgets reutilizables
└── main.dart
```

---

## 🎨 Tema

- **Primary**: `#00A86B` (verde farmacia)
- **Secondary**: `#005F3E` (verde oscuro)
- **Fuente**: Poppins (Google Fonts)
- **Soporte**: Tema claro y oscuro automático

---

## 📋 Permisos

### Android (`AndroidManifest.xml`)
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `INTERNET`

### iOS (`Info.plist`)
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

---

## 📄 Licencia

Proyecto privado — Todos los derechos reservados.
