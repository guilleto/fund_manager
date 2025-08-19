import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import 'package:fund_manager/features/funds/domain/services/user_funds_service.dart';
import 'package:fund_manager/features/funds/domain/services/notification_service.dart';

// Events
abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsStarted extends TransactionsEvent {
  const TransactionsStarted();
}

class TransactionsRefresh extends TransactionsEvent {
  const TransactionsRefresh();
}

class TransactionsFilterChanged extends TransactionsEvent {
  final String filter;

  const TransactionsFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class TransactionsPeriodChanged extends TransactionsEvent {
  final String period;

  const TransactionsPeriodChanged({required this.period});

  @override
  List<Object?> get props => [period];
}

class TransactionsSyncWithAppBloc extends TransactionsEvent {
  const TransactionsSyncWithAppBloc();
}

// States
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final String currentFilter;
  final String currentPeriod;
  final bool isLoading;

  const TransactionsLoaded({
    required this.transactions,
    this.currentFilter = 'Todas',
    this.currentPeriod = 'Último mes',
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [transactions, currentFilter, currentPeriod, isLoading];

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    String? currentFilter,
    String? currentPeriod,
    bool? isLoading,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final UserFundsService _userFundsService;

  TransactionsBloc({UserFundsService? userFundsService})
      : _userFundsService = userFundsService ?? MockUserFundsService(MockNotificationService()),
        super(TransactionsInitial()) {
    on<TransactionsStarted>(_onTransactionsStarted);
    on<TransactionsRefresh>(_onTransactionsRefresh);
    on<TransactionsFilterChanged>(_onTransactionsFilterChanged);
    on<TransactionsPeriodChanged>(_onTransactionsPeriodChanged);
    on<TransactionsSyncWithAppBloc>(_onSyncWithAppBloc);
  }

  Future<void> _onTransactionsStarted(
    TransactionsStarted event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(TransactionsLoading());
    try {
      // Simular un pequeño delay para asegurar que los datos estén actualizados
      await Future.delayed(const Duration(milliseconds: 100));
      final transactions = await _userFundsService.getTransactionHistory();
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionsError(message: e.toString()));
    }
  }

  Future<void> _onTransactionsRefresh(
    TransactionsRefresh event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(isLoading: true));
      
      try {
        final transactions = await _userFundsService.getTransactionHistory();
        emit(TransactionsLoaded(
          transactions: transactions,
          currentFilter: currentState.currentFilter,
          currentPeriod: currentState.currentPeriod,
        ));
      } catch (e) {
        emit(TransactionsError(message: e.toString()));
      }
    }
  }

  void _onTransactionsFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }

  void _onTransactionsPeriodChanged(
    TransactionsPeriodChanged event,
    Emitter<TransactionsState> emit,
  ) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(currentPeriod: event.period));
    }
  }

  void _onSyncWithAppBloc(
    TransactionsSyncWithAppBloc event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      final transactions = await _userFundsService.getTransactionHistory();
      if (state is TransactionsLoaded) {
        final currentState = state as TransactionsLoaded;
        emit(currentState.copyWith(transactions: transactions));
      } else {
        emit(TransactionsLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(TransactionsError(message: e.toString()));
    }
  }
}
