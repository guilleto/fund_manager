import 'package:flutter/material.dart';

class ResponsiveService {
  static ResponsiveService? _instance;
  static ResponsiveService get instance => _instance ??= ResponsiveService._();

  ResponsiveService._();

  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Tamaños de fuente base
  static const double baseFontSize = 16.0;
  static const double smallFontSize = 14.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 24.0;
  static const double titleFontSize = 32.0;

  // Obtener el tipo de dispositivo basado en el ancho de pantalla
  DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  // Verificar si es móvil
  bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  // Verificar si es tablet
  bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  // Verificar si es desktop
  bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  // Obtener tamaño de fuente responsive
  double getFontSize(BuildContext context, FontSizeType type) {
    final deviceType = getDeviceType(context);
    
    switch (type) {
      case FontSizeType.small:
        return _getResponsiveFontSize(smallFontSize, deviceType);
      case FontSizeType.base:
        return _getResponsiveFontSize(baseFontSize, deviceType);
      case FontSizeType.large:
        return _getResponsiveFontSize(largeFontSize, deviceType);
      case FontSizeType.extraLarge:
        return _getResponsiveFontSize(extraLargeFontSize, deviceType);
      case FontSizeType.title:
        return _getResponsiveFontSize(titleFontSize, deviceType);
    }
  }

  // Calcular tamaño de fuente responsive
  double _getResponsiveFontSize(double baseSize, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSize * 0.9; // Ligeramente más pequeño en móvil
      case DeviceType.tablet:
        return baseSize * 1.0; // Tamaño base en tablet
      case DeviceType.desktop:
        return baseSize * 1.1; // Ligeramente más grande en desktop
    }
  }

  // Obtener padding responsive
  EdgeInsets getPadding(BuildContext context, PaddingType type) {
    final deviceType = getDeviceType(context);
    
    switch (type) {
      case PaddingType.small:
        return _getResponsivePadding(8.0, deviceType);
      case PaddingType.medium:
        return _getResponsivePadding(16.0, deviceType);
      case PaddingType.large:
        return _getResponsivePadding(24.0, deviceType);
      case PaddingType.extraLarge:
        return _getResponsivePadding(32.0, deviceType);
    }
  }

  // Calcular padding responsive
  EdgeInsets _getResponsivePadding(double basePadding, DeviceType deviceType) {
    double padding;
    
    switch (deviceType) {
      case DeviceType.mobile:
        padding = basePadding * 0.8;
        break;
      case DeviceType.tablet:
        padding = basePadding * 1.0;
        break;
      case DeviceType.desktop:
        padding = basePadding * 1.2;
        break;
    }
    
    return EdgeInsets.all(padding);
  }

  // Obtener spacing vertical responsive
  double getVerticalSpacing(BuildContext context, SpacingType type) {
    final deviceType = getDeviceType(context);
    
    switch (type) {
      case SpacingType.small:
        return _getResponsiveSpacing(8.0, deviceType);
      case SpacingType.medium:
        return _getResponsiveSpacing(16.0, deviceType);
      case SpacingType.large:
        return _getResponsiveSpacing(24.0, deviceType);
      case SpacingType.extraLarge:
        return _getResponsiveSpacing(32.0, deviceType);
    }
  }

  // Calcular spacing responsive
  double _getResponsiveSpacing(double baseSpacing, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSpacing * 0.8;
      case DeviceType.tablet:
        return baseSpacing * 1.0;
      case DeviceType.desktop:
        return baseSpacing * 1.2;
    }
  }

  // Obtener ancho de pantalla
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Obtener alto de pantalla
  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Obtener densidad de píxeles
  double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Verificar orientación
  bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}

// Enums para tipos
enum DeviceType { mobile, tablet, desktop }

enum FontSizeType { small, base, large, extraLarge, title }

enum PaddingType { small, medium, large, extraLarge }

enum SpacingType { small, medium, large, extraLarge }
