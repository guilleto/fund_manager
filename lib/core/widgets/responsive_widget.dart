import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Usar MediaQuery para obtener el tamaño real de la pantalla
        final screenWidth = MediaQuery.of(context).size.width;
        
        if (screenWidth >= AppConstants.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (screenWidth >= AppConstants.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        
        final isMobile = screenWidth < AppConstants.tabletBreakpoint;
        final isTablet = screenWidth >= AppConstants.tabletBreakpoint && 
                        screenWidth < AppConstants.desktopBreakpoint;
        final isDesktop = screenWidth >= AppConstants.desktopBreakpoint;
        
        return builder(context, isMobile, isTablet, isDesktop);
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        EdgeInsets padding;
        
        if (isDesktop) {
          padding = desktopPadding ?? EdgeInsets.all(32.w);
        } else if (isTablet) {
          padding = tabletPadding ?? EdgeInsets.all(24.w);
        } else {
          padding = mobilePadding ?? EdgeInsets.all(16.w);
        }
        
        return Padding(padding: padding, child: child);
      },
    );
  }
}

class ResponsiveSpacing extends StatelessWidget {
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final bool isVertical;

  const ResponsiveSpacing({
    super.key,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        double spacing;
        
        if (isDesktop) {
          spacing = desktopSpacing ?? 32.h;
        } else if (isTablet) {
          spacing = tabletSpacing ?? 24.h;
        } else {
          spacing = mobileSpacing ?? 16.h;
        }
        
        return isVertical
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing);
      },
    );
  }
}
