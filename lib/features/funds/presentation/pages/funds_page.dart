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

class FundsPage extends StatelessWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FundsView();
  }
}

class FundsView extends StatefulWidget {
  const FundsView({super.key});

  @override
  State<FundsView> createState() => _FundsViewState();
}

class _FundsViewState extends State<FundsView> {
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
                  refreshInterval: const Duration(minutes: 5),
                  child: AppScaffold(
                    title: 'Fondos Disponibles',
                    actions: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: Colors.green[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                                                   Text(
                           'Fondos por minuto',
                           style: TextStyle(
                             fontSize: 12.sp,
                             color: Colors.green[600],
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                          SizedBox(width: 8.w),
                        ],
                      ),
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
          items: const [
            DropdownMenuItem(value: null, child: Text('Todas las categorías')),
            DropdownMenuItem(value: 'FPV', child: Text('FPV')),
            DropdownMenuItem(value: 'FIC', child: Text('FIC')),
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
          items: const [
            DropdownMenuItem(value: null, child: Text('Todos los riesgos')),
            DropdownMenuItem(value: 'Bajo', child: Text('Bajo')),
            DropdownMenuItem(value: 'Medio', child: Text('Medio')),
            DropdownMenuItem(value: 'Medio-Alto', child: Text('Medio-Alto')),
            DropdownMenuItem(value: 'Alto', child: Text('Alto')),
          ],
          onChanged: (value) {
            context.read<FundsBloc>().add(FundsFilterByRisk(risk: value));
          },
        ),
      ],
    );
  }

  Widget _buildMinAmountFilter(BuildContext context, FundsLoaded state) {
    // Calcular el rango de montos disponibles
    final allFunds = state.allFunds;
    final minAmount = allFunds.map((f) => f.minAmount).reduce((a, b) => a < b ? a : b);
    final maxAmount = allFunds.map((f) => f.minAmount).reduce((a, b) => a > b ? a : b);
    
    // Usar el rango actual o crear uno por defecto
    final currentRange = state.filters.amountRange ?? RangeValues(
      minAmount.toDouble(), 
      maxAmount.toDouble()
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de monto mínimo',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        RangeSlider(
          values: currentRange,
          min: minAmount.toDouble(),
          max: maxAmount.toDouble(),
          divisions: 10,
          labels: RangeLabels(
            FormatUtils.formatCurrencyInt(currentRange.start.toInt()),
            FormatUtils.formatCurrencyInt(currentRange.end.toInt()),
          ),
          onChanged: (RangeValues values) {
            context.read<FundsBloc>().add(FundsFilterByAmountRange(amountRange: values));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Desde: ${FormatUtils.formatCurrencyInt(currentRange.start.toInt())}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            Text(
              'Hasta: ${FormatUtils.formatCurrencyInt(currentRange.end.toInt())}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
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
                FormatUtils.formatCurrencyInt(state.summary.totalMinAmount.toInt()),
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

  
}
