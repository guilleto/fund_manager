import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:fund_manager/core/widgets/app_scaffold.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import '../blocs/transactions_bloc.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final transactionsBloc = TransactionsBloc();
        
        // Verificar si el AppBloc ya está cargado y sincronizar inmediatamente
        final appState = context.read<AppBloc>().state;
        if (appState is AppLoaded) {
          print('AppBloc ya está cargado, sincronizando inmediatamente');
          transactionsBloc.add(TransactionsSyncWithAppBloc(appState.transactions));
        } else {
          print('AppBloc no está cargado aún, iniciando normalmente');
          transactionsBloc.add(const TransactionsStarted());
        }
        
        return transactionsBloc;
      },
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
  String _selectedFilter = 'all';
  String _selectedPeriod = 'all';

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
              print('Sincronizando transacciones con el AppBloc');
              context.read<TransactionsBloc>().add(TransactionsSyncWithAppBloc(state.transactions));
            }
            print('AppBloc cargado: ${state is AppLoaded}');
          },
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) {
          print('AppBloc cargado: ${appState is AppLoaded}');
          if (appState is AppLoaded) {
            return BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, transactionsState) {
                print('TransactionsBloc cargado: ${transactionsState is TransactionsLoaded}');
                return AppScaffold(
                  title: 'Historial de Transacciones',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<TransactionsBloc>().add(const TransactionsRefresh());
                        context.read<AppBloc>().add(const AppRefreshData());
                      },
                      tooltip: 'Actualizar',
                    ),
                  ],
                  body: transactionsState is TransactionsLoading
                      ? const Center(child: CircularProgressIndicator(
                        color: Colors.teal,
                      ))
                      : transactionsState is TransactionsLoaded
                          ? _buildContent(context, transactionsState)
                          : const Center(child: Text('Cargando...')),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator(
            color: Colors.red,
          ));
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
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filtro',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todas')),
                      DropdownMenuItem(value: 'subscription', child: Text('Suscripciones')),
                      DropdownMenuItem(value: 'cancellation', child: Text('Cancelaciones')),
                      DropdownMenuItem(value: 'completed', child: Text('Completadas')),
                      DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFilter = value;
                        });
                        context.read<TransactionsBloc>().add(TransactionsFilterChanged(value));
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todo')),
                      DropdownMenuItem(value: 'today', child: Text('Hoy')),
                      DropdownMenuItem(value: 'week', child: Text('Última semana')),
                      DropdownMenuItem(value: 'month', child: Text('Último mes')),
                      DropdownMenuItem(value: 'year', child: Text('Último año')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        context.read<TransactionsBloc>().add(TransactionsPeriodChanged(value));
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Lista'),
                Tab(text: 'Análisis'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(TransactionsLoaded state) {
    if (state.transactions.isEmpty) {
      return const Center(
        child: Text('No hay transacciones para mostrar'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.transactions.length,
      itemBuilder: (context, index) {
        final transaction = state.transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.subscription 
              ? Colors.green 
              : Colors.red,
          child: Icon(
            transaction.type == TransactionType.subscription 
                ? Icons.add 
                : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.fundName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transaction.type.toString().split('.').last} - ${FormatUtils.formatDate(transaction.date)}',
            ),
            Text(
              transaction.description!,
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FormatUtils.formatCurrency(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == TransactionType.subscription 
                    ? Colors.green 
                    : Colors.red,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: transaction.status == TransactionStatus.completed 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                transaction.status.toString().split('.').last,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: transaction.status == TransactionStatus.completed 
                      ? Colors.green 
                      : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics(TransactionsLoaded state) {
    if (state.transactions.isEmpty) {
      return const Center(
        child: Text('No hay datos para analizar'),
      );
    }

    final totalAmount = state.transactions.fold<double>(
      0, (sum, transaction) => sum + transaction.amount
    );
    
    final subscriptionCount = state.transactions
        .where((t) => t.type == TransactionType.subscription)
        .length;
    
    final cancellationCount = state.transactions
        .where((t) => t.type == TransactionType.cancellation)
        .length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildSummaryCards(totalAmount, subscriptionCount, cancellationCount),
          SizedBox(height: 24.h),
          _buildChart(state),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double totalAmount, int subscriptionCount, int cancellationCount) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total',
            FormatUtils.formatCurrency(totalAmount),
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildSummaryCard(
            'Suscripciones',
            subscriptionCount.toString(),
            Icons.add_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildSummaryCard(
            'Cancelaciones',
            cancellationCount.toString(),
            Icons.remove_circle,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(TransactionsLoaded state) {
    if (state.chartData.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Text(
              'No hay datos para mostrar en el gráfico',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.chartTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timeline,
                    size: 16.sp,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Orden temporal: Más recientes → Más antiguos',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50.w,
                        getTitlesWidget: (value, meta) {
                          final absValue = value.abs();
                          final sign = value >= 0 ? '+' : '-';
                          return Text(
                            '$sign\$${absValue.toInt()}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: value >= 0 ? Colors.green : Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50.h,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < state.chartData.length) {
                            final dataPoint = state.chartData[value.toInt()];
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Column(
                                children: [
                                  Text(
                                    dataPoint.label,
                                    style: TextStyle(fontSize: 8.sp),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (value.toInt() == 0 && state.chartData.length > 1)
                                    Container(
                                      margin: EdgeInsets.only(top: 4.h),
                                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'MÁS RECIENTE',
                                        style: TextStyle(
                                          fontSize: 6.sp,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (value.toInt() == state.chartData.length - 1  && state.chartData.length > 1)
                                    Container(
                                      margin: EdgeInsets.only(top: 4.h),
                                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'MÁS ANTIGUO',
                                        style: TextStyle(
                                          fontSize: 6.sp,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: state.chartData.asMap().entries.map((entry) {
                    final dataPoint = entry.value;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: dataPoint.value,
                          color: dataPoint.isPositive ? Colors.green : Colors.red,
                          width: 16.w,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildChartLegend(state.chartData),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(List<ChartDataPoint> chartData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles:',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ...chartData.take(5).map((dataPoint) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: dataPoint.isPositive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${dataPoint.label}: ${dataPoint.value >= 0 ? '+' : ''}\$${dataPoint.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: dataPoint.isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        )),
        if (chartData.length > 5)
          Text(
            '... y ${chartData.length - 5} más',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
