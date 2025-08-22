import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/loading_overlay.dart';
import 'package:fund_manager/core/widgets/auto_refresh_widget.dart';
import 'package:fund_manager/core/widgets/app_scaffold.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';

class MyFundsPage extends StatelessWidget {
  const MyFundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyFundsView();
  }
}

class MyFundsView extends StatefulWidget {
  const MyFundsView({super.key});

  @override
  State<MyFundsView> createState() => _MyFundsViewState();
}

class _MyFundsViewState extends State<MyFundsView> {
  @override
  void initState() {
    super.initState();
    // Actualizar datos al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBloc>().add(const AppRefreshData());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppLoaded) {
          return AutoRefreshWidget(
            child: AppScaffold(
              title: 'Mis Fondos',
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Actualizado cada minuto',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<AppBloc>().add(const AppRefreshData());
                  },
                  tooltip: 'Actualizar',
                ),
              ],
              body: LoadingOverlay(
                isLoading: state.isLoading,
                message: state.isLoading ? 'Procesando...' : null,
                child: ResponsiveWidget(
                  mobile: _buildMobileLayout(context, state),
                  tablet: _buildTabletLayout(context, state),
                  desktop: _buildDesktopLayout(context, state),
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildUserInfoCard(state.currentUser),
          const SizedBox(height: 24.0),
          _buildFundsList(context, state),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildUserInfoCard(state.currentUser),
          const SizedBox(height: 24.0),
          Expanded(
            child: _buildFundsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          _buildUserInfoCard(state.currentUser),
          const SizedBox(height: 32.0),
          Expanded(
            child: _buildFundsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(User? user) {
    if (user == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${user.name}',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14.0,
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
                      'Saldo Disponible',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      FormatUtils.formatCurrency(user.balance),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundsList(BuildContext context, AppLoaded state) {
    final userFunds = state.userFunds;

    if (userFunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16.0),
            Text(
              'No tienes fondos suscritos',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Explora los fondos disponibles para comenzar a invertir',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            CustomButton(
              text: 'Ver Fondos',
              onPressed: () {
                context.read<AppBloc>().add(const AppNavigateTo(AppRoute.funds));
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Fondos (${userFunds.length})',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButton(
              text: 'Ver Todos los Fondos',
              onPressed: () {
                context.read<AppBloc>().add(const AppNavigateTo(AppRoute.funds));
              },
              type: ButtonType.outline,
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        ResponsiveWidget(
          mobile: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userFunds.length,
          itemBuilder: (context, index) {
            final userFund = userFunds[index];
            return _buildUserFundCard(context, userFund);
          },
        ),
        tablet: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userFunds.length,
          itemBuilder: (context, index) {
            final userFund = userFunds[index];
            return _buildUserFundCard(context, userFund);
          },
        ),
        desktop: Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userFunds.length,
            itemBuilder: (context, index) {
              final userFund = userFunds[index];
              return _buildUserFundCard(context, userFund);
            },
          ),
        ),
        )
        
      ],
    );
  }

  Widget _buildUserFundCard(BuildContext context, UserFund userFund) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userFund.fundName,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: FormatUtils.getCategoryColor(userFund.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FormatUtils.getCategoryColor(userFund.category).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          userFund.category,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: FormatUtils.getCategoryColor(userFund.category),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Valor Actual',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      FormatUtils.formatCurrency(userFund.currentValue),
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildFundStat(
                    'Invertido',
                    FormatUtils.formatCurrency(userFund.investedAmount),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Rendimiento Fijo',
                    '${userFund.fixedPerformance.toStringAsFixed(2)}% por min',
                    Icons.trending_up,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Rendimiento Actual',
                    '${userFund.getCurrentPerformance() >= 0 ? '+' : ''}${userFund.getCurrentPerformance().toStringAsFixed(2)}%',
                    Icons.analytics,
                    color: userFund.getCurrentPerformance() >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: _buildFundStat(
                    'Ganancias',
                    '${userFund.getTotalGains() >= 0 ? '+' : ''}${FormatUtils.formatCurrency(userFund.getTotalGains())}',
                    Icons.monetization_on,
                    color: userFund.getTotalGains() >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Fecha',
                    FormatUtils.formatDate(userFund.subscriptionDate),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Tiempo',
                    _getTimeElapsed(userFund.subscriptionDate),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    onPressed: () {
                      _showCancelDialog(context, userFund);
                    },
                    type: ButtonType.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 20.0, color: color ?? Colors.grey[600]),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getTimeElapsed(DateTime subscriptionDate) {
    final now = DateTime.now();
    final duration = now.difference(subscriptionDate);
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _showCancelDialog(BuildContext context, UserFund userFund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Fondo'),
        content: Text(
          '¿Estás seguro de que quieres cancelar tu suscripción al fondo "${userFund.fundName}"? '
          'Se te devolverá el valor actual de \$${userFund.currentValue.toStringAsFixed(0)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(AppCancelFund(userFund));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}
