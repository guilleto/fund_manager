import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/widgets/responsive_widget.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/blocs/app_bloc.dart';
import '../blocs/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppLoaded) {
          // Sincronizar datos del AppBloc con el DashboardBloc
          context.read<DashboardBloc>().add(DashboardSyncWithAppBloc(
            currentUser: state.currentUser,
            userFunds: state.userFunds,
            transactions: state.transactions,
          ));
        }
      },
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Actualizar datos al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(const DashboardRefresh());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return AppScaffold(
          title: 'Dashboard',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<DashboardBloc>().add(const DashboardRefresh()),
              tooltip: 'Actualizar',
            ),
          ],
          body: state is DashboardLoading
              ? const Center(child: CircularProgressIndicator())
              : state is DashboardLoaded
                  ? ResponsiveWidget(
                      mobile: _buildMobileLayout(context, state),
                      tablet: _buildTabletLayout(context, state),
                      desktop: _buildDesktopLayout(context, state),
                    )
                  : state is DashboardError
                      ? Center(child: Text('Error: ${state.message}'))
                      : const Center(child: Text('Cargando...')),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, state),
          SizedBox(height: 20.0),
          _buildUserBalanceCard(state),
          SizedBox(height: 20.0),
          _buildMainStatsGrid(state.stats),
          SizedBox(height: 20.0),
          _buildTransactionSummaryCard(state.stats.transactionSummary),
          SizedBox(height: 20.0),
          _buildTopFundsCard(state.stats.topFunds),
          SizedBox(height: 20.0),
          _buildBalanceChartCard(state.stats.balanceHistory),
          SizedBox(height: 20.0),
          _buildRecentActivity(state.recentActivity),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildWelcomeCard(context, state),
          SizedBox(height: 20.0),
          _buildUserBalanceCard(state),
          SizedBox(height: 20.0),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMainStatsGrid(state.stats),
                        SizedBox(height: 20.0),
                        _buildTransactionSummaryCard(state.stats.transactionSummary),
                        SizedBox(height: 20.0),
                        _buildTopFundsCard(state.stats.topFunds),
                        SizedBox(height: 20.0),
                        _buildBalanceChartCard(state.stats.balanceHistory),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  flex: 1,
                  child: _buildRecentActivity(state.recentActivity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildWelcomeCard(context, state),
          SizedBox(height: 24.0),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMainStatsGrid(state.stats),
                        SizedBox(height: 24.0),
                        Row(
                          children: [
                            Expanded(child: _buildTransactionSummaryCard(state.stats.transactionSummary)),
                            SizedBox(width: 24.0),
                            Expanded(child: _buildTopFundsCard(state.stats.topFunds)),
                          ],
                        ),
                        SizedBox(height: 24.0),
                        _buildBalanceChartCard(state.stats.balanceHistory),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                  children: [
                    _buildUserBalanceCard(state),
                    SizedBox(height: 24.0),
                  _buildRecentActivity(state.recentActivity),
                  ],
                ),
                ),
                SizedBox(width: 24.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, DashboardLoaded state) {
    final hasData = state.stats.totalTransactions > 0 || state.stats.activeFunds > 0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.0,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 24.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasData ? '¡Bienvenido de vuelta!' : '¡Bienvenido a Fund Manager!',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.currentUser != null) ...[
                        SizedBox(height: 4.0),
                        Text(
                          state.currentUser!.name,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            Text(
              hasData 
                  ? 'Aquí tienes un resumen completo de tus inversiones y rendimiento.'
                  : 'Comienza tu viaje de inversión explorando los fondos disponibles.',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            if (!hasData) ...[
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AppBloc>().add(const AppNavigateTo(AppRoute.funds));
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Explorar Fondos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserBalanceCard(DashboardLoaded state) {
    final hasData = state.stats.totalTransactions > 0 || state.stats.activeFunds > 0;
    
    return Builder(
      builder: (context) => Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 24.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 12.0),
                  Text(
                    'Saldo Actual',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${FormatUtils.formatAmount(state.stats.userBalance)}',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        if (hasData) ...[
                          Row(
                            children: [
                              Icon(
                                state.stats.monthlyGrowth >= 0 
                                    ? Icons.trending_up 
                                    : Icons.trending_down,
                                size: 16.0,
                                color: state.stats.monthlyGrowth >= 0 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '${state.stats.monthlyGrowth >= 0 ? '+' : ''}${state.stats.monthlyGrowth.toStringAsFixed(1)}% este mes',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: state.stats.monthlyGrowth >= 0 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            'Saldo disponible para inversiones',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasData) ...[
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '\$${FormatUtils.formatAmount(state.stats.totalGains)}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Ganancias Totales',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatsGrid(DashboardStats stats) {
    final hasData = stats.totalTransactions > 0 || stats.activeFunds > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasData ? 'Resumen de Inversiones' : 'Tu Cuenta',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        if (hasData) ...[
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Invertido',
                '\$${FormatUtils.formatAmount(stats.totalFunds)}',
                Icons.account_balance,
                Colors.blue,
              ),
              _buildStatCard(
                'Rendimiento',
                '${stats.performance >= 0 ? '+' : ''}${stats.performance.toStringAsFixed(2)}%',
                Icons.trending_up,
                Colors.green,
              ),
              _buildStatCard(
                'Fondos Activos',
                '${stats.activeFunds}',
                Icons.check_circle,
                Colors.orange,
              ),
              _buildStatCard(
                'Promedio por Transacción',
                '\$${FormatUtils.formatAmount(stats.averageGainPerTransaction)}',
                Icons.analytics,
                Colors.purple,
              ),
            ],
          ),
        ] else ...[
          _buildEmptyStateCard(),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28.0,
              color: color,
            ),
            SizedBox(height: 6.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.0,
                color: Colors.grey[600],
                height: 1.2,
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

  Widget _buildEmptyStateCard() {
    return Builder(
      builder: (context) => Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 48.0,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.0),
              Text(
                'No tienes fondos activos',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Comienza invirtiendo en uno de nuestros fondos disponibles',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AppBloc>().add(const AppNavigateTo(AppRoute.funds));
                },
                icon: const Icon(Icons.add),
                label: const Text('Suscribirse a un Fondo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSummaryCard(TransactionSummary summary) {
    return Builder(
      builder: (context) => Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 20.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Resumen de Transacciones',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _buildTransactionRow('Total Transacciones', '${summary.totalTransactions}'),
              _buildTransactionRow('Suscripciones', '${summary.subscriptions}'),
              _buildTransactionRow('Cancelaciones', '${summary.cancellations}'),
              _buildTransactionRow('Rendimientos', '${summary.performanceTransactions}'),
              Divider(height: 16.0),
              _buildTransactionRow(
                'Total Invertido', 
                '\$${FormatUtils.formatAmount(summary.totalInvested)}',
                isAmount: true,
              ),
              _buildTransactionRow(
                'Total Retirado', 
                '\$${FormatUtils.formatAmount(summary.totalWithdrawn)}',
                isAmount: true,
              ),
              _buildTransactionRow(
                'Promedio por Transacción', 
                '\$${FormatUtils.formatAmount(summary.averageTransactionAmount)}',
                isAmount: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String label, String value, {bool isAmount = false}) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: isAmount ? FontWeight.w600 : FontWeight.w500,
                color: isAmount ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFundsCard(List<FundRanking> topFunds) {
    return Builder(
      builder: (context) => Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 20.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Top Fondos por Retiros',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              if (topFunds.isNotEmpty) ...[
                ...topFunds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fund = entry.value;
                  return _buildFundRankingItem(index + 1, fund);
                }).toList(),
              ] else ...[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 48.0,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'No hay fondos para mostrar',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundRankingItem(int rank, FundRanking fund) {
    final rankColors = [
      Colors.amber[700]!,
      Colors.grey[400]!,
      Colors.orange[700]!,
      Colors.blue[400]!,
      Colors.green[400]!,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: rankColors[rank - 1],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.fundName,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fund.category,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${FormatUtils.formatAmount(fund.currentValue)}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Retirado',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChartCard(List<BalanceHistory> balanceHistory) {
    return Builder(
      builder: (context) => Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 20.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Evolución del Saldo Disponible',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                'Saldo disponible para inversiones a lo largo del tiempo',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.0),
              if (balanceHistory.isNotEmpty) ...[
                SizedBox(
                  height: 200.0,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60.0,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(0)}K',
                                style: TextStyle(fontSize: 10.0),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30.0,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < balanceHistory.length) {
                                final date = balanceHistory[value.toInt()].date;
                                return Text(
                                  '${date.month}/${date.day}',
                                  style: TextStyle(fontSize: 10.0),
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
                      lineBarsData: [
                        LineChartBarData(
                          spots: balanceHistory.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.balance);
                          }).toList(),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.white,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: EdgeInsets.all(8.0),
                          tooltipMargin: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              final index = touchedSpot.x.toInt();
                              if (index >= 0 && index < balanceHistory.length) {
                                final history = balanceHistory[index];
                                final change = history.change;
                                final changeText = change > 0 
                                    ? '+${FormatUtils.formatAmount(change)}'
                                    : change < 0 
                                        ? '-${FormatUtils.formatAmount(change.abs())}'
                                        : 'Sin cambios';
                                final changeColor = change > 0 
                                    ? Colors.green 
                                    : change < 0 
                                        ? Colors.red 
                                        : Colors.grey;
                                
                                return LineTooltipItem(
                                  '${history.date.day}/${history.date.month}/${history.date.year}\n',
                                  TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Saldo: \$${FormatUtils.formatAmount(history.balance)}\n',
                                      style: TextStyle(
                                        fontSize: 11.0,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Cambio: $changeText',
                                      style: TextStyle(
                                        fontSize: 11.0,
                                        color: changeColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return null;
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                // Leyenda de la gráfica
                Row(
                  children: [
                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Saldo disponible',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Puntos: ${balanceHistory.length}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48.0,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'No hay datos para mostrar',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Realiza transacciones para ver la evolución',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<ActivityItem> activities) {
    final hasRealActivity = activities.any((activity) => 
      activity.title != 'Fondo de Renta Fija'
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasRealActivity ? 'Actividad Reciente' : 'Fondo Recomendado',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: activities.map((activity) {
                return Column(
                  children: [
                    _buildActivityItem(
                      activity.title,
                      activity.subtitle,
                      activity.time,
                      FormatUtils.getActivityIcon(activity.type.name),
                      FormatUtils.getActivityColor(activity.type.name),
                    ),
                    if (activity != activities.last) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    final isRecommendedFund = title == 'Fondo de Renta Fija';
    
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    size: 18.0,
                    color: color,
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (isRecommendedFund) ...[
              SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AppBloc>().add(const AppNavigateTo(AppRoute.funds));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      child: Text(
                        'Ver Detalles',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
