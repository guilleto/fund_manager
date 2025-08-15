import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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

  const DashboardLoaded({
    required this.stats,
    required this.recentActivity,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [stats, recentActivity, isLoading];

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<ActivityItem>? recentActivity,
    bool? isLoading,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      isLoading: isLoading ?? this.isLoading,
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

  const DashboardStats({
    required this.totalFunds,
    required this.performance,
    required this.activeFunds,
    required this.totalTransactions,
  });

  @override
  List<Object?> get props => [totalFunds, performance, activeFunds, totalTransactions];
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
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardStarted>(_onDashboardStarted);
    on<DashboardRefresh>(_onDashboardRefresh);
    on<DashboardLoadStats>(_onLoadStats);
    on<DashboardLoadRecentActivity>(_onLoadRecentActivity);
  }

  void _onDashboardStarted(DashboardStarted event, Emitter<DashboardState> emit) {
    emit(const DashboardLoading());
    _loadDashboardData(emit);
  }

  void _onDashboardRefresh(DashboardRefresh event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(isLoading: true));
    }
    _loadDashboardData(emit);
  }

  void _onLoadStats(DashboardLoadStats event, Emitter<DashboardState> emit) {
    // Simular carga de estadísticas
    Future.delayed(const Duration(milliseconds: 300), () {
      final stats = const DashboardStats(
        totalFunds: 1250000.0,
        performance: 12.5,
        activeFunds: 8,
        totalTransactions: 24,
      );
      
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(currentState.copyWith(stats: stats));
      }
    });
  }

  void _onLoadRecentActivity(DashboardLoadRecentActivity event, Emitter<DashboardState> emit) {
    // Simular carga de actividad reciente
    Future.delayed(const Duration(milliseconds: 300), () {
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
      
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(currentState.copyWith(recentActivity: activity));
      }
    });
  }

  void _loadDashboardData(Emitter<DashboardState> emit) {
    // Cargar datos iniciales
    final stats = const DashboardStats(
      totalFunds: 1250000.0,
      performance: 12.5,
      activeFunds: 8,
      totalTransactions: 24,
    );

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

    emit(DashboardLoaded(
      stats: stats,
      recentActivity: activity,
    ));
  }
}
