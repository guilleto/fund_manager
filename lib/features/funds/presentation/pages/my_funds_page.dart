import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/services/user_funds_service.dart';
import 'package:fund_manager/features/funds/domain/services/notification_service.dart';

class MyFundsPage extends StatelessWidget {
  const MyFundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final notificationService = MockNotificationService();
        final userFundsService = MockUserFundsService(notificationService);
        return FundsBloc(userFundsService);
      },
      child: const MyFundsView(),
    );
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
    // Cargar datos del usuario y sus fondos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FundsBloc>().add(const FundsLoadUserData());
      context.read<FundsBloc>().add(const FundsLoadUserFunds());
      context.read<FundsBloc>().add(const FundsLoadTransactionHistory());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FundsBloc, FundsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mis Fondos'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<FundsBloc>().add(const FundsRefresh());
                },
                tooltip: 'Actualizar',
              ),
              IconButton(
                icon: const Icon(Icons.account_balance),
                onPressed: () {
                  context
                      .read<AppBloc>()
                      .add(const AppNavigateTo(AppRoute.funds));
                },
                tooltip: 'Ver Fondos Disponibles',
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => _showTransactionHistory(context),
                tooltip: 'Historial de Transacciones',
              ),
            ],
          ),
          body: state is FundsLoading
              ? const Center(child: CircularProgressIndicator())
              : state is FundsLoaded
                  ? _buildContent(context, state)
                  : state is FundsError
                      ? Center(child: Text('Error: ${state.message}'))
                      : const Center(child: Text('Cargando...')),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FundsLoaded state) {
    return ResponsiveWidget(
      mobile: _buildMobileLayout(context, state),
      tablet: _buildTabletLayout(context, state),
      desktop: _buildDesktopLayout(context, state),
    );
  }

  Widget _buildMobileLayout(BuildContext context, FundsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(context, state.currentUser),
          ResponsiveSpacing(mobileSpacing: 16.h),
          _buildBalanceCard(context, state.currentUser),
          ResponsiveSpacing(mobileSpacing: 16.h),
          _buildUserFundsList(context, state.userFunds),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, FundsLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(context, state.currentUser),
                ResponsiveSpacing(tabletSpacing: 24.h),
                _buildBalanceCard(context, state.currentUser),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildUserFundsList(context, state.userFunds),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, FundsLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(context, state.currentUser),
                ResponsiveSpacing(desktopSpacing: 32.h),
                _buildBalanceCard(context, state.currentUser),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildUserFundsList(context, state.userFunds),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, User? user) {
    if (user == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.name.split(' ').map((e) => e[0]).join(''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.notifications, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  'Notificaciones: ${user.notificationPreference.displayName}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, User? user) {
    if (user == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Disponible',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '\$${user.balance.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserFundsList(BuildContext context, List<UserFund> userFunds) {
    if (userFunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No tienes fondos suscritos',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Suscríbete a un fondo para comenzar a invertir',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Ver Fondos Disponibles',
              onPressed: () {
                context
                    .read<AppBloc>()
                    .add(const AppNavigateTo(AppRoute.funds));
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: userFunds.length,
      itemBuilder: (context, index) {
        final userFund = userFunds[index];
        return _buildUserFundCard(context, userFund);
      },
    );
  }

  Widget _buildUserFundCard(BuildContext context, UserFund userFund) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userFund.fundName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:
                              FormatUtils.getCategoryColor(userFund.category),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          userFund.category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _showCancelFundDialog(context, userFund),
                  tooltip: 'Cancelar Fondo',
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildFundStat(
                    'Monto Invertido',
                    '\$${userFund.investedAmount.toStringAsFixed(0)}',
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Valor Actual',
                    '\$${userFund.currentValue.toStringAsFixed(0)}',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Rendimiento',
                    '${userFund.performance.toStringAsFixed(2)}%',
                    Icons.analytics,
                    color:
                        userFund.performance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Suscrito el ${FormatUtils.formatDate(userFund.subscriptionDate)}',
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

  Widget _buildFundStat(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: color ?? Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showCancelFundDialog(BuildContext context, UserFund userFund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Fondo'),
        content: Text(
          '¿Estás seguro de que quieres cancelar tu participación en "${userFund.fundName}"?\n\n'
          'Recibirás \$${userFund.currentValue.toStringAsFixed(0)} en tu saldo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FundsBloc>().add(FundsCancelFund(userFund));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Historial de Transacciones',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: BlocBuilder<FundsBloc, FundsState>(
                  builder: (context, state) {
                    if (state is FundsLoaded) {
                      if (state.transactionHistory.isEmpty) {
                        return const Center(
                          child: Text('No hay transacciones para mostrar'),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.transactionHistory.length,
                        itemBuilder: (context, index) {
                          final transaction = state.transactionHistory[index];
                          return _buildTransactionCard(transaction);
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(transaction) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.type == 'subscription' ? Colors.green : Colors.red,
          child: Icon(
            transaction.type == 'subscription' ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(transaction.fundName),
        subtitle: Text(
          '${transaction.type.displayName} - ${FormatUtils.formatDate(transaction.date)}',
        ),
        trailing: Text(
          '\$${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                transaction.type == 'subscription' ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
