# Fund Manager

Una aplicación web moderna de gestión de fondos desarrollada con Flutter, diseñada para proporcionar una experiencia de usuario excepcional en dispositivos móviles, tablets y desktop.

## 🚀 Características Principales

### ✨ Funcionalidades Core
- **Gestión Completa de Fondos**: Visualización, análisis y seguimiento de inversiones
- **Dashboard Interactivo**: Resumen ejecutivo con métricas clave y gráficos
- **Sistema de Transacciones**: Historial detallado de operaciones financieras
- **Configuraciones Personalizables**: Temas claro/oscuro y preferencias de usuario
- **Navegación Intuitiva**: Breadcrumbs y sidebar responsive

### 🏗️ Arquitectura y Tecnologías
- **Clean Architecture**: Separación clara de capas (Data, Domain, Presentation)
- **Flutter Bloc**: Manejo de estado reactivo y predecible
- **Flutter Navigator 2.0**: Navegación moderna con Router, RouterDelegate y RouteInformationParser
- **Diseño Responsive**: Adaptable a móvil (<768px), tablet (768-1440px) y desktop (>1440px)
- **Testing Completo**: Pruebas unitarias, de widgets y BLoCs
- **Inyección de Dependencias**: Configuración con Flutter Bloc Provider

## 📁 Estructura del Proyecto

```
lib/
├── core/                          # Infraestructura compartida
│   ├── blocs/                     # BLoCs globales (App, Theme)
│   ├── constants/                 # Constantes de la aplicación
│   ├── di/                        # Inyección de dependencias
│   ├── errors/                    # Manejo centralizado de errores
│   ├── navigation/                # Configuración de navegación
│   ├── network/                   # Cliente HTTP (Dio)
│   ├── providers/                 # Proveedores de BLoCs
│   ├── services/                  # Servicios globales
│   ├── utils/                     # Utilidades compartidas
│   └── widgets/                   # Widgets reutilizables
├── features/                      # Características de la aplicación
│   ├── welcome/                   # Página de bienvenida
│   │   └── presentation/
│   │       ├── blocs/
│   │       └── pages/
│   ├── dashboard/                 # Dashboard principal
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── blocs/
│   │       └── pages/
│   ├── funds/                     # Gestión de fondos
│   │   ├── data/
│   │   ├── domain/
│   │   │   ├── models/            # Fund, Transaction, UserFund, User
│   │   │   └── services/
│   │   └── presentation/
│   │       ├── blocs/
│   │       └── pages/
│   ├── transactions/              # Gestión de transacciones
│   │   └── presentation/
│   │       ├── blocs/
│   │       └── pages/
│   └── settings/                  # Configuraciones
│       └── presentation/
│           ├── blocs/
│           └── pages/
├── shared/                        # Recursos compartidos
└── main.dart                      # Punto de entrada
```

## 🛠️ Stack Tecnológico

### Dependencias Principales
```yaml
# State Management
flutter_bloc: ^8.1.4          # Manejo de estado reactivo
equatable: ^2.0.5             # Comparación de objetos

# HTTP Client
dio: ^5.4.0                   # Cliente HTTP robusto

# UI Components
fl_chart: ^0.66.2             # Gráficos interactivos

# Utils
logger: ^2.0.2+1              # Logging estructurado
intl: ^0.19.0                 # Internacionalización
shared_preferences: ^2.2.2    # Almacenamiento local
```

### Dependencias de Desarrollo
```yaml
# Testing
bloc_test: ^9.1.5             # Testing de BLoCs
mocktail: ^1.0.3              # Mocking para tests

# Code Quality
flutter_lints: ^5.0.0         # Reglas de linting
```

## 🚀 Configuración del Proyecto

### Prerrequisitos
- **Flutter SDK**: 3.27.4 o superior
- **Dart SDK**: 3.6.2 o superior
- **Navegador**: Chrome, Firefox, Safari o Edge (para desarrollo web)

### Instalación y Configuración

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd fund_manager
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar configuración**
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación**
   ```bash
   # Desarrollo web
   flutter run -d chrome
   
   # Con hot reload
   flutter run -d chrome --hot
   ```

## 🧪 Testing

### Ejecutar Suite Completa de Tests
```bash
# Todos los tests
flutter test

# Con cobertura
flutter test --coverage

# Generar reporte HTML de cobertura
genhtml coverage/lcov.info -o coverage/html
```

### Tests Específicos
```bash
# Tests unitarios
flutter test test/unit/

# Tests de widgets
flutter test test/widgets/

# Tests de BLoCs
flutter test test/blocs/

# Tests de navegación
flutter test test/navigation/
```

### Estructura de Tests
```
test/
├── blocs/                     # Tests de BLoCs
├── navigation/                # Tests de navegación
├── pages/                     # Tests de páginas
├── unit/                      # Tests unitarios
├── widgets/                   # Tests de widgets
└── test_utils.dart           # Utilidades para testing
```

## 📱 Características de la Aplicación

### 🏠 Página de Bienvenida
- **Animaciones Elegantes**: Transiciones suaves y efectos visuales atractivos
- **Diseño Responsive**: Adaptable a todos los dispositivos
- **Gradientes Modernos**: Paleta de colores profesional
- **Navegación Intuitiva**: Transición automática al dashboard

### 📊 Dashboard Principal
- **Métricas Clave**: Resumen ejecutivo de fondos y rendimiento
- **Gráficos Interactivos**: Visualización de datos con fl_chart
- **Actividad Reciente**: Timeline de transacciones
- **Widgets Responsive**: Adaptación automática al tamaño de pantalla

### 💰 Gestión de Fondos
- **Lista de Fondos**: Vista completa con información detallada
- **Tarjetas Informativas**: Diseño moderno con métricas clave
- **Acciones Rápidas**: Acceso directo a detalles y transacciones
- **Filtros y Búsqueda**: Navegación eficiente

### 📈 Transacciones
- **Historial Completo**: Todas las operaciones financieras
- **Filtros Avanzados**: Por fecha, tipo, monto
- **Detalles Expandidos**: Información completa de cada transacción

### ⚙️ Configuraciones
- **Tema Claro/Oscuro**: Cambio dinámico de apariencia
- **Preferencias de Usuario**: Personalización de la experiencia
- **Configuración de Notificaciones**: Control de alertas

## 🎨 Diseño Responsive

### Servicio Responsive Personalizado
La aplicación utiliza un servicio responsive personalizado basado en `MediaQuery` que proporciona:
- **Control preciso de tamaños de fuente**: Evita problemas de escalado automático
- **Breakpoints optimizados**: Móvil (<768px), Tablet (768-1024px), Desktop (>1024px)
- **Tamaños de fuente controlados**: Escalado manual para mejor legibilidad
- **Migración completada**: Todos los archivos han sido actualizados exitosamente

### Breakpoints Optimizados
```dart
// Móvil: < 768px
// Tablet: 768px - 1024px  
// Desktop: > 1024px
```

### Widgets Responsive
- **ResponsiveWidget**: Adapta contenido según el tamaño de pantalla
- **ResponsiveBuilder**: Builder pattern para lógica responsive
- **ResponsivePadding**: Padding adaptativo con valores optimizados
- **ResponsiveSpacing**: Espaciado adaptativo vertical y horizontal
- **ResponsiveText**: Texto con tamaños de fuente responsive
- **ResponsiveContainer**: Container con ancho responsive
- **ResponsiveGrid**: Grid con columnas adaptativas
- **ResponsiveList**: Lista con espaciado responsive

### Mejoras de UX
- **Tipografía Adaptativa**: Tamaños de fuente optimizados por dispositivo usando MediaQuery
- **Espaciado Inteligente**: Densidad de información balanceada
- **Navegación Contextual**: Sidebar en desktop, bottom nav en móvil
- **Touch-Friendly**: Elementos táctiles optimizados para móvil
- **Servicio Responsive**: Control centralizado de breakpoints y tamaños

## 🔧 Configuración de Desarrollo

### Variables de Entorno
```dart
// API Configuration
static const String baseUrl = 'https://api.fundmanager.com';
static const String apiVersion = '/v1';
static const Duration connectionTimeout = Duration(seconds: 30);

// Responsive Breakpoints
static const double mobileBreakpoint = 768;
static const double tabletBreakpoint = 1024;
static const double desktopBreakpoint = 1440;
```


### Linting y Formato
```bash
# Verificar código
flutter analyze

# Formatear código
dart format lib/ test/

# Verificar dependencias
flutter pub deps
```

## 🚀 Despliegue

### Build para Producción
```bash
# Web
flutter build web --release

# Optimización adicional
flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false
```


## 📝 Convenciones de Código

### Nomenclatura
- **Archivos**: `snake_case.dart` (ej: `custom_button.dart`)
- **Clases**: `PascalCase` (ej: `CustomButton`)
- **Variables**: `camelCase` (ej: `isLoading`)
- **Constantes**: `SCREAMING_SNAKE_CASE` (ej: `APP_NAME`)
- **BLoCs**: `FeatureBloc`, `FeatureEvent`, `FeatureState`

### Estructura de Archivos
```
feature/
├── data/
│   ├── datasources/     # Fuentes de datos
│   ├── models/          # Modelos de datos
│   └── repositories/    # Implementaciones
├── domain/
│   ├── entities/        # Entidades de dominio
│   ├── repositories/    # Interfaces
│   └── usecases/        # Casos de uso
└── presentation/
    ├── blocs/           # BLoCs
    ├── pages/           # Páginas
    └── widgets/         # Widgets específicos
```


## 🤝 Contribución

### Proceso de Contribución
1. **Fork** el proyecto
2. **Crea** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

### Estándares de Código
- Seguir las convenciones de nomenclatura
- Escribir tests para nuevas funcionalidades
- Mantener cobertura de código > 80%
- Documentar APIs públicas
- Usar commits semánticos

## 🆘 Soporte y Contacto

### Recursos de Ayuda
- **Documentación**: Revisar comentarios en el código
- **Issues**: Crear issues en GitHub para bugs o features
- **Discussions**: Usar GitHub Discussions para preguntas

### Información del Proyecto
- **Versión**: 1.0.0+1
- **Licencia**: MIT
- **Plataformas**: Web (Chrome, Firefox, Safari, Edge)
- **Estado**: En desarrollo activo

---

**Desarrollado con ❤️ usando Flutter**

