import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/fund_card.dart';
import 'package:fund_manager/core/widgets/loading_overlay.dart';
import 'package:fund_manager/core/widgets/auto_refresh_widget.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/services/user_funds_service.dart';
import 'package:fund_manager/features/funds/domain/services/notification_service.dart';

class FundsPage extends StatelessWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final notificationService = MockNotificationService();
        final userFundsService = MockUserFundsService(notificationService);
        return FundsBloc(userFundsService)..add(const FundsStarted());
      },
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
        builder: (context, state) {
          return AutoRefreshWidget(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Fondos Disponibles'),
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
                    icon: const Icon(Icons.dashboard),
                    onPressed: () {
                      context
                          .read<AppBloc>()
                          .add(const AppNavigateTo(AppRoute.dashboard));
                    },
                    tooltip: 'Ir al Dashboard',
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_balance_wallet),
                    onPressed: () {
                      context
                          .read<AppBloc>()
                          .add(const AppNavigateTo(AppRoute.myFunds));
                    },
                    tooltip: 'Mis Fondos',
                  ),
                ],
              ),
              body: state is FundsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is FundsLoaded
                      ? LoadingOverlay(
                          isLoading: state.isLoading,
                          message: state.isLoading ? 'Procesando...' : null,
                          child: ResponsiveWidget(
                            mobile: _buildMobileLayout(context, state),
                            tablet: _buildTabletLayout(context, state),
                            desktop: _buildDesktopLayout(context, state),
                          ),
                        )
                      : state is FundsError
                          ? Center(child: Text('Error: ${state.message}'))
                          : const Center(child: Text('Cargando...')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, FundsLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(state.summary),
          SizedBox(height: 24.h),
          _buildFiltersAndSorting(context, state),
          SizedBox(height: 16.h),
          _buildFundsList(context, state),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, FundsLoaded state) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _buildSummaryCard(state.summary),
          SizedBox(height: 24.h),
          _buildFiltersAndSorting(context, state),
          SizedBox(height: 16.h),
          Expanded(
            child: _buildFundsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, FundsLoaded state) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          _buildSummaryCard(state.summary),
          SizedBox(height: 32.h),
          _buildFiltersAndSorting(context, state),
          SizedBox(height: 16.h),
          Expanded(
            child: _buildFundsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(FundsSummary summary) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.w),
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
                        'Total Fondos',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${summary.totalFunds}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${summary.uniqueCategories}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('FPV', '${summary.fpvCount}'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryItem('FIC', '${summary.ficCount}'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryItem('Mín. Promedio',
                      '\$${FormatUtils.formatAmountInt(summary.averageMinAmount)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFundsList(BuildContext context, FundsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fondos Disponibles',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButton(
              text: 'Filtrar',
              onPressed: () {
                // Aquí iría la lógica para filtrar fondos
              },
              type: ButtonType.outline,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        BlocBuilder<AppBloc, AppState>(
          builder: (context, appState) {
            if (appState is AppLoaded) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.filteredFunds.length,
                itemBuilder: (context, index) {
                  final fund = state.filteredFunds[index];
                  final userFund = appState.userFunds
                      .where(
                        (uf) => uf.fundId == fund.id && uf.isActive,
                      )
                      .firstOrNull;
                  return FundCard(
                    fund: fund,
                    userFund: userFund,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFiltersAndSorting(BuildContext context, FundsLoaded state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Filtros y Ordenamiento',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (state.filters.hasFilters)
                  TextButton.icon(
                    onPressed: () {
                      context.read<FundsBloc>().add(const FundsClearFilters());
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar'),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            ResponsiveWidget(
              mobile: Column(
                children: [
                  _buildCategoryFilter(context, state),
                  SizedBox(height: 12.h),
                  _buildRiskFilter(context, state),
                  SizedBox(height: 12.h),
                  _buildSortingDropdown(context, state),
                ],
              ),
              tablet: Wrap(
                spacing: 12.w,
                runSpacing: 16.h,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: _buildCategoryFilter(context, state),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: _buildRiskFilter(context, state),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: _buildSortingDropdown(context, state),
                  ),
                ],
              ),
              desktop: Wrap(
                spacing: 12.w,
                runSpacing: 16.h,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: _buildCategoryFilter(context, state),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: _buildRiskFilter(context, state),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: _buildSortingDropdown(context, state),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildMinAmountFilter(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, FundsLoaded state) {
    final categories = ['FPV', 'FIC'];

    return DropdownButtonFormField<String>(
      value: state.filters.category,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Todas'),
        ),
        ...categories.map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            )),
      ],
      onChanged: (value) {
        context.read<FundsBloc>().add(FundsFilterByCategory(category: value));
      },
    );
  }

  Widget _buildRiskFilter(BuildContext context, FundsLoaded state) {
    final risks = ['Bajo', 'Medio', 'Medio-Alto', 'Alto'];

    return DropdownButtonFormField<String>(
      value: state.filters.risk,
      decoration: InputDecoration(
        labelText: 'Riesgo',
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Todos'),
        ),
        ...risks.map((risk) => DropdownMenuItem<String>(
              value: risk,
              child: Text(risk),
            )),
      ],
      onChanged: (value) {
        context.read<FundsBloc>().add(FundsFilterByRisk(risk: value));
      },
    );
  }

  Widget _buildMinAmountFilter(BuildContext context, FundsLoaded state) {
    // Obtener el rango de montos mínimos de todos los fondos
    final allFunds = state.allFunds;
    final minAmount = allFunds.isEmpty
        ? 0
        : allFunds.map((f) => f.minAmount).reduce((a, b) => a < b ? a : b);
    final maxAmount = allFunds.isEmpty
        ? 100000
        : allFunds.map((f) => f.minAmount).reduce((a, b) => a > b ? a : b);

    // Valor actual del filtro o el mínimo si no hay filtro
    final currentValue = state.filters.minAmount ?? minAmount;

    // Determinar si el filtro está activo (no es el valor mínimo)
    final isFilterActive =
        state.filters.minAmount != null && state.filters.minAmount! > minAmount;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 100.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monto Mínimo',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isFilterActive)
                TextButton(
                  onPressed: () {
                    context
                        .read<FundsBloc>()
                        .add(const FundsFilterByMinAmount(minAmount: null));
                  },
                  child: Text(
                    'Limpiar',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
              valueIndicatorColor: Theme.of(context).primaryColor,
              valueIndicatorTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: currentValue.toDouble(),
              min: minAmount.toDouble(),
              max: maxAmount.toDouble(),
              divisions: 10, // 10 divisiones para mejor control
              label: FormatUtils.formatAmountInt(currentValue),
              onChanged: (value) {
                context
                    .read<FundsBloc>()
                    .add(FundsFilterByMinAmount(minAmount: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatUtils.formatAmountInt(minAmount),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isFilterActive
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                        border: isFilterActive
                            ? Border.all(
                                color: Theme.of(context).primaryColor, width: 1)
                            : null,
                      ),
                      child: Text(
                        '${FormatUtils.formatAmountInt(currentValue)}+',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isFilterActive
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${state.filteredFunds.length} fondos',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isFilterActive
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                        fontWeight: isFilterActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Text(
                  FormatUtils.formatAmountInt(maxAmount),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortingDropdown(BuildContext context, FundsLoaded state) {
    return DropdownButtonFormField<String>(
      value: state.sortBy,
      decoration: InputDecoration(
        labelText: 'Ordenar por',
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        suffixIcon: Icon(
          state.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16.sp,
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value: 'name',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nombre'),
              if (state.sortBy == 'name') ...[
                SizedBox(width: 8.w),
                Icon(
                  state.sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14.sp,
                ),
              ],
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'minAmount',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Monto Mínimo'),
              if (state.sortBy == 'minAmount') ...[
                SizedBox(width: 8.w),
                Icon(
                  state.sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14.sp,
                ),
              ],
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'risk',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Riesgo'),
              if (state.sortBy == 'risk') ...[
                SizedBox(width: 8.w),
                Icon(
                  state.sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14.sp,
                ),
              ],
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          context.read<FundsBloc>().add(FundsSortBy(
                sortBy: value,
                ascending: state.sortBy == value ? !state.sortAscending : true,
              ));
        }
      },
    );
  }
}
