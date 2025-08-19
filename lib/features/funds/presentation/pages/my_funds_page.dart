import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/fund_card.dart';
import 'package:fund_manager/core/widgets/loading_overlay.dart';
import 'package:fund_manager/core/widgets/auto_refresh_widget.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
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
        return FundsBloc(userFundsService)..add(const FundsStarted());
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
    // Cargar datos de fondos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FundsBloc>().add(const FundsLoadUserFunds());
      context.read<FundsBloc>().add(const FundsLoadTransactionHistory());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppLoaded) {
              // Mostrar mensajes de error si existen
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              
              // Sincronizar datos con el FundsBloc
              context.read<FundsBloc>().add(FundsSyncWithAppBloc(
                currentUser: state.currentUser,
                userFunds: state.userFunds,
                transactions: state.transactionHistory,
              ));
            }
          },
        ),
        BlocListener<FundsBloc, FundsState>(
          listener: (context, state) {
            if (state is FundsLoaded && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      ],
              child: BlocBuilder<FundsBloc, FundsState>(
          builder: (context, fundsState) {
            return AutoRefreshWidget(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Mis Fondos'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<FundsBloc>().add(const FundsRefresh());
                        context.read<AppBloc>().add(const AppLoadUserData());
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
                body: BlocBuilder<AppBloc, AppState>(
                  builder: (context, appState) {
                    if (appState is AppLoaded) {
                      return LoadingOverlay(
                        isLoading: appState.isLoading || (fundsState is FundsLoaded && fundsState.isLoading),
                        message: (appState.isLoading || (fundsState is FundsLoaded && fundsState.isLoading)) 
                            ? 'Cargando fondos...' : null,
                        child: _buildContent(context, appState, fundsState),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            );
          },
        ),
    );
  }

  Widget _buildContent(BuildContext context, AppLoaded appState, FundsState fundsState) {
    return ResponsiveWidget(
      mobile: _buildMobileLayout(context, appState, fundsState),
      tablet: _buildTabletLayout(context, appState, fundsState),
      desktop: _buildDesktopLayout(context, appState, fundsState),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLoaded appState, FundsState fundsState) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(context, appState.currentUser),
          ResponsiveSpacing(mobileSpacing: 16.h),
          _buildBalanceCard(context, appState.currentUser),
          ResponsiveSpacing(mobileSpacing: 16.h),
          _buildUserFundsList(context, appState.userFunds, appState, fundsState),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppLoaded appState, FundsState fundsState) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(context, appState.currentUser),
                ResponsiveSpacing(tabletSpacing: 24.h),
                _buildBalanceCard(context, appState.currentUser),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: _buildUserFundsList(context, appState.userFunds, appState, fundsState),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLoaded appState, FundsState fundsState) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(context, appState.currentUser),
                ResponsiveSpacing(desktopSpacing: 32.h),
                _buildBalanceCard(context, appState.currentUser),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: _buildUserFundsList(context, appState.userFunds, appState, fundsState),
          ),
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

  Widget _buildUserFundsList(
      BuildContext context, List<UserFund> userFunds, AppLoaded appState, FundsState fundsState) {
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

    if (fundsState is FundsLoaded) {
      return Column(
        children: userFunds.map((userFund) {
          // Buscar el fondo completo en el estado
          final fund = fundsState.allFunds.firstWhere(
            (f) => f.id.toString() == userFund.fundId,
            orElse: () => Fund(
              id: int.tryParse(userFund.fundId) ?? 0,
              name: userFund.fundName,
              type: 'FIC',
              category: userFund.category,
              minAmount: userFund.investedAmount.round(),
              value: userFund.currentValue,
              performance: userFund.performance,
              risk: 'Medio',
              status: 'Activo',
            ),
          );
          return FundCard(
            fund: fund,
            userFund: userFund,
            showActions: true,
          );
        }).toList(),
      );
    }
    
    return const Center(child: CircularProgressIndicator());
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
