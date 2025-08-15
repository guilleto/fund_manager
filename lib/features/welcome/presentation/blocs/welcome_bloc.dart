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
  const WelcomeLoaded();
}

class WelcomeError extends WelcomeState {
  final String message;

  const WelcomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class WelcomeCompleted extends WelcomeState {
  const WelcomeCompleted();
}

class WelcomeFinished extends WelcomeEvent {
  const WelcomeFinished();
}

// BLoC
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(const WelcomeInitial()) {
    on<WelcomeStarted>(_onWelcomeStarted);
    on<WelcomeFinished>(_onWelcomeFinished);
  }

  void _onWelcomeStarted(
      WelcomeStarted event, Emitter<WelcomeState> emit) async {
    emit(const WelcomeLoading());
    // Simular carga inicial
    await Future.delayed(const Duration(milliseconds: 250));
    if (!emit.isDone) {
      emit(const WelcomeLoaded());
    }
  }

  void _onWelcomeFinished(WelcomeFinished event, Emitter<WelcomeState> emit) {
    emit(const WelcomeCompleted());
  }
}
