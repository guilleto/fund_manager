import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:fund_manager/core/widgets/app_scaffold.dart';
import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import '../blocs/transactions_bloc.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionsBloc()..add(const TransactionsStarted()),
      child: const TransactionsView(),
    );
  }
}

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Todas';
  String _selectedPeriod = 'Último mes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppLoaded && !state.isLoading) {
              // Sincronizar transacciones cuando el AppBloc se actualiza
              context.read<TransactionsBloc>().add(const TransactionsSyncWithAppBloc());
            }
          },
        ),
      ],
      child: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          return AppScaffold(
            title: 'Historial de Transacciones',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<TransactionsBloc>().add(const TransactionsRefresh());
                  context.read<AppBloc>().add(const AppLoadUserData());
                },
                tooltip: 'Actualizar',
              ),
            ],
            body: state is TransactionsLoading
                ? const Center(child: CircularProgressIndicator())
                : state is TransactionsLoaded
                    ? _buildContent(context, state)
                    : state is TransactionsError
                        ? Center(child: Text('Error: ${state.message}'))
                        : const Center(child: Text('Cargando...')),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionsLoaded state) {
    return Column(
      children: [
        _buildFilters(context, state),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsList(state),
              _buildAnalytics(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, TransactionsLoaded state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Transacciones'),
              Tab(text: 'Análisis'),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Filtro',
                  _selectedFilter,
                  ['Todas', 'Suscripciones', 'Cancelaciones', 'Rendimientos'],
                  (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                    context.read<TransactionsBloc>().add(
                          TransactionsFilterChanged(filter: value),
                        );
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildFilterDropdown(
                  'Período',
                  _selectedPeriod,
                  ['Último mes', 'Últimos 3 meses', 'Último año', 'Todo'],
                  (value) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                    context.read<TransactionsBloc>().add(
                          TransactionsPeriodChanged(period: value),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(TransactionsLoaded state) {
    final filteredTransactions = _getFilteredTransactions(state.transactions);

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No hay transacciones',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No se encontraron transacciones con los filtros seleccionados',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isPositive = transaction.type == TransactionType.subscription ||
        transaction.type == TransactionType.performance;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.type);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.fundName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getTransactionDescription(transaction),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    FormatUtils.formatDate(transaction.date),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}\$${FormatUtils.formatAmount(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getTransactionTypeText(transaction.type),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics(TransactionsLoaded state) {
    return ResponsiveWidget(
      mobile: _buildMobileAnalytics(state),
      tablet: _buildTabletAnalytics(state),
      desktop: _buildDesktopAnalytics(state),
    );
  }

  Widget _buildMobileAnalytics(TransactionsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildSummaryCards(state),
          SizedBox(height: 24.h),
          _buildTransactionsChart(state),
          SizedBox(height: 24.h),
          _buildFundPerformanceChart(state),
        ],
      ),
    );
  }

  Widget _buildTabletAnalytics(TransactionsLoaded state) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _buildSummaryCards(state),
          SizedBox(height: 24.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTransactionsChart(state),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  flex: 1,
                  child: _buildFundPerformanceChart(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAnalytics(TransactionsLoaded state) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          _buildSummaryCards(state),
          SizedBox(height: 32.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTransactionsChart(state),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  flex: 1,
                  child: _buildFundPerformanceChart(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TransactionsLoaded state) {
    final stats = _calculateStats(state.transactions);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Transacciones',
          '${stats.totalTransactions}',
          Icons.receipt,
          Colors.blue,
        ),
        _buildStatCard(
          'Monto Total',
          '\$${FormatUtils.formatAmount(stats.totalAmount)}',
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildStatCard(
          'Promedio por Transacción',
          '\$${FormatUtils.formatAmount(stats.averageAmount)}',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'Fondos Activos',
          '${stats.activeFunds}',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsChart(TransactionsLoaded state) {
    final chartData = _prepareChartData(state.transactions);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolución de Transacciones',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40.w,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: TextStyle(fontSize: 10.sp),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < chartData.length) {
                            return Text(
                              chartData[value.toInt()].label,
                              style: TextStyle(fontSize: 10.sp),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundPerformanceChart(TransactionsLoaded state) {
    final fundData = _prepareFundData(state.transactions);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rendimiento por Fondo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sections: fundData.map((data) {
                    return PieChartSectionData(
                      value: data.value,
                      title: '${data.label}\n${data.value.toStringAsFixed(1)}%',
                      color: data.color,
                      radius: 60.r,
                      titleStyle: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // Aplicar filtro por tipo
    switch (_selectedFilter) {
      case 'Suscripciones':
        filtered = filtered.where((t) => t.type == TransactionType.subscription).toList();
        break;
      case 'Cancelaciones':
        filtered = filtered.where((t) => t.type == TransactionType.cancellation).toList();
        break;
      case 'Rendimientos':
        filtered = filtered.where((t) => t.type == TransactionType.performance).toList();
        break;
    }

    // Aplicar filtro por período
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Último mes':
        filtered = filtered.where((t) => 
          t.date.isAfter(now.subtract(const Duration(days: 30)))).toList();
        break;
      case 'Últimos 3 meses':
        filtered = filtered.where((t) => 
          t.date.isAfter(now.subtract(const Duration(days: 90)))).toList();
        break;
      case 'Último año':
        filtered = filtered.where((t) => 
          t.date.isAfter(now.subtract(const Duration(days: 365)))).toList();
        break;
    }

    return filtered;
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.subscription:
        return Icons.add_circle;
      case TransactionType.cancellation:
        return Icons.remove_circle;
      case TransactionType.performance:
        return Icons.trending_up;
    }
  }

  String _getTransactionDescription(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.subscription:
        return 'Suscripción realizada';
      case TransactionType.cancellation:
        return 'Suscripción cancelada';
      case TransactionType.performance:
        return 'Rendimiento generado';
    }
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.subscription:
        return 'SUSCRIPCIÓN';
      case TransactionType.cancellation:
        return 'CANCELACIÓN';
      case TransactionType.performance:
        return 'RENDIMIENTO';
    }
  }

  List<ChartData> _prepareChartData(List<Transaction> transactions) {
    // Agrupar transacciones por fecha y calcular totales
    final Map<String, double> dailyTotals = {};
    
    for (final transaction in transactions) {
      final dateKey = FormatUtils.formatDate(transaction.date);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + transaction.amount;
    }

    // Convertir a lista ordenada
    final sortedEntries = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.map((entry) {
      return ChartData(entry.key, entry.value);
    }).toList();
  }

  List<FundData> _prepareFundData(List<Transaction> transactions) {
    // Agrupar por fondo y calcular rendimientos
    final Map<String, double> fundTotals = {};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.performance) {
        fundTotals[transaction.fundName] = 
          (fundTotals[transaction.fundName] ?? 0) + transaction.amount;
      }
    }

    final total = fundTotals.values.fold(0.0, (sum, value) => sum + value);
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];

    return fundTotals.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0;
      final colorIndex = fundTotals.keys.toList().indexOf(entry.key) % colors.length;
      
      return FundData(
        entry.key,
        percentage.toDouble(),
        colors[colorIndex],
      );
    }).toList();
  }

  TransactionStats _calculateStats(List<Transaction> transactions) {
    final totalTransactions = transactions.length;
    final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final averageAmount = totalTransactions > 0 ? totalAmount / totalTransactions : 0;
    final activeFunds = transactions
        .where((t) => t.type == TransactionType.subscription)
        .map((t) => t.fundName)
        .toSet()
        .length;

    return TransactionStats(
      totalTransactions: totalTransactions,
      totalAmount: totalAmount,
      averageAmount: averageAmount.toDouble(),
      activeFunds: activeFunds,
    );
  }
}

// Clases auxiliares
class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}

class FundData {
  final String label;
  final double value;
  final Color color;

  FundData(this.label, this.value, this.color);
}

class TransactionStats {
  final int totalTransactions;
  final double totalAmount;
  final double averageAmount;
  final int activeFunds;

  TransactionStats({
    required this.totalTransactions,
    required this.totalAmount,
    required this.averageAmount,
    required this.activeFunds,
  });
}
