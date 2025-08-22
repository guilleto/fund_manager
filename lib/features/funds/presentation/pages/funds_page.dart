import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/fund_card.dart';
import 'package:fund_manager/core/widgets/loading_overlay.dart';
import 'package:fund_manager/core/widgets/auto_refresh_widget.dart';
import 'package:fund_manager/core/widgets/app_scaffold.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/core/services/user_service.dart';

class FundsPage extends StatelessWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FundsBloc(context.read<UserService>())..add(const FundsStarted()),
      child: const FundsView(),
    );
  }
}

class FundsView extends StatelessWidget {
  const FundsView({super.key});

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
                transactions: state.transactions,
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
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) {
          if (appState is AppLoaded) {
            return BlocBuilder<FundsBloc, FundsState>(
              builder: (context, fundsState) {
                return AutoRefreshWidget(
                  child: AppScaffold(
                    title: 'Fondos Disponibles',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          context.read<FundsBloc>().add(const FundsRefresh());
                          context.read<AppBloc>().add(const AppRefreshData());
                        },
                        tooltip: 'Actualizar',
                      ),
                    ],
                    body: fundsState is FundsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : fundsState is FundsLoaded
                            ? LoadingOverlay(
                                isLoading: appState.isLoading,
                                message: appState.isLoading ? 'Procesando...' : null,
                                child: ResponsiveWidget(
                                  mobile: _buildMobileLayout(context, fundsState, appState),
                                  tablet: _buildTabletLayout(context, fundsState, appState),
                                  desktop: _buildDesktopLayout(context, fundsState, appState),
                                ),
                              )
                            : const Center(child: Text('Error al cargar fondos')),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, FundsLoaded state, AppLoaded appState) {
    return Column(
      children: [
        _buildFiltersSection(context, state),
        Expanded(
          child: _buildFundsList(context, state, appState),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, FundsLoaded state, AppLoaded appState) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildFiltersSection(context, state),
        ),
        Expanded(
          flex: 2,
          child: _buildFundsList(context, state, appState),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, FundsLoaded state, AppLoaded appState) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildFiltersSection(context, state),
        ),
        Expanded(
          flex: 3,
          child: _buildFundsList(context, state, appState),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(BuildContext context, FundsLoaded state) {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildCategoryFilter(context, state),
            SizedBox(height: 12.h),
            _buildRiskFilter(context, state),
            SizedBox(height: 12.h),
            _buildMinAmountFilter(context, state),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      context.read<FundsBloc>().add(const FundsClearFilters());
                    },
                    text: 'Limpiar',
                    type: ButtonType.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, FundsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: state.filters.category,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('Todas las categorías'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas las categorías')),
            const DropdownMenuItem(value: 'FPV', child: Text('FPV')),
            const DropdownMenuItem(value: 'FIC', child: Text('FIC')),
          ],
          onChanged: (value) {
            context.read<FundsBloc>().add(FundsFilterByCategory(category: value));
          },
        ),
      ],
    );
  }

  Widget _buildRiskFilter(BuildContext context, FundsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riesgo',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: state.filters.risk,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('Todos los riesgos'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos los riesgos')),
            const DropdownMenuItem(value: 'Bajo', child: Text('Bajo')),
            const DropdownMenuItem(value: 'Medio', child: Text('Medio')),
            const DropdownMenuItem(value: 'Medio-Alto', child: Text('Medio-Alto')),
            const DropdownMenuItem(value: 'Alto', child: Text('Alto')),
          ],
          onChanged: (value) {
            context.read<FundsBloc>().add(FundsFilterByRisk(risk: value));
          },
        ),
      ],
    );
  }

  Widget _buildMinAmountFilter(BuildContext context, FundsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto mínimo',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<int>(
          value: state.filters.minAmount,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('Cualquier monto'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Cualquier monto')),
            const DropdownMenuItem(value: 50000, child: Text('\$50,000')),
            const DropdownMenuItem(value: 75000, child: Text('\$75,000')),
            const DropdownMenuItem(value: 100000, child: Text('\$100,000')),
            const DropdownMenuItem(value: 125000, child: Text('\$125,000')),
            const DropdownMenuItem(value: 250000, child: Text('\$250,000')),
          ],
          onChanged: (value) {
            context.read<FundsBloc>().add(FundsFilterByMinAmount(minAmount: value));
          },
        ),
      ],
    );
  }

  Widget _buildFundsList(BuildContext context, FundsLoaded state, AppLoaded appState) {
    return Column(
      children: [
        _buildSummarySection(context, state),
        Expanded(
          child: state.filteredFunds.isEmpty
              ? const Center(
                  child: Text('No se encontraron fondos con los filtros aplicados'),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.filteredFunds.length,
                  itemBuilder: (context, index) {
                    final fund = state.filteredFunds[index];
                    final isSubscribed = appState.userFunds.any(
                      (userFund) => userFund.fundId == fund.id.toString() && userFund.isActive,
                    );
                    
                    return FundCard(
                      fund: fund,
                      userFund: isSubscribed ? appState.userFunds.firstWhere(
                        (userFund) => userFund.fundId == fund.id.toString() && userFund.isActive,
                      ) : null,
                      onSubscribe: () {
                        // Mostrar diálogo para ingresar monto
                        _showSubscriptionDialog(context, fund);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, FundsLoaded state) {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Fondos',
                state.summary.totalFunds.toString(),
                Icons.account_balance,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'FPV',
                state.summary.fpvCount.toString(),
                Icons.pie_chart,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'FIC',
                state.summary.ficCount.toString(),
                Icons.trending_up,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Total Min.',
                FormatUtils.formatCurrency(state.summary.totalMinAmount),
                Icons.attach_money,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: Colors.blue),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showSubscriptionDialog(BuildContext context, Fund fund) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suscribirse a ${fund.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Monto mínimo: \$${fund.minAmount.toStringAsFixed(0)}'),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto a invertir',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount >= fund.minAmount) {
                context.read<AppBloc>().add(AppSubscribeToFund(
                  fund: fund,
                  amount: amount,
                ));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Suscribirse'),
          ),
        ],
      ),
    );
  }
}
