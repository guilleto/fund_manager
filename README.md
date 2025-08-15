# Fund Manager

Una aplicación web de gestión de fondos desarrollada con Flutter.

## 🚀 Características

- **Arquitectura Limpia**: Implementación completa de Clean Architecture con separación clara de capas
- **Flutter Bloc**: Manejo de estado reactivo y predecible
- **Diseño Responsive**: Adaptable a diferentes tamaños de pantalla (móvil, tablet, desktop)
- **Navegación Moderna**: Flutter Navigator 2.0 nativo con Router, RouterDelegate y RouteInformationParser
- **Testing Completo**: Pruebas unitarias y de widgets con Flutter Test
- **Inyección de Dependencias**: Configuración con GetIt e Injectable
- **API REST Simulada**: Mocks locales para desarrollo

## 📁 Estructura del Proyecto

```
lib/
├── core/                          # Capa de infraestructura compartida
│   ├── constants/                 # Constantes de la aplicación
│   ├── di/                       # Inyección de dependencias
│   ├── errors/                   # Manejo de errores
│   ├── network/                  # Configuración de red
│   ├── utils/                    # Utilidades compartidas
│   └── widgets/                  # Widgets reutilizables
├── features/                     # Características de la aplicación
│   ├── auth/                     # Autenticación
│   │   ├── data/                 # Capa de datos
│   │   ├── domain/               # Capa de dominio
│   │   └── presentation/         # Capa de presentación
│   ├── dashboard/                # Dashboard principal
│   └── funds/                    # Gestión de fondos
└── shared/                       # Recursos compartidos
```

## 🛠️ Tecnologías Utilizadas

### Dependencias Principales
- **flutter_bloc**: ^8.1.4 - Manejo de estado
- **equatable**: ^2.0.5 - Comparación de objetos
- **get_it**: ^7.6.7 - Inyección de dependencias
- **injectable**: ^2.3.2 - Generación de código para DI
- **dio**: ^5.4.0 - Cliente HTTP
- **Navegación**: Flutter Navigator 2.0 nativo
- **flutter_screenutil**: ^5.9.0 - Diseño responsive
- **json_annotation**: ^4.8.1 - Serialización JSON

### Dependencias de Desarrollo
- **build_runner**: ^2.4.8 - Generación de código
- **json_serializable**: ^6.7.1 - Serialización JSON
- **injectable_generator**: ^2.4.1 - Generador para DI
- **bloc_test**: ^9.1.5 - Testing de BLoCs
- **mockito**: ^5.4.4 - Mocking para tests
- **mocktail**: ^1.0.3 - Mocking alternativo

## 🚀 Configuración del Proyecto

### Prerrequisitos
- Flutter SDK 3.27.4
- Dart SDK 3.6.2

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd fund_manager
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar código**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run -d chrome
   ```

## 🧪 Testing

### Ejecutar todas las pruebas
```bash
flutter test
```

### Ejecutar pruebas específicas
```bash
flutter test test/unit/validation_utils_test.dart
flutter test test/widgets/custom_button_test.dart
flutter test test/widgets/welcome_page_test.dart
flutter test test/navigation/app_router_test.dart
```

### Cobertura de código
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Características de la Aplicación

### Página de Bienvenida
- Animaciones elegantes de entrada y transición
- Diseño responsive con gradientes atractivos
- Transición suave hacia el dashboard

### Dashboard
- Resumen de fondos y estadísticas
- Actividad reciente
- Diseño adaptable (móvil, tablet, desktop)

### Gestión de Fondos
- Lista de fondos con información detallada
- Estadísticas de rendimiento
- Acciones para cada fondo (ver detalles, transacciones)

### Navegación
- Flutter Navigator 2.0 nativo implementado
- RouterDelegate personalizado para manejo de estado
- RouteInformationParser para parsing de URLs
- Breadcrumb de navegación para mejor UX
- Rutas definidas para welcome, dashboard y fondos
- Animaciones de transición entre páginas

## 🎨 Diseño Responsive

La aplicación utiliza breakpoints optimizados para mejor legibilidad:
- **Móvil**: < 768px (mejor espaciado y tamaños de fuente)
- **Tablet**: 768px - 1440px
- **Desktop**: > 1440px

### Widgets Responsive Mejorados
- `ResponsiveWidget`: Adapta contenido según el tamaño de pantalla
- `ResponsiveBuilder`: Builder pattern para lógica responsive
- `ResponsivePadding`: Padding adaptativo con valores optimizados
- `ResponsiveSpacing`: Espaciado adaptativo vertical y horizontal

### Mejoras de Legibilidad
- Tamaños de fuente optimizados para móvil
- Espaciado mejorado entre elementos
- Mejor densidad de información
- Textos con overflow controlado
- Aspect ratios optimizados para tarjetas

## 🔧 Configuración de Desarrollo

### Generación de Código
El proyecto utiliza code generation para:
- Inyección de dependencias (Injectable)
- Serialización JSON (json_serializable)

Para regenerar el código después de cambios:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Estructura de Features
Cada feature sigue la arquitectura limpia:

```
feature/
├── data/
│   ├── datasources/     # Fuentes de datos (API, local)
│   ├── models/          # Modelos de datos
│   └── repositories/    # Implementaciones de repositorios
├── domain/
│   ├── entities/        # Entidades de dominio
│   ├── repositories/    # Interfaces de repositorios
│   └── usecases/        # Casos de uso
└── presentation/
    ├── blocs/           # BLoCs para manejo de estado
    ├── pages/           # Páginas de la UI
    └── widgets/         # Widgets específicos de la feature
```

## 🚀 Despliegue

### Web
```bash
flutter build web
```

### Producción
```bash
flutter build web --release
```

## 📝 Convenciones de Código

### Nomenclatura
- **Archivos**: snake_case (ej: `custom_button.dart`)
- **Clases**: PascalCase (ej: `CustomButton`)
- **Variables**: camelCase (ej: `isLoading`)
- **Constantes**: SCREAMING_SNAKE_CASE (ej: `APP_NAME`)

### Estructura de Archivos
- Un archivo por clase
- Agrupación lógica en carpetas
- Separación clara de responsabilidades

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 🆘 Soporte

Para soporte y preguntas:
- Crear un issue en GitHub
- Contactar al desarrollador

---

Desarrollado con ❤️ usando Flutter
