import 'package:flutter/material.dart';
import '../services/responsive_service.dart';

/// Widget que se adapta según el tipo de dispositivo
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
    final responsiveService = ResponsiveService.instance;
    
    if (responsiveService.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (responsiveService.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Builder pattern para lógica responsive
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    final deviceType = responsiveService.getDeviceType(context);
    
    return builder(context, deviceType);
  }
}

/// Padding responsive
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final PaddingType paddingType;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.paddingType = PaddingType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    final padding = responsiveService.getPadding(context, paddingType);
    
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Spacing vertical responsive
class ResponsiveSpacing extends StatelessWidget {
  final SpacingType spacingType;

  const ResponsiveSpacing({
    super.key,
    this.spacingType = SpacingType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    final spacing = responsiveService.getVerticalSpacing(context, spacingType);
    
    return SizedBox(height: spacing);
  }
}

/// Texto con tamaño responsive
class ResponsiveText extends StatelessWidget {
  final String text;
  final FontSizeType fontSizeType;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.fontSizeType = FontSizeType.base,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    final fontSize = responsiveService.getFontSize(context, fontSizeType);
    
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Container con ancho responsive
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    final screenWidth = responsiveService.getScreenWidth(context);
    
    // Calcular ancho responsive si se proporciona
    double? responsiveWidth;
    if (width != null) {
      if (responsiveService.isMobile(context)) {
        responsiveWidth = screenWidth * 0.95; // 95% del ancho en móvil
      } else if (responsiveService.isTablet(context)) {
        responsiveWidth = width! * 0.8; // 80% del ancho especificado en tablet
      } else {
        responsiveWidth = width!; // Ancho completo en desktop
      }
    }
    
    return Container(
      width: responsiveWidth,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// Grid con columnas responsive
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    
    int crossAxisCount;
    if (responsiveService.isMobile(context)) {
      crossAxisCount = 1;
    } else if (responsiveService.isTablet(context)) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Lista con elementos responsive
class ResponsiveList extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const ResponsiveList({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveService = ResponsiveService.instance;
    final responsiveSpacing = responsiveService.getVerticalSpacing(
      context, 
      SpacingType.medium
    );
    
    return ListView.separated(
      padding: padding,
      physics: physics,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: responsiveSpacing),
      itemBuilder: (context, index) => children[index],
    );
  }
}
