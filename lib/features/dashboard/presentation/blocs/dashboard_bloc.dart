import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fund_manager/core/services/user_service.dart';

import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';

// Eventos
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

class DashboardRefresh extends DashboardEvent {
  const DashboardRefresh();
}

class DashboardLoadStats extends DashboardEvent {
  const DashboardLoadStats();
}

class DashboardLoadRecentActivity extends DashboardEvent {
  const DashboardLoadRecentActivity();
}

class DashboardSyncWithAppBloc extends DashboardEvent {
  final User? currentUser;
  final List<UserFund> userFunds;
  final List<Transaction> transactions;

  const DashboardSyncWithAppBloc({
    this.currentUser,
    this.userFunds = const [],
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [currentUser, userFunds, transactions];
}

// Estados
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ActivityItem> recentActivity;
  final bool isLoading;
  final User? currentUser;

  const DashboardLoaded({
    required this.stats,
    required this.recentActivity,
    this.isLoading = false,
    this.currentUser,
  });

  @override
  List<Object?> get props => [stats, recentActivity, isLoading, currentUser];

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<ActivityItem>? recentActivity,
    bool? isLoading,
    User? currentUser,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Modelos de datos
class DashboardStats extends Equatable {
  final double totalFunds;
  final double performance;
  final int activeFunds;
  final int totalTransactions;
  final double averageGainPerTransaction;
  final double totalGains;
  final double monthlyGrowth;
  final double userBalance;
  final List<FundRanking> topFunds;
  final List<BalanceHistory> balanceHistory;
  final TransactionSummary transactionSummary;

  const DashboardStats({
    required this.totalFunds,
    required this.performance,
    required this.activeFunds,
    required this.totalTransactions,
    required this.averageGainPerTransaction,
    required this.totalGains,
    required this.monthlyGrowth,
    required this.userBalance,
    required this.topFunds,
    required this.balanceHistory,
    required this.transactionSummary,
  });

  @override
  List<Object?> get props => [
    totalFunds,
    performance,
    activeFunds,
    totalTransactions,
    averageGainPerTransaction,
    totalGains,
    monthlyGrowth,
    userBalance,
    topFunds,
    balanceHistory,
    transactionSummary,
  ];
}

class FundRanking extends Equatable {
  final String fundName;
  final String fundId;
  final double totalInvested;
  final double currentValue;
  final double performance;
  final int transactionCount;
  final String category;

  const FundRanking({
    required this.fundName,
    required this.fundId,
    required this.totalInvested,
    required this.currentValue,
    required this.performance,
    required this.transactionCount,
    required this.category,
  });

  @override
  List<Object?> get props => [
    fundName,
    fundId,
    totalInvested,
    currentValue,
    performance,
    transactionCount,
    category,
  ];
}

class BalanceHistory extends Equatable {
  final DateTime date;
  final double balance;
  final double change;

  const BalanceHistory({
    required this.date,
    required this.balance,
    required this.change,
  });

  @override
  List<Object?> get props => [date, balance, change];
}

class TransactionSummary extends Equatable {
  final int totalTransactions;
  final int subscriptions;
  final int cancellations;
  final int performanceTransactions;
  final double totalInvested;
  final double totalWithdrawn;
  final double totalGains;
  final double averageTransactionAmount;

  const TransactionSummary({
    required this.totalTransactions,
    required this.subscriptions,
    required this.cancellations,
    required this.performanceTransactions,
    required this.totalInvested,
    required this.totalWithdrawn,
    required this.totalGains,
    required this.averageTransactionAmount,
  });

  @override
  List<Object?> get props => [
    totalTransactions,
    subscriptions,
    cancellations,
    performanceTransactions,
    totalInvested,
    totalWithdrawn,
    totalGains,
    averageTransactionAmount,
  ];
}

class ActivityItem extends Equatable {
  final String title;
  final String subtitle;
  final String time;
  final ActivityType type;
  final double amount;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.amount,
  });

  @override
  List<Object?> get props => [title, subtitle, time, type, amount];
}

enum ActivityType {
  purchase,
  sale,
  dividend,
  transfer,
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final UserService _userService;

  DashboardBloc({required UserService userService})
      : _userService = userService,
        super(const DashboardInitial()) {
    on<DashboardStarted>(_onDashboardStarted);
    on<DashboardRefresh>(_onDashboardRefresh);
    on<DashboardLoadStats>(_onLoadStats);
    on<DashboardLoadRecentActivity>(_onLoadRecentActivity);
    on<DashboardSyncWithAppBloc>(_onSyncWithAppBloc);
  }

  void _onDashboardStarted(
      DashboardStarted event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit);
  }

  void _onDashboardRefresh(
      DashboardRefresh event, Emitter<DashboardState> emit) async {
    // Si ya estamos cargando, no hacer nada
    if (state is DashboardLoading) {
      return;
    }
    
    // Si ya tenemos datos cargados, mostrar loading overlay
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(isLoading: true));
    } else {
      emit(const DashboardLoading());
    }
    
    await _loadDashboardData(emit);
  }

  void _onLoadStats(
      DashboardLoadStats event, Emitter<DashboardState> emit) async {
    // Simular carga de estadísticas
    await Future.delayed(const Duration(milliseconds: 300));
    if (!emit.isDone && state is DashboardLoaded) {
      final stats = DashboardStats(
        totalFunds: 1250000.0,
        performance: 12.5,
        activeFunds: 8,
        totalTransactions: 24,
        averageGainPerTransaction: 50.0,
        totalGains: 1200.0,
        monthlyGrowth: 1.5,
        userBalance: 150000.0,
        topFunds: [
          const FundRanking(
            fundName: 'Fondo de Renta Fija A',
            fundId: 'F123',
            totalInvested: 500000.0,
            currentValue: 550000.0,
            performance: 10.0,
            transactionCount: 10,
            category: 'Renta Fija',
          ),
          const FundRanking(
            fundName: 'Fondo de Renta Fija B',
            fundId: 'F124',
            totalInvested: 300000.0,
            currentValue: 320000.0,
            performance: 6.7,
            transactionCount: 5,
            category: 'Renta Fija',
          ),
        ],
        balanceHistory: [
          BalanceHistory(date: DateTime(2023, 1, 1), balance: 100000.0, change: 0.0),
          BalanceHistory(date: DateTime(2023, 2, 1), balance: 105000.0, change: 5000.0),
          BalanceHistory(date: DateTime(2023, 3, 1), balance: 110000.0, change: 5000.0),
        ],
        transactionSummary: const TransactionSummary(
          totalTransactions: 24,
          subscriptions: 10,
          cancellations: 5,
          performanceTransactions: 9,
          totalInvested: 1250000.0,
          totalWithdrawn: 50000.0,
          totalGains: 1200.0,
          averageTransactionAmount: 52083.33,
        ),
      );

      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(stats: stats));
    }
  }

  void _onLoadRecentActivity(
      DashboardLoadRecentActivity event, Emitter<DashboardState> emit) async {
    // Simular carga de actividad reciente
    await Future.delayed(const Duration(milliseconds: 300));
    if (!emit.isDone && state is DashboardLoaded) {
      final activity = [
        const ActivityItem(
          title: 'Compra de acciones',
          subtitle: 'AAPL - 10 acciones',
          time: 'Hace 2 horas',
          type: ActivityType.purchase,
          amount: 1500.0,
        ),
        const ActivityItem(
          title: 'Venta de bonos',
          subtitle: 'Treasury Bond - \$5,000',
          time: 'Hace 1 día',
          type: ActivityType.sale,
          amount: 5000.0,
        ),
        const ActivityItem(
          title: 'Dividendo recibido',
          subtitle: 'MSFT - \$150',
          time: 'Hace 3 días',
          type: ActivityType.dividend,
          amount: 150.0,
        ),
      ];

      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(recentActivity: activity));
    }
  }

  void _onSyncWithAppBloc(DashboardSyncWithAppBloc event, Emitter<DashboardState> emit) {
    final userFunds = event.userFunds;
    final transactions = event.transactions;
    final currentUser = event.currentUser;
    
    // Usar datos del AppBloc directamente
    final totalFunds = userFunds.fold(0.0, (sum, fund) => sum + (fund.investedAmount ?? 0.0));
    final totalTransactions = transactions.length;
    final activeFunds = userFunds.where((fund) => fund.isActive).length;
    
    // Calcular rendimiento basado en el capital inicial de 500K usando datos del AppBloc
    const double initialCapital = 500000.0;
    final totalGains = _calculateTotalGains(userFunds);
    final performance = initialCapital > 0 ? (totalGains / initialCapital) * 100 : 0.0;

    // Calcular métricas basadas en transacciones de cancelación (retiros)
    final transactionSummary = _calculateTransactionSummary(transactions);
    final topFunds = _calculateTopFundsFromCancellations(transactions);
    final balanceHistory = _calculateBalanceHistory(transactions, currentUser?.balance ?? 0.0);
    final averageGainPerTransaction = totalTransactions > 0 ? totalGains / totalTransactions : 0.0;
    final monthlyGrowth = _calculateMonthlyGrowth(balanceHistory);

    final stats = DashboardStats(
      totalFunds: totalFunds,
      performance: performance,
      activeFunds: activeFunds,
      totalTransactions: totalTransactions,
      averageGainPerTransaction: averageGainPerTransaction,
      totalGains: totalGains,
      monthlyGrowth: monthlyGrowth,
      userBalance: currentUser?.balance ?? 0.0,
      topFunds: topFunds,
      balanceHistory: balanceHistory,
      transactionSummary: transactionSummary,
    );

    // Convertir transacciones recientes a ActivityItem
    final recentTransactions = transactions.take(5).toList();
    final activity = recentTransactions.map((transaction) {
      return ActivityItem(
        title: _getActivityTitle(transaction),
        subtitle: transaction.fundName,
        time: _getTimeAgo(transaction.date),
        type: _getActivityType(transaction.type),
        amount: transaction.amount,
      );
    }).toList();

    // Si no hay actividad real, mostrar contenido sugerido
    if (activity.isEmpty) {
      final suggestedActivity = _getSuggestedContent(currentUser);
      if (!emit.isDone) {
        emit(DashboardLoaded(
          stats: stats,
          recentActivity: suggestedActivity,
          currentUser: currentUser,
        ));
      }
    } else {
      if (!emit.isDone) {
        emit(DashboardLoaded(
          stats: stats,
          recentActivity: activity,
          currentUser: currentUser,
        ));
      }
    }
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      // Cargar datos reales de transacciones
      final transactions = await _userService.getTransactionHistory();
      final userFunds = await _userService.getUserFunds();
      final currentUser = await _userService.getCurrentUser();

      // Verificar si el emit aún está activo
      if (emit.isDone) return;

      // Verificar si hay datos para mostrar
      if (transactions.isEmpty && userFunds.isEmpty) {
        // No hay datos, mostrar contenido sugerido
        if (!emit.isDone) {
          emit(DashboardLoaded(
            stats: DashboardStats(
              totalFunds: 0.0,
              performance: 0.0,
              activeFunds: 0,
              totalTransactions: 0,
              averageGainPerTransaction: 0.0,
              totalGains: 0.0,
              monthlyGrowth: 0.0,
              userBalance: currentUser?.balance ?? 0.0,
              topFunds: [],
              balanceHistory: [],
              transactionSummary: const TransactionSummary(
                totalTransactions: 0,
                subscriptions: 0,
                cancellations: 0,
                performanceTransactions: 0,
                totalInvested: 0.0,
                totalWithdrawn: 0.0,
                totalGains: 0.0,
                averageTransactionAmount: 0.0,
              ),
            ),
            recentActivity: _getSuggestedContent(currentUser),
            currentUser: currentUser,
          ));
        }
        return;
      }

      // Usar datos del UserService directamente (igual que AppBloc)
      final totalFunds = userFunds.fold(0.0, (sum, fund) => sum + (fund.investedAmount ?? 0.0));
      final totalTransactions = transactions.length;
      final activeFunds = userFunds.where((fund) => fund.isActive).length;
      
      // Calcular rendimiento basado en el capital inicial de 500K
      const double initialCapital = 500000.0;
      final totalGains = _calculateTotalGains(userFunds);
      final performance = initialCapital > 0 ? (totalGains / initialCapital) * 100 : 0.0;

      // Calcular métricas basadas en transacciones de cancelación
      final transactionSummary = _calculateTransactionSummary(transactions);
      final topFunds = _calculateTopFundsFromCancellations(transactions);
      final balanceHistory = _calculateBalanceHistory(transactions, currentUser?.balance ?? 0.0);
      final averageGainPerTransaction = totalTransactions > 0 ? totalGains / totalTransactions : 0.0;
      final monthlyGrowth = _calculateMonthlyGrowth(balanceHistory);

      final stats = DashboardStats(
        totalFunds: totalFunds,
        performance: performance,
        activeFunds: activeFunds,
        totalTransactions: totalTransactions,
        averageGainPerTransaction: averageGainPerTransaction,
        totalGains: totalGains,
        monthlyGrowth: monthlyGrowth,
        userBalance: currentUser?.balance ?? 0.0,
        topFunds: topFunds,
        balanceHistory: balanceHistory,
        transactionSummary: transactionSummary,
      );

      // Convertir transacciones recientes a ActivityItem
      final recentTransactions = transactions.take(5).toList();
      final activity = recentTransactions.map((transaction) {
        return ActivityItem(
          title: _getActivityTitle(transaction),
          subtitle: transaction.fundName,
          time: _getTimeAgo(transaction.date),
          type: _getActivityType(transaction.type),
          amount: transaction.amount,
        );
      }).toList();

      if (!emit.isDone) {
        emit(DashboardLoaded(
          stats: stats,
          recentActivity: activity,
          currentUser: currentUser,
        ));
      }
    } catch (e) {
      print('Error al cargar datos del dashboard: $e');
      if (!emit.isDone) {
        emit(const DashboardError('Error al cargar los datos del dashboard. Por favor, intenta de nuevo.'));
      }
    }
  }

  // Métodos auxiliares para calcular métricas
  TransactionSummary _calculateTransactionSummary(List<Transaction> transactions) {
    final subscriptions = transactions.where((t) => t.type == TransactionType.subscription).length;
    final cancellations = transactions.where((t) => t.type == TransactionType.cancellation).length;
    final performanceTransactions = transactions.where((t) => t.type == TransactionType.performance).length;
    
    final totalInvested = transactions
        .where((t) => t.type == TransactionType.subscription)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalWithdrawn = transactions
        .where((t) => t.type == TransactionType.cancellation)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalGains = transactions
        .where((t) => t.type == TransactionType.performance)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final averageTransactionAmount = transactions.isNotEmpty 
        ? transactions.fold(0.0, (sum, t) => sum + t.amount) / transactions.length 
        : 0.0;

    return TransactionSummary(
      totalTransactions: transactions.length,
      subscriptions: subscriptions,
      cancellations: cancellations,
      performanceTransactions: performanceTransactions,
      totalInvested: totalInvested,
      totalWithdrawn: totalWithdrawn,
      totalGains: totalGains,
      averageTransactionAmount: averageTransactionAmount,
    );
  }

  List<FundRanking> _calculateTopFundsFromCancellations(List<Transaction> transactions) {
    final fundStats = <String, Map<String, dynamic>>{};
    
    // Solo procesar transacciones de cancelación (retiros)
    final cancellationTransactions = transactions.where((t) => t.type == TransactionType.cancellation).toList();
    
    for (final transaction in cancellationTransactions) {
      if (!fundStats.containsKey(transaction.fundId)) {
        fundStats[transaction.fundId] = {
          'fundName': transaction.fundName,
          'totalWithdrawn': 0.0,
          'transactionCount': 0,
          'category': 'Fondo',
          'performance': 0.0,
        };
      }
      
      final stats = fundStats[transaction.fundId]!;
      stats['totalWithdrawn'] = (stats['totalWithdrawn'] as double) + transaction.amount;
      stats['transactionCount'] = (stats['transactionCount'] as int) + 1;
    }
    
    // Convertir a lista y ordenar por monto retirado
    final rankings = fundStats.entries.map((entry) {
      final stats = entry.value;
      final totalWithdrawn = stats['totalWithdrawn'] as double;
      
      return FundRanking(
        fundName: stats['fundName'] as String,
        fundId: entry.key,
        totalInvested: 0.0, // No tenemos esta información en cancelaciones
        currentValue: totalWithdrawn, // Usar el monto retirado como valor actual
        performance: 0.0, // No calculamos rendimiento en cancelaciones
        transactionCount: stats['transactionCount'] as int,
        category: stats['category'] as String,
      );
    }).toList();
    
    // Ordenar por monto retirado descendente y tomar los top 5
    rankings.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    return rankings.take(5).toList();
  }

  List<BalanceHistory> _calculateBalanceHistory(List<Transaction> transactions, double currentBalance) {
    final history = <BalanceHistory>[];
    
    // Ordenar transacciones por fecha (más antiguas primero)
    final sortedTransactions = transactions.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Si no hay transacciones, solo mostrar el balance actual
    if (sortedTransactions.isEmpty) {
      history.add(BalanceHistory(
        date: DateTime.now(),
        balance: currentBalance,
        change: 0.0,
      ));
      return history;
    }
    
    // Calcular el saldo inicial estimado
    // Sumamos todas las salidas (suscripciones) y restamos todas las entradas (cancelaciones)
    double totalOutflows = 0.0;
    double totalInflows = 0.0;
    
    for (final transaction in sortedTransactions) {
      switch (transaction.type) {
        case TransactionType.subscription:
          totalOutflows += transaction.amount;
          break;
        case TransactionType.cancellation:
          totalInflows += transaction.amount;
          break;
        case TransactionType.performance:
          // Los rendimientos no afectan el saldo disponible directamente
          break;
      }
    }
    
    // El saldo inicial sería el saldo actual + salidas - entradas
    double initialBalance = currentBalance + totalOutflows - totalInflows;
    
    // Si el saldo inicial es negativo, asumimos que empezó con el saldo actual
    if (initialBalance < 0) {
      initialBalance = currentBalance;
    }
    
    // Agregar el saldo inicial
    if (sortedTransactions.isNotEmpty) {
      history.add(BalanceHistory(
        date: sortedTransactions.first.date.subtract(const Duration(days: 1)),
        balance: initialBalance,
        change: 0.0,
      ));
    }
    
    // Calcular balance histórico hacia adelante
    double runningBalance = initialBalance;
    
    for (final transaction in sortedTransactions) {
      double change = 0.0;
      
      switch (transaction.type) {
        case TransactionType.subscription:
          // Al suscribirse, el saldo disponible disminuye
          change = -transaction.amount;
          break;
        case TransactionType.cancellation:
          // Al cancelar, el saldo disponible aumenta (incluye ganancias)
          change = transaction.amount;
          break;
        case TransactionType.performance:
          // Los rendimientos se reflejan en el valor del fondo, no en el saldo disponible
          // Solo se reflejan cuando se cancela la suscripción
          change = 0.0;
          break;
      }
      
      // Calcular el nuevo balance después de la transacción
      runningBalance += change;
      
      history.add(BalanceHistory(
        date: transaction.date,
        balance: runningBalance,
        change: change,
      ));
    }
    
    // Agregar el balance actual al final si es diferente al último
    if (history.isNotEmpty && (history.last.balance != currentBalance || 
        history.last.date.isBefore(DateTime.now().subtract(const Duration(days: 1))))) {
      history.add(BalanceHistory(
        date: DateTime.now(),
        balance: currentBalance,
        change: currentBalance - history.last.balance,
      ));
    }
    
    return history;
  }

  double _calculateTotalGains(List<UserFund> userFunds) {
    return userFunds.fold(0.0, (sum, fund) {
      return sum + (fund.currentValue - fund.investedAmount);
    });
  }

  double _calculateMonthlyGrowth(List<BalanceHistory> balanceHistory) {
    if (balanceHistory.length < 2) return 0.0;
    
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    final currentBalance = balanceHistory.last.balance;
    final pastBalance = balanceHistory
        .where((h) => h.date.isBefore(oneMonthAgo))
        .lastOrNull?.balance ?? currentBalance;
    
    if (pastBalance == 0.0) return 0.0;
    
    return ((currentBalance - pastBalance) / pastBalance) * 100;
  }

  List<ActivityItem> _getSuggestedContent(User? user) {
    return [
      const ActivityItem(
        title: 'Fondo de Renta Fija',
        subtitle: 'Recomendado para principiantes',
        time: 'Recomendado',
        type: ActivityType.purchase,
        amount: 100000.0,
      ),
    ];
  }

  String _getActivityTitle(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.subscription:
        return 'Suscripción realizada';
      case TransactionType.cancellation:
        return 'Suscripción cancelada';
      case TransactionType.performance:
        return 'Rendimiento generado';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  ActivityType _getActivityType(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.subscription:
        return ActivityType.purchase;
      case TransactionType.cancellation:
        return ActivityType.sale;
      case TransactionType.performance:
        return ActivityType.dividend;
    }
  }
}
