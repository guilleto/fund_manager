import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_widget.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/di/injection.dart';
import '../blocs/welcome_bloc.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador para animación de fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador para animación de slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Controlador para animación de scale
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Configurar animaciones
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animaciones secuencialmente
    _startAnimations();
  }

  void _startAnimations() async {
    // Iniciar fade
    _fadeController.forward();
    
    // Esperar un poco y iniciar slide
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    
    // Esperar un poco y iniciar scale
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  void _navigateToDashboard() async {
    // Animación de salida hacia arriba con fade
    await _fadeController.reverse();
    await _slideController.animateTo(0.0, curve: Curves.easeIn);
    
    // Notificar al BLoC para que maneje la navegación
    if (mounted) {
      context.read<WelcomeBloc>().add(const WelcomeNavigateToDashboard());
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WelcomeBloc>()..add(const WelcomeStarted()),
      child: BlocListener<WelcomeBloc, WelcomeState>(
        listener: (context, state) {
          if (state is WelcomeLoaded && state.isNavigating) {
            // Navegar al dashboard cuando el estado indique que debe navegar
            AppRouter.goToDashboard();
          }
        },
        child: Scaffold(
          body: ResponsiveWidget(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoSection(),
              SizedBox(height: 40.h),
              _buildWelcomeText(),
              SizedBox(height: 32.h),
              _buildDescriptionText(),
              SizedBox(height: 48.h),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(48.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoSection(),
              SizedBox(height: 60.h),
              _buildWelcomeText(),
              SizedBox(height: 40.h),
              _buildDescriptionText(),
              SizedBox(height: 60.h),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.9),
            Theme.of(context).primaryColor.withOpacity(0.7),
            Theme.of(context).primaryColor.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(64.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoSection(),
              SizedBox(height: 80.h),
              _buildWelcomeText(),
              SizedBox(height: 48.h),
              _buildDescriptionText(),
              SizedBox(height: 80.h),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.account_balance,
            size: 80.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Fund Manager',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Tu plataforma profesional para la gestión inteligente de fondos de inversión. Descubre herramientas avanzadas y análisis detallado para maximizar tus retornos.',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomButton(
          text: 'Comenzar Experiencia',
          onPressed: _navigateToDashboard,
          type: ButtonType.primary,
          isFullWidth: true,
          height: 56.h,
          icon: Icons.arrow_forward,
        ),
      ),
    );
  }
}
