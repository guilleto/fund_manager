import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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

class FundsInvestInFund extends FundsEvent {
  final int fundId;

  const FundsInvestInFund(this.fundId);

  @override
  List<Object?> get props => [fundId];
}

class FundsViewDetails extends FundsEvent {
  final int fundId;

  const FundsViewDetails(this.fundId);

  @override
  List<Object?> get props => [fundId];
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
  final bool isLoading;

  const FundsLoaded({
    required this.allFunds,
    required this.filteredFunds,
    required this.summary,
    required this.filters,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [allFunds, filteredFunds, summary, filters, isLoading];

  FundsLoaded copyWith({
    List<Fund>? allFunds,
    List<Fund>? filteredFunds,
    FundsSummary? summary,
    FundsFilters? filters,
    bool? isLoading,
  }) {
    return FundsLoaded(
      allFunds: allFunds ?? this.allFunds,
      filteredFunds: filteredFunds ?? this.filteredFunds,
      summary: summary ?? this.summary,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FundsError extends FundsState {
  final String message;

  const FundsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Modelos de datos
class Fund extends Equatable {
  final int id;
  final String name;
  final int minAmount;
  final String category;
  final String type;
  final String risk;
  final String status;
  final double value;
  final double performance;

  const Fund({
    required this.id,
    required this.name,
    required this.minAmount,
    required this.category,
    required this.type,
    required this.risk,
    required this.status,
    required this.value,
    required this.performance,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        minAmount,
        category,
        type,
        risk,
        status,
        value,
        performance,
      ];
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
  FundsBloc() : super(const FundsInitial()) {
    on<FundsStarted>(_onFundsStarted);
    on<FundsRefresh>(_onFundsRefresh);
    on<FundsFilterByCategory>(_onFilterByCategory);
    on<FundsFilterByRisk>(_onFilterByRisk);
    on<FundsFilterByMinAmount>(_onFilterByMinAmount);
    on<FundsClearFilters>(_onClearFilters);
    on<FundsInvestInFund>(_onInvestInFund);
    on<FundsViewDetails>(_onViewDetails);
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
      
      emit(currentState.copyWith(
        filteredFunds: filteredFunds,
        filters: newFilters,
      ));
    }
  }

  void _onFilterByRisk(FundsFilterByRisk event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = currentState.filters.copyWith(risk: event.risk);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      
      emit(currentState.copyWith(
        filteredFunds: filteredFunds,
        filters: newFilters,
      ));
    }
  }

  void _onFilterByMinAmount(FundsFilterByMinAmount event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = currentState.filters.copyWith(minAmount: event.minAmount);
      final filteredFunds = _applyFilters(currentState.allFunds, newFilters);
      
      emit(currentState.copyWith(
        filteredFunds: filteredFunds,
        filters: newFilters,
      ));
    }
  }

  void _onClearFilters(FundsClearFilters event, Emitter<FundsState> emit) {
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      final newFilters = const FundsFilters();
      
      emit(currentState.copyWith(
        filteredFunds: currentState.allFunds,
        filters: newFilters,
      ));
    }
  }

  void _onInvestInFund(FundsInvestInFund event, Emitter<FundsState> emit) {
    // Aquí iría la lógica para invertir en el fondo
    // Por ahora solo emitimos el estado actual
    if (state is FundsLoaded) {
      final currentState = state as FundsLoaded;
      emit(currentState.copyWith(isLoading: true));
      
      // Simular proceso de inversión
      Future.delayed(const Duration(milliseconds: 1000), () {
        emit(currentState.copyWith(isLoading: false));
      });
    }
  }

  void _onViewDetails(FundsViewDetails event, Emitter<FundsState> emit) {
    // Aquí iría la lógica para ver detalles del fondo
    // Por ahora solo emitimos el estado actual
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

    emit(FundsLoaded(
      allFunds: allFunds,
      filteredFunds: allFunds,
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
        : funds.fold<int>(0, (sum, fund) => sum + fund.minAmount) ~/ funds.length;

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
}
