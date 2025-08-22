import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:fund_manager/features/funds/domain/models/transaction.dart';

// Clase auxiliar para los datos del gráfico
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime date;
  final Transaction? transaction;
  final bool isPositive;

  ChartDataPoint({
    required this.label,
    required this.value,
    required this.date,
    this.transaction,
    required this.isPositive,
  });
}

// Eventos
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

  const TransactionsFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class TransactionsPeriodChanged extends TransactionsEvent {
  final String period;

  const TransactionsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

class TransactionsSyncWithAppBloc extends TransactionsEvent {
  final List<Transaction> transactions;

  const TransactionsSyncWithAppBloc(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

// Estados
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final String currentFilter;
  final String currentPeriod;
  final bool isLoading;
  final List<ChartDataPoint> chartData;
  final String chartTitle;

  const TransactionsLoaded({
    required this.transactions,
    this.currentFilter = 'all',
    this.currentPeriod = 'all',
    this.isLoading = false,
    required this.chartData,
    required this.chartTitle,
  });

  @override
  List<Object?> get props => [transactions, currentFilter, currentPeriod, isLoading, chartData, chartTitle];

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    String? currentFilter,
    String? currentPeriod,
    bool? isLoading,
    List<ChartDataPoint>? chartData,
    String? chartTitle,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      isLoading: isLoading ?? this.isLoading,
      chartData: chartData ?? this.chartData,
      chartTitle: chartTitle ?? this.chartTitle,
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
  // Datos originales del AppBloc (sin filtrar)
  List<Transaction> _originalTransactions = [];
  
  TransactionsBloc() : super(TransactionsInitial()) {
    on<TransactionsStarted>(_onTransactionsStarted);
    on<TransactionsRefresh>(_onTransactionsRefresh);
    on<TransactionsFilterChanged>(_onTransactionsFilterChanged);
    on<TransactionsPeriodChanged>(_onTransactionsPeriodChanged);
    on<TransactionsSyncWithAppBloc>(_onSyncWithAppBloc);
  }

  void _onTransactionsStarted(TransactionsStarted event, Emitter<TransactionsState> emit) {
    emit(const TransactionsLoading());
    print("Start loading");
    // Los datos vendrán del AppBloc a través de TransactionsSyncWithAppBloc
    // Si el AppBloc ya está cargado, se sincronizará automáticamente
  }

  void _onTransactionsRefresh(TransactionsRefresh event, Emitter<TransactionsState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(isLoading: true));
      // Los datos se actualizarán desde el AppBloc
    }
  }

  void _onTransactionsFilterChanged(TransactionsFilterChanged event, Emitter<TransactionsState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      // Aplicar filtros sobre los datos originales
      final filteredTransactions = _applyAllFilters(
        _originalTransactions,
        event.filter,
        currentState.currentPeriod,
      );
      
      // Procesar datos para el gráfico
      final chartData = _processChartData(filteredTransactions);
      final chartTitle = _generateChartTitle(filteredTransactions);
      
      emit(currentState.copyWith(
        transactions: filteredTransactions,
        currentFilter: event.filter,
        chartData: chartData,
        chartTitle: chartTitle,
      ));
    }
  }

  void _onTransactionsPeriodChanged(TransactionsPeriodChanged event, Emitter<TransactionsState> emit) {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      // Aplicar filtros sobre los datos originales
      final filteredTransactions = _applyAllFilters(
        _originalTransactions,
        currentState.currentFilter,
        event.period,
      );
      
      // Procesar datos para el gráfico
      final chartData = _processChartData(filteredTransactions);
      final chartTitle = _generateChartTitle(filteredTransactions);
      
      emit(currentState.copyWith(
        transactions: filteredTransactions,
        currentPeriod: event.period,
        chartData: chartData,
        chartTitle: chartTitle,
      ));
    }
  }

  void _onSyncWithAppBloc(TransactionsSyncWithAppBloc event, Emitter<TransactionsState> emit) {
    print("Syncing with AppBloc - Transactions count: ${event.transactions.length}");
    // Guardar los datos originales
    _originalTransactions = List.from(event.transactions);
    
    // Aplicar filtros actuales sobre los datos originales
    final filteredTransactions = _applyAllFilters(
      _originalTransactions,
      'all', // filtro inicial
      'all', // período inicial
    );
    
    // Procesar datos para el gráfico
    final chartData = _processChartData(filteredTransactions);
    final chartTitle = _generateChartTitle(filteredTransactions);
    
    emit(TransactionsLoaded(
      transactions: filteredTransactions,
      currentFilter: 'all',
      currentPeriod: 'all',
      chartData: chartData,
      chartTitle: chartTitle,
    ));
  }

  // Método que aplica todos los filtros sobre los datos originales
  List<Transaction> _applyAllFilters(
    List<Transaction> originalTransactions,
    String filter,
    String period,
  ) {
    List<Transaction> filtered = List.from(originalTransactions);
    
    // Aplicar filtro por tipo/estado
    filtered = _applyFilter(filtered, filter);
    
    // Aplicar filtro por período
    filtered = _applyPeriodFilter(filtered, period);
    
    return filtered;
  }

  List<Transaction> _applyFilter(List<Transaction> transactions, String filter) {
    switch (filter) {
      case 'subscription':
        return transactions.where((t) => t.type == TransactionType.subscription).toList();
      case 'cancellation':
        return transactions.where((t) => t.type == TransactionType.cancellation).toList();
      case 'completed':
        return transactions.where((t) => t.status == TransactionStatus.completed).toList();
      case 'pending':
        return transactions.where((t) => t.status == TransactionStatus.pending).toList();
      default:
        return transactions;
    }
  }

  List<Transaction> _applyPeriodFilter(List<Transaction> transactions, String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'today':
        return transactions.where((t) => 
          t.date.year == now.year && 
          t.date.month == now.month && 
          t.date.day == now.day
        ).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return transactions.where((t) => t.date.isAfter(weekAgo)).toList();
      case 'month':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return transactions.where((t) => t.date.isAfter(monthAgo)).toList();
      case 'year':
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        return transactions.where((t) => t.date.isAfter(yearAgo)).toList();
      default:
        return transactions;
    }
  }

  // Procesar datos para el gráfico
  List<ChartDataPoint> _processChartData(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return [];
    }

    // Ordenar transacciones por fecha (más recientes primero)
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedTransactions.length <= 20) {
      // Mostrar transacciones individuales
      return sortedTransactions.asMap().entries.map((entry) {
        final transaction = entry.value;
        // Para suscripciones (gastos): valor negativo (rojo hacia abajo)
        // Para cancelaciones (ingresos): valor positivo (verde hacia arriba)
        final value = transaction.type == TransactionType.subscription 
            ? -transaction.amount 
            : transaction.amount;
            
        return ChartDataPoint(
          label: _truncateFundName(transaction.fundName),
          value: value,
          date: transaction.date,
          transaction: transaction,
          isPositive: transaction.type == TransactionType.cancellation,
        );
      }).toList();
    } else {
      // Hacer promedios por grupos
      final groupSize = (sortedTransactions.length / 20).ceil();
      final chartData = <ChartDataPoint>[];
      
      for (int i = 0; i < sortedTransactions.length; i += groupSize) {
        final endIndex = (i + groupSize < sortedTransactions.length) ? i + groupSize : sortedTransactions.length;
        final group = sortedTransactions.sublist(i, endIndex);
        
        // Calcular balance neto del grupo
        double netAmount = 0;
        
        for (final transaction in group) {
          if (transaction.type == TransactionType.subscription) {
            netAmount -= transaction.amount;
          } else {
            netAmount += transaction.amount;
          }
        }
        
        final startDate = group.first.date;
        final endDate = group.last.date;
        
        final label = _generateDateRangeLabel(startDate, endDate);
        
        chartData.add(ChartDataPoint(
          label: label,
          value: netAmount,
          date: startDate,
          transaction: null,
          isPositive: netAmount >= 0,
        ));
      }
      
      return chartData;
    }
  }

  // Generar título del gráfico
  String _generateChartTitle(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return 'No hay datos para mostrar';
    }

    if (transactions.length <= 20) {
      return 'Flujo de Movimientos (${transactions.length} transacciones)';
    } else {
      final groupSize = (transactions.length / 20).ceil();
      return 'Balance Neto por Períodos (${groupSize} transacciones por grupo)';
    }
  }

  // Truncar nombre del fondo
  String _truncateFundName(String fundName) {
    return fundName.length > 10 
        ? '${fundName.substring(0, 10)}...'
        : fundName;
  }

  // Generar etiqueta de rango de fechas
  String _generateDateRangeLabel(DateTime startDate, DateTime endDate) {
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${startDate.day}-${endDate.day} ${_getMonthName(startDate.month)}';
    } else {
      return '${startDate.day}/${startDate.month}-${endDate.day}/${endDate.month}';
    }
  }

  // Obtener nombre del mes
  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}
