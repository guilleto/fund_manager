import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fund_manager/core/services/user_service.dart';
import 'package:fund_manager/core/services/theme_service.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';

// Eventos
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadUser extends SettingsEvent {
  const SettingsLoadUser();
}

class SettingsUpdateUser extends SettingsEvent {
  final String name;
  final String email;
  final String? phone;
  final bool isDarkMode;

  const SettingsUpdateUser({
    required this.name,
    required this.email,
    this.phone,
    required this.isDarkMode,
  });

  @override
  List<Object?> get props => [name, email, phone, isDarkMode];
}

class SettingsToggleTheme extends SettingsEvent {
  const SettingsToggleTheme();
}

class SettingsResetForm extends SettingsEvent {
  const SettingsResetForm();
}

class SettingsFieldChanged extends SettingsEvent {
  const SettingsFieldChanged();
}

class SettingsResetToOriginal extends SettingsEvent {
  const SettingsResetToOriginal();
}

// Estados
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final User user;
  final bool isDarkMode;
  final bool hasChanges;
  final Map<String, String?> validationErrors;

  const SettingsLoaded({
    required this.user,
    required this.isDarkMode,
    this.hasChanges = false,
    this.validationErrors = const {},
  });

  SettingsLoaded copyWith({
    User? user,
    bool? isDarkMode,
    bool? hasChanges,
    Map<String, String?>? validationErrors,
  }) {
    return SettingsLoaded(
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      hasChanges: hasChanges ?? this.hasChanges,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  List<Object?> get props => [user, isDarkMode, hasChanges, validationErrors];
}

class SettingsSaving extends SettingsState {
  const SettingsSaving();
}

class SettingsSaved extends SettingsState {
  final User user;
  final bool isDarkMode;
  final bool shouldUpdateTheme;

  const SettingsSaved({
    required this.user,
    required this.isDarkMode,
    this.shouldUpdateTheme = true,
  });

  @override
  List<Object?> get props => [user, isDarkMode, shouldUpdateTheme];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserService _userService;
  final ThemeService _themeService;

  SettingsBloc(this._userService, this._themeService) : super(const SettingsInitial()) {
    on<SettingsLoadUser>(_onLoadUser);
    on<SettingsUpdateUser>(_onUpdateUser);
    on<SettingsToggleTheme>(_onToggleTheme);
    on<SettingsResetForm>(_onResetForm);
    on<SettingsFieldChanged>(_onFieldChanged);
    on<SettingsResetToOriginal>(_onResetToOriginal);
  }

  void _onLoadUser(SettingsLoadUser event, Emitter<SettingsState> emit) async {
    emit(const SettingsLoading());
    
    try {
      final user = await _userService.getCurrentUser();
      final isDarkMode = await _themeService.isDarkMode();
      
      emit(SettingsLoaded(
        user: user,
        isDarkMode: isDarkMode,
      ));
    } catch (e) {
      emit(SettingsError(message: 'Error al cargar datos del usuario: ${e.toString()}'));
    }
  }

  void _onUpdateUser(SettingsUpdateUser event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      // Validar campos
      final validationErrors = _validateFields(
        name: event.name,
        email: event.email,
        phone: event.phone,
      );

      if (validationErrors.isNotEmpty) {
        emit(currentState.copyWith(validationErrors: validationErrors));
        return;
      }

      emit(const SettingsSaving());
      
      try {
        // Crear usuario actualizado
        final updatedUser = currentState.user.copyWith(
          name: event.name,
          email: event.email,
          phone: event.phone,
        );

        // Actualizar usuario en el servicio
        await _userService.updateUser(updatedUser);
        
        emit(SettingsSaved(
          user: updatedUser,
          isDarkMode: event.isDarkMode,
        ));
      } catch (e) {
        emit(SettingsError(message: 'Error al guardar cambios: ${e.toString()}'));
      }
    }
  }

  void _onToggleTheme(SettingsToggleTheme event, Emitter<SettingsState> emit) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        isDarkMode: !currentState.isDarkMode,
        hasChanges: true,
      ));
    }
  }

  void _onResetForm(SettingsResetForm event, Emitter<SettingsState> emit) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        hasChanges: false,
        validationErrors: {},
      ));
    }
  }

  void _onFieldChanged(SettingsFieldChanged event, Emitter<SettingsState> emit) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        hasChanges: true,
        validationErrors: {},
      ));
    }
  }

  void _onResetToOriginal(SettingsResetToOriginal event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      try {
        final user = await _userService.getCurrentUser();
        final isDarkMode = await _themeService.isDarkMode();
        
        emit(SettingsLoaded(
          user: user,
          isDarkMode: isDarkMode,
          hasChanges: false,
          validationErrors: {},
        ));
      } catch (e) {
        emit(SettingsError(message: 'Error al resetear configuración: ${e.toString()}'));
      }
    }
  }

  Map<String, String?> _validateFields({
    required String name,
    required String email,
    String? phone,
  }) {
    final errors = <String, String?>{};

    // Validar nombre
    if (name.trim().isEmpty) {
      errors['name'] = 'El nombre es requerido';
    } else if (name.trim().length < 2) {
      errors['name'] = 'El nombre debe tener al menos 2 caracteres';
    }

    // Validar email
    if (email.trim().isEmpty) {
      errors['email'] = 'El email es requerido';
    } else if (!_isValidEmail(email)) {
      errors['email'] = 'Ingrese un email válido';
    }

    // Validar teléfono (opcional)
    if (phone != null && phone.trim().isNotEmpty && !_isValidPhone(phone)) {
      errors['phone'] = 'Ingrese un número de teléfono válido';
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    return phoneRegex.hasMatch(phone);
  }
}
