import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fund_manager/core/services/user_service.dart';

import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';

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

class FundsFilterByAmountRange extends FundsEvent {
  final RangeValues? amountRange;

  const FundsFilterByAmountRange({this.amountRange});

  @override
  List<Object?> get props => [amountRange];
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



class FundsSyncWithAppBloc extends FundsEvent {
  final User? currentUser;
  final List<UserFund> userFunds;
  final List<Transaction> transactions;

  const FundsSyncWithAppBloc({
    this.currentUser,
    this.userFunds = const [],
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [currentUser, userFunds, transactions];
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
  final List<Transaction> transactions;
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
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FundsLoaded copyWith({
    List<Fund>? allFunds,
    List<Fund>? filteredFunds,
    FundsSummary? summary,
    FundsFilters? filters,
    String? sortBy,
    bool? sortAscending,
    User? currentUser,
    List<UserFund>? userFunds,
    List<Transaction>? transactions,
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
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

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
        transactions,
        isLoading,
        errorMessage,
      ];
}

class FundsError extends FundsState {
  final String message;

  const FundsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Modelos auxiliares
class FundsFilters extends Equatable {
  final String? category;
  final String? risk;
  final RangeValues? amountRange;

  const FundsFilters({
    this.category,
    this.risk,
    this.amountRange,
  });

  FundsFilters copyWith({
    String? category,
    String? risk,
    RangeValues? amountRange,
  }) {
    return FundsFilters(
      category: category ?? this.category,
      risk: risk ?? this.risk,
      amountRange: amountRange ?? this.amountRange,
    );
  }

  @override
  List<Object?> get props => [category, risk, amountRange];
}

class FundsSummary extends Equatable {
  final int totalFunds;
  final int fpvCount;
  final int ficCount;
  final double totalMinAmount;

  const FundsSummary({
    required this.totalFunds,
    required this.fpvCount,
    required this.ficCount,
    required this.totalMinAmount,
  });

  @override
  List<Object?> get props => [totalFunds, fpvCount, ficCount, totalMinAmount];
}

// BLoC
class FundsBloc extends Bloc<FundsEvent, FundsState> {
  final UserService _userService;

  FundsBloc(this._userService) : super(const FundsInitial()) {
    on<FundsStarted>(_onFundsStarted);
    on<FundsRefresh>(_onFundsRefresh);
    on<FundsFilterByCategory>(_onFilterByCategory);
    on<FundsFilterByRisk>(_onFilterByRisk);
    on<FundsFilterByAmountRange>(_onFilterByAmountRange);
    on<FundsClearFilters>(_onClearFilters);
    on<FundsSortBy>(_onSortBy);
    on<FundsSyncWithAppBloc>(_onSyncWithAppBloc);
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

  void _onFilterByCategory(FundsFilterByCategory event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = currentState.filters.copyWith(category: event.category);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      final sortedFunds = _sortFunds(filteredFunds, currentState.sortBy, currentState.sortAscending);

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
      final sortedFunds = _sortFunds(filteredFunds, currentState.sortBy, currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onFilterByAmountRange(FundsFilterByAmountRange event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = currentState.filters.copyWith(amountRange: event.amountRange);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      final sortedFunds = _sortFunds(filteredFunds, currentState.sortBy, currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onClearFilters(FundsClearFilters event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      const newFilters = FundsFilters();
      final sortedFunds = _sortFunds(currentState.allFunds, currentState.sortBy, currentState.sortAscending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        filters: newFilters,
      ));
    }
  }

  void _onSortBy(FundsSortBy event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final sortedFunds = _sortFunds(currentState.filteredFunds, event.sortBy, event.ascending);

      emit(currentState.copyWith(
        filteredFunds: sortedFunds,
        sortBy: event.sortBy,
        sortAscending: event.ascending,
      ));
    }
  }



  void _onSyncWithAppBloc(FundsSyncWithAppBloc event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(
        currentUser: event.currentUser,
        userFunds: event.userFunds,
        transactions: event.transactions,
      ));
    } else {
      // Si no hay estado cargado, cargar los fondos primero
      _loadFundsData(emit);
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(
        currentUser: event.currentUser,
        userFunds: event.userFunds,
        transactions: event.transactions,
      ));
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
    final fpvCount = funds.where((fund) => fund.category == 'FPV').length;
    final ficCount = funds.where((fund) => fund.category == 'FIC').length;
    final totalMinAmount = funds.fold<double>(0, (sum, fund) => sum + fund.minAmount);

    return FundsSummary(
      totalFunds: funds.length,
      fpvCount: fpvCount,
      ficCount: ficCount,
      totalMinAmount: totalMinAmount,
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
      if (filters.amountRange != null) {
        final minAmount = filters.amountRange!.start;
        final maxAmount = filters.amountRange!.end;
        if (fund.minAmount < minAmount || fund.minAmount > maxAmount) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Fund> _sortFunds(List<Fund> funds, String sortBy, bool ascending) {
    final sortedFunds = List<Fund>.from(funds);
    
    switch (sortBy) {
      case 'name':
        sortedFunds.sort((a, b) => ascending 
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
        break;
      case 'minAmount':
        sortedFunds.sort((a, b) => ascending 
          ? a.minAmount.compareTo(b.minAmount)
          : b.minAmount.compareTo(a.minAmount));
        break;
      case 'risk':
        sortedFunds.sort((a, b) => ascending 
          ? a.risk.compareTo(b.risk)
          : b.risk.compareTo(a.risk));
        break;
      case 'category':
        sortedFunds.sort((a, b) => ascending 
          ? a.category.compareTo(b.category)
          : b.category.compareTo(a.category));
        break;
    }
    
    return sortedFunds;
  }
}
