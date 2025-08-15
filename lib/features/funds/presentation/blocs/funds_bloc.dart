import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import 'package:fund_manager/features/funds/domain/services/user_funds_service.dart';

// Eventos
abstract class FundsEvent extends Equatable {
  const FundsEvent();

  @override
  List<Object?> get props => [];
}

class FundsStarted extends FundsEvent {
  const FundsStarted();
}

class FundsRefresh extends FundsEvent {
  const FundsRefresh();
}

class FundsFilterByCategory extends FundsEvent {
  final String? category;

  const FundsFilterByCategory({this.category});

  @override
  List<Object?> get props => [category];
}

class FundsFilterByRisk extends FundsEvent {
  final String? risk;

  const FundsFilterByRisk({this.risk});

  @override
  List<Object?> get props => [risk];
}

class FundsFilterByMinAmount extends FundsEvent {
  final int? minAmount;

  const FundsFilterByMinAmount({this.minAmount});

  @override
  List<Object?> get props => [minAmount];
}

class FundsClearFilters extends FundsEvent {
  const FundsClearFilters();
}

class FundsSortBy extends FundsEvent {
  final String sortBy;
  final bool ascending;

  const FundsSortBy({
    required this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}

class FundsSubscribeToFund extends FundsEvent {
  final Fund fund;
  final double amount;

  const FundsSubscribeToFund({
    required this.fund,
    required this.amount,
  });

  @override
  List<Object?> get props => [fund, amount];
}

class FundsCancelFund extends FundsEvent {
  final UserFund userFund;

  const FundsCancelFund(this.userFund);

  @override
  List<Object?> get props => [userFund];
}

class FundsLoadUserData extends FundsEvent {
  const FundsLoadUserData();
}

class FundsLoadUserFunds extends FundsEvent {
  const FundsLoadUserFunds();
}

class FundsLoadTransactionHistory extends FundsEvent {
  const FundsLoadTransactionHistory();
}

class FundsUpdateNotificationPreference extends FundsEvent {
  final NotificationPreference preference;

  const FundsUpdateNotificationPreference(this.preference);

  @override
  List<Object?> get props => [preference];
}

// Estados
abstract class FundsState extends Equatable {
  const FundsState();

  @override
  List<Object?> get props => [];
}

class FundsInitial extends FundsState {
  const FundsInitial();
}

class FundsLoading extends FundsState {
  const FundsLoading();
}

class FundsLoaded extends FundsState {
  final List<Fund> allFunds;
  final List<Fund> filteredFunds;
  final FundsSummary summary;
  final FundsFilters filters;
  final String sortBy;
  final bool sortAscending;
  final User? currentUser;
  final List<UserFund> userFunds;
  final List<Transaction> transactionHistory;
  final bool isLoading;
  final String? errorMessage;

  const FundsLoaded({
    required this.allFunds,
    required this.filteredFunds,
    required this.summary,
    required this.filters,
    this.sortBy = 'name',
    this.sortAscending = true,
    this.currentUser,
    this.userFunds = const [],
    this.transactionHistory = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        allFunds,
        filteredFunds,
        summary,
        filters,
        sortBy,
        sortAscending,
        currentUser,
        userFunds,
        transactionHistory,
        isLoading,
        errorMessage,
      ];

  FundsLoaded copyWith({
    List<Fund>? allFunds,
    List<Fund>? filteredFunds,
    FundsSummary? summary,
    FundsFilters? filters,
    String? sortBy,
    bool? sortAscending,
    User? currentUser,
    List<UserFund>? userFunds,
    List<Transaction>? transactionHistory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FundsLoaded(
      allFunds: allFunds ?? this.allFunds,
      filteredFunds: filteredFunds ?? this.filteredFunds,
      summary: summary ?? this.summary,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      currentUser: currentUser ?? this.currentUser,
      userFunds: userFunds ?? this.userFunds,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FundsError extends FundsState {
  final String message;

  const FundsError(this.message);

  @override
  List<Object?> get props => [message];
}

class FundsSummary extends Equatable {
  final int totalFunds;
  final int uniqueCategories;
  final int fpvCount;
  final int ficCount;
  final int averageMinAmount;

  const FundsSummary({
    required this.totalFunds,
    required this.uniqueCategories,
    required this.fpvCount,
    required this.ficCount,
    required this.averageMinAmount,
  });

  @override
  List<Object?> get props => [
        totalFunds,
        uniqueCategories,
        fpvCount,
        ficCount,
        averageMinAmount,
      ];
}

class FundsFilters extends Equatable {
  final String? category;
  final String? risk;
  final int? minAmount;

  const FundsFilters({
    this.category,
    this.risk,
    this.minAmount,
  });

  @override
  List<Object?> get props => [category, risk, minAmount];

  FundsFilters copyWith({
    String? category,
    String? risk,
    int? minAmount,
  }) {
    return FundsFilters(
      category: category ?? this.category,
      risk: risk ?? this.risk,
      minAmount: minAmount ?? this.minAmount,
    );
  }

  bool get hasFilters => category != null || risk != null || minAmount != null;
}

// BLoC
class FundsBloc extends Bloc<FundsEvent, FundsState> {
  final UserFundsService _userFundsService;

  FundsBloc(this._userFundsService) : super(const FundsInitial()) {
    on<FundsStarted>(_onFundsStarted);
    on<FundsRefresh>(_onFundsRefresh);
    on<FundsFilterByCategory>(_onFilterByCategory);
    on<FundsFilterByRisk>(_onFilterByRisk);
    on<FundsFilterByMinAmount>(_onFilterByMinAmount);
    on<FundsClearFilters>(_onClearFilters);
    on<FundsSortBy>(_onSortBy);
    on<FundsSubscribeToFund>(_onSubscribeToFund);
    on<FundsCancelFund>(_onCancelFund);
    on<FundsLoadUserData>(_onLoadUserData);
    on<FundsLoadUserFunds>(_onLoadUserFunds);
    on<FundsLoadTransactionHistory>(_onLoadTransactionHistory);
    on<FundsUpdateNotificationPreference>(_onUpdateNotificationPreference);
  }

  void _onFundsStarted(FundsStarted event, Emitter<FundsState> emit) {
    emit(const FundsLoading());
    _loadFundsData(emit);
  }

  void _onFundsRefresh(FundsRefresh event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));
    }
    _loadFundsData(emit);
  }

  void _onFilterByCategory(
      FundsFilterByCategory event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters =
          currentState.filters.copyWith(category: event.category);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      final sortedFunds = _sortFunds(
          filteredFunds, currentState.sortBy, currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onFilterByRisk(FundsFilterByRisk event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = currentState.filters.copyWith(risk: event.risk);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      final sortedFunds = _sortFunds(
          filteredFunds, currentState.sortBy, currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onFilterByMinAmount(
      FundsFilterByMinAmount event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters =
          currentState.filters.copyWith(minAmount: event.minAmount);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      final sortedFunds = _sortFunds(
          filteredFunds, currentState.sortBy, currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onClearFilters(FundsClearFilters event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = const FundsFilters();
      final sortedFunds = _sortFunds(currentState.allFunds, currentState.sortBy,
          currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onSortBy(FundsSortBy event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final sortedFunds =
          _sortFunds(currentState.filteredFunds, event.sortBy, event.ascending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        sortBy: event.sortBy,
        sortAscending: event.ascending,
      ));
    }
  }

  void _onSubscribeToFund(
      FundsSubscribeToFund event, Emitter<FundsState> emit) async {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
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
            errorMessage: null, // Limpiar cualquier error previo
          ));
        } else {
          emit(currentState.copyWith(
            isLoading: false,
            errorMessage:
                'No se pudo completar la suscripción. Verifica tu saldo.',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));

        // Limpiar el error después de un tiempo
        Future.delayed(const Duration(seconds: 5), () {
          if (state is FundsLoaded) {
            final currentState = state as FundsLoaded;
            emit(currentState.copyWith(errorMessage: null));
          }
        });
      }
    }
  }

  void _onCancelFund(FundsCancelFund event, Emitter<FundsState> emit) async {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
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
            errorMessage: null, // Limpiar cualquier error previo
          ));
        } else {
          emit(currentState.copyWith(
            isLoading: false,
            errorMessage: 'No se pudo completar la cancelación.',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));

        // Limpiar el error después de un tiempo
        Future.delayed(const Duration(seconds: 5), () {
          if (state is FundsLoaded) {
            final currentState = state as FundsLoaded;
            emit(currentState.copyWith(errorMessage: null));
          }
        });
      }
    }
  }

  void _onLoadUserData(
      FundsLoadUserData event, Emitter<FundsState> emit) async {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final user = await _userFundsService.getCurrentUser();
        emit(currentState.copyWith(
          currentUser: user,
          isLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    } else {
      // Si no hay estado cargado, cargar los fondos primero
      _loadFundsData(emit);
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final user = await _userFundsService.getCurrentUser();
        emit(currentState.copyWith(
          currentUser: user,
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

  void _onLoadUserFunds(
      FundsLoadUserFunds event, Emitter<FundsState> emit) async {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final userFunds = await _userFundsService.getUserFunds();
        emit(currentState.copyWith(
          userFunds: userFunds,
          isLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    } else {
      // Si no hay estado cargado, cargar los fondos primero
      _loadFundsData(emit);
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final userFunds = await _userFundsService.getUserFunds();
        emit(currentState.copyWith(
          userFunds: userFunds,
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

  void _onLoadTransactionHistory(
      FundsLoadTransactionHistory event, Emitter<FundsState> emit) async {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final transactions = await _userFundsService.getTransactionHistory();
        emit(currentState.copyWith(
          transactionHistory: transactions,
          isLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    } else {
      // Si no hay estado cargado, cargar los fondos primero
      _loadFundsData(emit);
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final transactions = await _userFundsService.getTransactionHistory();
        emit(currentState.copyWith(
          transactionHistory: transactions,
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

  void _onUpdateNotificationPreference(
      FundsUpdateNotificationPreference event, Emitter<FundsState> emit) async {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
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
        }
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _loadFundsData(Emitter<FundsState> emit) {
    // Datos mock de fondos
    final allFunds = [
      const Fund(
        id: 1,
        name: 'FPV_BTG_PACTUAL_RECAUDADORA',
        minAmount: 75000,
        category: 'FPV',
        type: 'Fondo de Pensiones Voluntarias',
        value: 0.0,
        performance: 0.0,
        risk: 'Medio',
        status: 'Disponible',
      ),
      const Fund(
        id: 2,
        name: 'FPV_BTG_PACTUAL_ECOPETROL',
        minAmount: 125000,
        category: 'FPV',
        type: 'Fondo de Pensiones Voluntarias',
        value: 0.0,
        performance: 0.0,
        risk: 'Alto',
        status: 'Disponible',
      ),
      const Fund(
        id: 3,
        name: 'DEUDAPRIVADA',
        minAmount: 50000,
        category: 'FIC',
        type: 'Fondo de Inversión Colectiva',
        value: 0.0,
        performance: 0.0,
        risk: 'Bajo',
        status: 'Disponible',
      ),
      const Fund(
        id: 4,
        name: 'FDO-ACCIONES',
        minAmount: 250000,
        category: 'FIC',
        type: 'Fondo de Inversión Colectiva',
        value: 0.0,
        performance: 0.0,
        risk: 'Alto',
        status: 'Disponible',
      ),
      const Fund(
        id: 5,
        name: 'FPV_BTG_PACTUAL_DINAMICA',
        minAmount: 100000,
        category: 'FPV',
        type: 'Fondo de Pensiones Voluntarias',
        value: 0.0,
        performance: 0.0,
        risk: 'Medio-Alto',
        status: 'Disponible',
      ),
    ];

    final summary = _calculateSummary(allFunds);
    const filters = FundsFilters();
    final sortedFunds = _sortFunds(allFunds, 'name', true);

    emit(FundsLoaded(
      allFunds: allFunds,
      filteredFunds: sortedFunds,
      summary: summary,
      filters: filters,
    ));
  }

  FundsSummary _calculateSummary(List<Fund> funds) {
    final uniqueCategories = funds.map((f) => f.category).toSet().length;
    final fpvCount = funds.where((f) => f.category == 'FPV').length;
    final ficCount = funds.where((f) => f.category == 'FIC').length;
    final averageMinAmount = funds.isEmpty
        ? 0
        : funds.fold<int>(0, (sum, fund) => sum + fund.minAmount) ~/
            funds.length;

    return FundsSummary(
      totalFunds: funds.length,
      uniqueCategories: uniqueCategories,
      fpvCount: fpvCount,
      ficCount: ficCount,
      averageMinAmount: averageMinAmount,
    );
  }

  List<Fund> _applyFilters(List<Fund> funds, FundsFilters filters) {
    return funds.where((fund) {
      if (filters.category != null && fund.category != filters.category) {
        return false;
      }
      if (filters.risk != null && fund.risk != filters.risk) {
        return false;
      }
      if (filters.minAmount != null && fund.minAmount < filters.minAmount!) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Fund> _sortFunds(List<Fund> funds, String sortBy, bool ascending) {
    final sortedFunds = List<Fund>.from(funds);

    switch (sortBy) {
      case 'name':
        sortedFunds.sort((a, b) =>
            ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'minAmount':
        sortedFunds.sort((a, b) => ascending
            ? a.minAmount.compareTo(b.minAmount)
            : b.minAmount.compareTo(a.minAmount));
        break;
      case 'risk':
        sortedFunds.sort((a, b) =>
            ascending ? a.risk.compareTo(b.risk) : b.risk.compareTo(a.risk));
        break;
      default:
        // Por defecto ordenar por nombre
        sortedFunds.sort((a, b) => a.name.compareTo(b.name));
    }

    return sortedFunds;
  }
}
