import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/services/user_service.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';

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
  final Map<String, dynamic>? arguments;

  const AppNavigateTo(this.route, {this.arguments});

  @override
  List<Object?> get props => [route, arguments];
}

class AppNavigateBack extends AppEvent {
  const AppNavigateBack();
}

class AppRefreshData extends AppEvent {
  const AppRefreshData();
}

class AppSubscribeToFund extends AppEvent {
  final Fund fund;
  final double amount;

  const AppSubscribeToFund({
    required this.fund,
    required this.amount,
  });

  @override
  List<Object?> get props => [fund, amount];
}

class AppCancelFund extends AppEvent {
  final UserFund userFund;

  const AppCancelFund(this.userFund);

  @override
  List<Object?> get props => [userFund];
}

class AppUpdateNotificationPreference extends AppEvent {
  final NotificationPreference preference;

  const AppUpdateNotificationPreference(this.preference);

  @override
  List<Object?> get props => [preference];
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

class AppLoading extends AppState {
  const AppLoading();
}

class AppLoaded extends AppState {
  final AppRoute currentRoute;
  final bool canGoBack;
  final Map<String, dynamic>? arguments;
  final User? currentUser;
  final List<UserFund> userFunds;
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;

  const AppLoaded({
    required this.currentRoute,
    required this.canGoBack,
    this.arguments,
    this.currentUser,
    this.userFunds = const [],
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AppLoaded copyWith({
    AppRoute? currentRoute,
    bool? canGoBack,
    Map<String, dynamic>? arguments,
    User? currentUser,
    List<UserFund>? userFunds,
    List<Transaction>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppLoaded(
      currentRoute: currentRoute ?? this.currentRoute,
      canGoBack: canGoBack ?? this.canGoBack,
      arguments: arguments ?? this.arguments,
      currentUser: currentUser ?? this.currentUser,
      userFunds: userFunds ?? this.userFunds,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentRoute,
        canGoBack,
        arguments,
        currentUser,
        userFunds,
        transactions,
        isLoading,
        errorMessage,
      ];
}

class AppError extends AppState {
  final String message;

  const AppError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final UserService _userService;
  Timer? _userFundsUpdateTimer;

  AppBloc(this._userService) : super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppNavigateTo>(_onNavigateTo);
    on<AppNavigateBack>(_onNavigateBack);
    on<AppRefreshData>(_onRefreshData);
    on<AppSubscribeToFund>(_onSubscribeToFund);
    on<AppCancelFund>(_onCancelFund);
    on<AppUpdateNotificationPreference>(_onUpdateNotificationPreference);
  }

  @override
  Future<void> close() {
    _userFundsUpdateTimer?.cancel();
    return super.close();
  }

  void _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(const AppLoading());
    
    try {
      final user = await _userService.getCurrentUser();
      final userFunds = await _userService.getUserFunds();
      final transactions = await _userService.getTransactionHistory();
      
      emit(AppLoaded(
        currentRoute: AppRoute.welcome,
        canGoBack: false,
        currentUser: user,
        userFunds: userFunds,
        transactions: transactions,
      ));
    } catch (e) {
      emit(AppError(message: e.toString()));
    }
  }

  void _onNavigateTo(AppNavigateTo event, Emitter<AppState> emit) {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      final canGoBack = event.route != AppRoute.welcome;
      
      // Activar/desactivar timer según la página
      _manageUserFundsTimer(event.route);
      
      emit(currentState.copyWith(
        currentRoute: event.route,
        canGoBack: canGoBack,
        arguments: event.arguments,
      ));
    }
  }

  void _onNavigateBack(AppNavigateBack event, Emitter<AppState> emit) {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      // Lógica de navegación hacia atrás
      emit(currentState.copyWith(
        currentRoute: AppRoute.welcome, // Simplificado
        canGoBack: false,
      ));
    }
  }

  void _onRefreshData(AppRefreshData event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true));
      
      try {
        final user = await _userService.getCurrentUser();
        final userFunds = await _userService.getUserFunds();
        final transactions = await _userService.getTransactionHistory();
        
        emit(currentState.copyWith(
          currentUser: user,
          userFunds: userFunds,
          transactions: transactions,
          isLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _onSubscribeToFund(AppSubscribeToFund event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true));
      
      try {
        final success = await _userService.subscribeToFund(
          fund: event.fund,
          amount: event.amount,
        );
        
        if (success) {
          // Recargar datos actualizados
          final user = await _userService.getCurrentUser();
          final userFunds = await _userService.getUserFunds();
          final transactions = await _userService.getTransactionHistory();
          
          emit(currentState.copyWith(
            currentUser: user,
            userFunds: userFunds,
            transactions: transactions,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _onCancelFund(AppCancelFund event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true));
      
      try {
        final success = await _userService.cancelFund(userFund: event.userFund);
        
        if (success) {
          // Recargar datos actualizados
          final user = await _userService.getCurrentUser();
          final userFunds = await _userService.getUserFunds();
          final transactions = await _userService.getTransactionHistory();
          
          emit(currentState.copyWith(
            currentUser: user,
            userFunds: userFunds,
            transactions: transactions,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _onUpdateNotificationPreference(AppUpdateNotificationPreference event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true));
      
      try {
        final success = await _userService.updateNotificationPreference(
          preference: event.preference,
        );
        
        if (success) {
          final user = await _userService.getCurrentUser();
          emit(currentState.copyWith(
            currentUser: user,
            isLoading: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Gestiona el timer para actualizar los fondos del usuario
  void _manageUserFundsTimer(AppRoute route) {
    // Cancelar timer existente
    _userFundsUpdateTimer?.cancel();
    
    print('DEBUG: AppBloc - Navegando a: $route');
    
    // Solo activar timer en páginas relacionadas con fondos
    if (route == AppRoute.funds || route == AppRoute.myFunds || route == AppRoute.fundDetails) {
      print('DEBUG: AppBloc - Activando timer para actualizar fondos del usuario');
      _startUserFundsUpdateTimer();
    } else {
      print('DEBUG: AppBloc - Desactivando timer (no es página de fondos)');
    }
  }

  /// Inicia el timer para actualizar los fondos del usuario cada minuto
  void _startUserFundsUpdateTimer() {
    _userFundsUpdateTimer?.cancel();
    _userFundsUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (state is AppLoaded) {
        _updateUserFunds();
      }
    });
  }

  /// Actualiza los fondos del usuario
  void _updateUserFunds() async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      
      try {
        print('DEBUG: AppBloc - Actualizando fondos del usuario...');
        final userFunds = await _userService.getUserFunds();
        
        // Solo emitir si hay cambios
        if (userFunds.length != currentState.userFunds.length ||
            _hasUserFundsChanged(currentState.userFunds, userFunds)) {
          print('DEBUG: AppBloc - Fondos del usuario actualizados, emitiendo nuevo estado');
          emit(currentState.copyWith(userFunds: userFunds));
        } else {
          print('DEBUG: AppBloc - No hay cambios en los fondos del usuario');
        }
      } catch (e) {
        print('Error actualizando fondos del usuario: $e');
      }
    }
  }

  /// Verifica si los fondos del usuario han cambiado
  bool _hasUserFundsChanged(List<UserFund> oldFunds, List<UserFund> newFunds) {
    if (oldFunds.length != newFunds.length) return true;
    
    for (int i = 0; i < oldFunds.length; i++) {
      if (oldFunds[i].currentValue != newFunds[i].currentValue ||
          oldFunds[i].isActive != newFunds[i].isActive) {
        return true;
      }
    }
    
    return false;
  }
}
