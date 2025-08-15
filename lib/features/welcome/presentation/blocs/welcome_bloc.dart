import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Eventos
abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object?> get props => [];
}

class WelcomeStarted extends WelcomeEvent {
  const WelcomeStarted();
}

class WelcomeAnimationCompleted extends WelcomeEvent {
  const WelcomeAnimationCompleted();
}

class WelcomeNavigateToDashboard extends WelcomeEvent {
  const WelcomeNavigateToDashboard();
}

// Estados
abstract class WelcomeState extends Equatable {
  const WelcomeState();

  @override
  List<Object?> get props => [];
}

class WelcomeInitial extends WelcomeState {
  const WelcomeInitial();
}

class WelcomeLoading extends WelcomeState {
  const WelcomeLoading();
}

class WelcomeLoaded extends WelcomeState {
  final bool isAnimationComplete;
  final bool isNavigating;

  const WelcomeLoaded({
    this.isAnimationComplete = false,
    this.isNavigating = false,
  });

  @override
  List<Object?> get props => [isAnimationComplete, isNavigating];

  WelcomeLoaded copyWith({
    bool? isAnimationComplete,
    bool? isNavigating,
  }) {
    return WelcomeLoaded(
      isAnimationComplete: isAnimationComplete ?? this.isAnimationComplete,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}

class WelcomeError extends WelcomeState {
  final String message;

  const WelcomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(const WelcomeInitial()) {
    on<WelcomeStarted>(_onWelcomeStarted);
    on<WelcomeAnimationCompleted>(_onAnimationCompleted);
    on<WelcomeNavigateToDashboard>(_onNavigateToDashboard);
  }

  void _onWelcomeStarted(WelcomeStarted event, Emitter<WelcomeState> emit) {
    emit(const WelcomeLoading());
    // Simular carga inicial
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(const WelcomeLoaded());
    });
  }

  void _onAnimationCompleted(WelcomeAnimationCompleted event, Emitter<WelcomeState> emit) {
    if (state is WelcomeLoaded) {
      final currentState = state as WelcomeLoaded;
      emit(currentState.copyWith(isAnimationComplete: true));
    }
  }

  void _onNavigateToDashboard(WelcomeNavigateToDashboard event, Emitter<WelcomeState> emit) {
    if (state is WelcomeLoaded) {
      final currentState = state as WelcomeLoaded;
      emit(currentState.copyWith(isNavigating: true));
    }
  }
}
