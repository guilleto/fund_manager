import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../navigation/app_router.dart';
import '../../features/funds/domain/models/user.dart';
import '../../features/funds/domain/models/user_fund.dart';
import '../../features/funds/domain/models/transaction.dart';
import '../../features/funds/domain/services/user_funds_service.dart';
import '../../features/funds/domain/services/notification_service.dart';

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

class AppLoadUserData extends AppEvent {
  const AppLoadUserData();
}

class AppSubscribeToFund extends AppEvent {
  final dynamic fund;
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
  final dynamic preference;

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

class AppLoaded extends AppState {
  final AppRoute currentRoute;
  final bool canGoBack;
  final Map<String, dynamic>? arguments;
  final User? currentUser;
  final List<UserFund> userFunds;
  final List<Transaction> transactionHistory;
  final bool isLoading;
  final String? errorMessage;

  const AppLoaded({
    required this.currentRoute,
    required this.canGoBack,
    this.arguments,
    this.currentUser,
    this.userFunds = const [],
    this.transactionHistory = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        currentRoute,
        canGoBack,
        arguments,
        currentUser,
        userFunds,
        transactionHistory,
        isLoading,
        errorMessage
      ];

  AppLoaded copyWith({
    AppRoute? currentRoute,
    bool? canGoBack,
    Map<String, dynamic>? arguments,
    User? currentUser,
    List<UserFund>? userFunds,
    List<Transaction>? transactionHistory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppLoaded(
      currentRoute: currentRoute ?? this.currentRoute,
      canGoBack: canGoBack ?? this.canGoBack,
      arguments: arguments ?? this.arguments,
      currentUser: currentUser ?? this.currentUser,
      userFunds: userFunds ?? this.userFunds,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final UserFundsService _userFundsService;

  AppBloc()
      : _userFundsService = MockUserFundsService(MockNotificationService()),
        super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppNavigateTo>(_onNavigateTo);
    on<AppNavigateBack>(_onNavigateBack);
    on<AppLoadUserData>(_onLoadUserData);
    on<AppSubscribeToFund>(_onSubscribeToFund);
    on<AppCancelFund>(_onCancelFund);
    on<AppUpdateNotificationPreference>(_onUpdateNotificationPreference);
  }

  void _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(const AppLoaded(
      currentRoute: AppRoute.welcome,
      canGoBack: false,
      isLoading: true,
    ));

    // Cargar datos del usuario al iniciar la app
    try {
      final user = await _userFundsService.getCurrentUser();
      final userFunds = await _userFundsService.getUserFunds();
      final transactions = await _userFundsService.getTransactionHistory();

      emit(AppLoaded(
        currentRoute: AppRoute.welcome,
        canGoBack: false,
        currentUser: user,
        userFunds: userFunds,
        transactionHistory: transactions,
        isLoading: false,
      ));
    } catch (e) {
      emit(AppLoaded(
        currentRoute: AppRoute.welcome,
        canGoBack: false,
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onNavigateTo(AppNavigateTo event, Emitter<AppState> emit) {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      final canGoBack = event.route != AppRoute.welcome;
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
      if (currentState.canGoBack) {
        AppRoute previousRoute;
        switch (currentState.currentRoute) {
          case AppRoute.dashboard:
            previousRoute = AppRoute.welcome;
            break;
          case AppRoute.funds:
          case AppRoute.myFunds:
          case AppRoute.fundDetails:
            previousRoute = AppRoute.dashboard;
            break;
          default:
            previousRoute = AppRoute.welcome;
        }

        emit(currentState.copyWith(
          currentRoute: previousRoute,
          canGoBack: previousRoute != AppRoute.welcome,
          arguments: null,
        ));
      }
    }
  }

  void _onLoadUserData(AppLoadUserData event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final user = await _userFundsService.getCurrentUser();
        final userFunds = await _userFundsService.getUserFunds();
        final transactions = await _userFundsService.getTransactionHistory();

        emit(currentState.copyWith(
          currentUser: user,
          userFunds: userFunds,
          transactionHistory: transactions,
          isLoading: false,
          errorMessage: null,
        ));
      } catch (e) {
        print('Error al cargar datos del usuario: $e');
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: 'Error al cargar los datos. Por favor, intenta de nuevo.',
        ));
      }
    }
  }

  void _onSubscribeToFund(
      AppSubscribeToFund event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true, errorMessage: null));

      try {
        final success = await _userFundsService.subscribeToFund(
          fund: event.fund,
          amount: event.amount,
        );

        if (success) {
          // Recargar datos del usuario
          final user = await _userFundsService.getCurrentUser();
          final userFunds = await _userFundsService.getUserFunds();
          final transactions = await _userFundsService.getTransactionHistory();

          emit(currentState.copyWith(
            currentUser: user,
            userFunds: userFunds,
            transactionHistory: transactions,
            isLoading: false,
            errorMessage: null,
          ));
        } else {
          emit(currentState.copyWith(
            isLoading: false,
            errorMessage:
                'No se pudo completar la suscripción. Verifica tu saldo.',
          ));
        }
      } catch (e) {
        print('Error en suscripción a fondo: $e');
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
      emit(currentState.copyWith(isLoading: true, errorMessage: null));

      try {
        final success =
            await _userFundsService.cancelFund(userFund: event.userFund);

        if (success) {
          // Recargar datos del usuario
          final user = await _userFundsService.getCurrentUser();
          final userFunds = await _userFundsService.getUserFunds();
          final transactions = await _userFundsService.getTransactionHistory();

          emit(currentState.copyWith(
            currentUser: user,
            userFunds: userFunds,
            transactionHistory: transactions,
            isLoading: false,
            errorMessage: null,
          ));
        } else {
          emit(currentState.copyWith(
            isLoading: false,
            errorMessage: 'No se pudo completar la cancelación.',
          ));
        }
      } catch (e) {
        print('Error en cancelación de fondo: $e');
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _onUpdateNotificationPreference(
      AppUpdateNotificationPreference event, Emitter<AppState> emit) async {
    if (state is AppLoaded) {
      final currentState = state as AppLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final success = await _userFundsService.updateNotificationPreference(
          preference: event.preference,
        );

        if (success) {
          final user = await _userFundsService.getCurrentUser();
          emit(currentState.copyWith(
            currentUser: user,
            isLoading: false,
          ));
        } else {
          emit(currentState.copyWith(
            isLoading: false,
            errorMessage: 'No se pudo actualizar la preferencia de notificación.',
          ));
        }
      } catch (e) {
        print('Error al actualizar preferencia de notificación: $e');
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }
}
