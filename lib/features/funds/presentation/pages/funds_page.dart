import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_widget.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/di/injection.dart';
import '../blocs/funds_bloc.dart';

class FundsPage extends StatelessWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FundsBloc>()..add(const FundsStarted()),
      child: BlocBuilder<FundsBloc, FundsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Fondos Disponibles'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<FundsBloc>().add(const FundsRefresh()),
                  tooltip: 'Actualizar',
                ),
                IconButton(
                  icon: const Icon(Icons.dashboard),
                  onPressed: () => AppRouter.goToDashboard(),
                  tooltip: 'Ir al Dashboard',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Aquí iría la lógica para filtrar fondos
                  },
                  tooltip: 'Filtrar Fondos',
                ),
              ],
            ),
            body: state is FundsLoading
                ? const Center(child: CircularProgressIndicator())
                : state is FundsLoaded
                    ? ResponsiveWidget(
                        mobile: _buildMobileLayout(context, state),
                        tablet: _buildTabletLayout(context, state),
                        desktop: _buildDesktopLayout(context, state),
                      )
                    : state is FundsError
                        ? Center(child: Text('Error: ${state.message}'))
                        : const Center(child: Text('Cargando...')),
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
                  child: _buildSummaryItem('Mín. Promedio', '\$${_formatAmount(summary.averageMinAmount)}'),
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
        Expanded(
          child: ListView.builder(
            itemCount: state.filteredFunds.length,
            itemBuilder: (context, index) {
              final fund = state.filteredFunds[index];
              return _buildFundCard(context, fund);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFundCard(BuildContext context, Fund fund) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                        fund.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        fund.type,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(fund.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getCategoryColor(fund.category).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        fund.category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(fund.category),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildFundDetail('Monto Mínimo', '\$${_formatAmount(fund.minAmount)}'),
                ),
                Expanded(
                  child: _buildFundDetail('Riesgo', fund.risk),
                ),
                Expanded(
                  child: _buildFundDetail('Estado', fund.status),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Ver Detalles',
                    onPressed: () {
                      context.read<FundsBloc>().add(FundsViewDetails(fund.id));
                    },
                    type: ButtonType.outline,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'Invertir',
                    onPressed: () {
                      context.read<FundsBloc>().add(FundsInvestInFund(fund.id));
                    },
                    type: ButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Método para obtener el color de la categoría
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FPV':
        return Colors.blue;
      case 'FIC':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Método para formatear montos
  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toString();
    }
  }


}
