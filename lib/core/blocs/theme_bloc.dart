import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fund_manager/core/services/theme_service.dart';

// Eventos
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeLoad extends ThemeEvent {
  const ThemeLoad();
}

class ThemeUpdate extends ThemeEvent {
  final bool isDarkMode;

  const ThemeUpdate(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

// Estados
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;

  const ThemeLoaded(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class ThemeError extends ThemeState {
  final String message;

  const ThemeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService _themeService;

  ThemeBloc(this._themeService) : super(const ThemeInitial()) {
    on<ThemeLoad>(_onLoad);
    on<ThemeUpdate>(_onUpdate);
  }

  void _onLoad(ThemeLoad event, Emitter<ThemeState> emit) async {
    emit(const ThemeLoading());
    
    try {
      final isDarkMode = await _themeService.isDarkMode();
      emit(ThemeLoaded(isDarkMode));
    } catch (e) {
      emit(ThemeError('Error al cargar tema: ${e.toString()}'));
    }
  }

  void _onUpdate(ThemeUpdate event, Emitter<ThemeState> emit) async {
    try {
      await _themeService.setDarkMode(event.isDarkMode);
      emit(ThemeLoaded(event.isDarkMode));
    } catch (e) {
      emit(ThemeError('Error al actualizar tema: ${e.toString()}'));
    }
  }
}
