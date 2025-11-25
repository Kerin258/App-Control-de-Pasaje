# 🚌 Control de Pasaje

**Aplicación móvil para el control y gestión de gastos de transporte**

---

## 👥 Desarrolladores

- **Kerin Del Jesus Gonzalez Maas**
- **Kevin Del Jesus Gonzalez Maas**

---

## 📱 Descripción del Proyecto

**Control de Pasaje** es una aplicación móvil desarrollada en Flutter que permite a los usuarios gestionar y controlar sus gastos de transporte público de manera eficiente. La aplicación está diseñada específicamente para estudiantes y usuarios frecuentes del transporte público en México, ayudándoles a mantener un presupuesto semanal y llevar un registro detallado de sus gastos.

### 🎯 Utilidad y Aplicación Local

Esta aplicación resuelve un problema real del entorno local:
- **Control de Gastos**: Muchos estudiantes y trabajadores pierden la noción de cuánto gastan en transporte diariamente
- **Presupuesto Limitado**: Ayuda a administrar un presupuesto semanal específico para transporte
- **Categorías Locales**: Incluye categorías específicas del transporte mexicano (Autobús, Metro, Colectivo, Taxi/Uber)
- **Tarifa Estudiantil**: Considera descuentos especiales para estudiantes

---

## ✨ Características Principales

### 🔐 Sistema de Autenticación
- Registro de usuario con datos personales
- Validación de contraseña segura
- Selección de edad personalizada
- Foto de perfil opcional
- Indicador de estado de estudiante

### 💰 Gestión de Presupuesto
- Configuración de presupuesto semanal
- Visualización del saldo restante
- Indicador visual de gasto (circular progress)
- Alertas cuando se aproxima al límite del presupuesto

### 📊 Control de Gastos
- Registro rápido de gastos con categorías predefinidas
- Atajos personalizables para gastos frecuentes
- Edición y eliminación de gastos
- Historial completo con filtros por período
- Estadísticas visuales de gastos

### 🎨 Interfaz Moderna
- Diseño Material Design 3
- Modo claro y modo oscuro
- Animaciones fluidas
- Navegación intuitiva
- Interfaz completamente en español

### 💾 Persistencia de Datos
- Base de datos local (SQLite)
- Almacenamiento seguro de datos de usuario
- Sincronización automática
- Los datos persisten al cerrar la app

---

## 📲 Pantallas de la Aplicación

La aplicación cuenta con **7 pantallas principales**, cumpliendo ampliamente con el requisito de mínimo 3 pantallas:

### 1️⃣ **Login Screen** (Pantalla de Inicio de Sesión)
- Registro e inicio de sesión
- Validación de contraseña
- Selección de foto de perfil
- Animación de partículas de fondo

### 2️⃣ **Onboarding Screen** (Configuración Inicial)
- Configuración de presupuesto semanal
- Selección de estado de estudiante
- Primer contacto con la aplicación

### 3️⃣ **Home Screen** (Pantalla Principal)
- Dashboard con resumen financiero
- Visualización de presupuesto y gastos
- Atajos rápidos personalizables
- Últimos movimientos registrados

### 4️⃣ **Add Expense Screen** (Agregar Gasto)
- Formulario para registrar nuevos gastos
- Selector de categoría de transporte
- Validación de montos
- Sugerencia de precios por categoría

### 5️⃣ **History Screen** (Historial)
- Lista completa de gastos registrados
- Filtros por período (semana, mes, todo)
- Edición y eliminación de gastos
- Total gastado por período

### 6️⃣ **Stats Screen** (Estadísticas)
- Gráficas de gastos por categoría
- Distribución porcentual
- Insights sobre hábitos de gasto
- Resumen mensual

### 7️⃣ **Profile Screen** (Perfil)
- Información del usuario
- Edición de datos personales
- Cambio de presupuesto
- Configuración de temas

### 🔄 Navegación
La aplicación implementa un sistema de navegación completo:
- **NavigationBar** con 4 tabs principales (Inicio, Historial, Estadísticas, Perfil)
- **Navigator.push** para pantallas modales (Login, Onboarding, Agregar Gasto)
- **FloatingActionButton** para acceso rápido a funciones principales
- **Diálogos modales** para edición y confirmaciones

---

## 🛠️ Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter** 3.x
- **Dart** 3.x

### Arquitectura
- **Patrón MVVM** (Model-View-ViewModel)
- **Provider** para gestión de estado
- Separación clara de responsabilidades

### Persistencia de Datos
- **SQLite** (sqflite) - Base de datos local
- **SharedPreferences** - Preferencias del usuario

### UI/UX
- **Material Design 3**
- **Font Awesome Icons**
- **Internacionalización** (español mexicano)
- **Animate** - Animaciones fluidas

### Utilidades
- **image_picker** - Selección de fotos
- **intl** - Formateo de fechas y moneda

---

## 📋 Requisitos del Proyecto

✅ **Cumplimiento de requisitos de la tarea:**

| Requisito | Cumplimiento |
|-----------|--------------|
| Mínimo 3 pantallas diferentes | ✅ **7 pantallas** |
| Navegación entre pantallas | ✅ **NavigationBar + Navigator** |
| Aplicación útil | ✅ **Control de gastos de transporte** |
| Aplicable al entorno local | ✅ **Transporte público mexicano** |
| Desarrollo en pareja | ✅ **Kerin y Kevin** |
| Ejecución en dispositivo móvil | ✅ **Android APK generado** |

---

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Flutter SDK 3.0 o superior
- Android Studio o VS Code
- Dispositivo Android o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <url-del-repositorio>
cd flutter_controldepasaje_1
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Verificar dispositivos conectados**
```bash
flutter devices
```

4. **Ejecutar la aplicación**
```bash
flutter run
```

### Generar APK para Android
```bash
# APK de debug
flutter build apk --debug

# APK de release
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/`

---

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/                      # Modelos de datos
│   ├── expense_model.dart       # Modelo de gasto
│   └── shortcut_model.dart      # Modelo de atajo rápido
├── providers/                   # Gestión de estado (ViewModel)
│   ├── expense_provider.dart    # Provider principal
│   └── theme_provider.dart      # Provider de temas
├── screens/                     # Pantallas de la aplicación (Views)
│   ├── login_screen.dart        # Pantalla de login
│   ├── onboarding_screen.dart   # Configuración inicial
│   ├── home_screen.dart         # Dashboard principal
│   ├── add_expense_screen.dart  # Agregar gastos
│   ├── history_screen.dart      # Historial
│   ├── stats_screen.dart        # Estadísticas
│   └── profile_screen.dart      # Perfil
└── utils/                       # Utilidades y servicios
    ├── database_helper.dart     # Helper de SQLite
    ├── preferences_service.dart # Servicio de preferencias
    └── colors.dart              # Paleta de colores
```

---

## 🎨 Capturas de Pantalla

### Flujo de Registro
1. **Login** → Registro con validación de contraseña
2. **Onboarding** → Configuración de presupuesto semanal
3. **Dashboard** → Vista principal con resumen

### Funcionalidades Principales
- **Atajos Rápidos** → Registro de gastos con un toque
- **Historial** → Todos los gastos con filtros
- **Estadísticas** → Visualización de patrones de gasto
- **Perfil** → Gestión de cuenta de usuario

