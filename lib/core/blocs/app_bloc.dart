import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../navigation/app_router.dart';

// Eventos
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class AppNavigateTo extends AppEvent {
  final AppRoute route;

  const AppNavigateTo(this.route);

  @override
  List<Object?> get props => [route];
}

class AppNavigateBack extends AppEvent {
  const AppNavigateBack();
}

// Estados
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppLoaded extends AppState {
  final AppRoute currentRoute;
  final bool canGoBack;

  const AppLoaded({
    required this.currentRoute,
    this.canGoBack = false,
  });

  @override
  List<Object?> get props => [currentRoute, canGoBack];

  AppLoaded copyWith({
    AppRoute? currentRoute,
    bool? canGoBack,
  }) {
    return AppLoaded(
      currentRoute: currentRoute ?? this.currentRoute,
      canGoBack: canGoBack ?? this.canGoBack,
    );
  }
}

// BLoC
// Este BLoC maneja el estado de navegación global de la aplicación.
// El AppRouterDelegate escucha los cambios de estado y actualiza la UI automáticamente.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppNavigateTo>(_onNavigateTo);
    on<AppNavigateBack>(_onNavigateBack);
  }

  void _onAppStarted(AppStarted event, Emitter<AppState> emit) {
    if (state is! AppLoaded) {
      emit(const AppLoaded(currentRoute: AppRoute.welcome));
    }
  }

  void _onNavigateTo(AppNavigateTo event, Emitter<AppState> emit) {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      final canGoBack = event.route != AppRoute.welcome;

      emit(currentState.copyWith(
        currentRoute: event.route,
        canGoBack: canGoBack,
      ));

      // La navegación se maneja automáticamente por el AppRouterDelegate
      // que escucha los cambios de estado del AppBloc
    }
  }

  void _onNavigateBack(AppNavigateBack event, Emitter<AppState> emit) {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;

      // Determinar la ruta anterior
      AppRoute previousRoute;
      switch (currentState.currentRoute) {
        case AppRoute.dashboard:
          previousRoute = AppRoute.welcome;
          break;
        case AppRoute.funds:
        case AppRoute.myFunds:
          previousRoute = AppRoute.dashboard;
          break;
        case AppRoute.welcome:
          return; // No se puede ir más atrás
      }

      final canGoBack = previousRoute != AppRoute.welcome;

      emit(currentState.copyWith(
        currentRoute: previousRoute,
        canGoBack: canGoBack,
      ));
    }
  }
}
