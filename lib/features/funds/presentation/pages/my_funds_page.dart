import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/fund_card.dart';
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
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppLoaded) {
          return AutoRefreshWidget(
            child: AppScaffold(
              title: 'Mis Fondos',
              actions: [
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(state.currentUser),
          SizedBox(height: 24.h),
          _buildFundsList(context, state),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppLoaded state) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _buildUserInfoCard(state.currentUser),
          SizedBox(height: 24.h),
          Expanded(
            child: _buildFundsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLoaded state) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          _buildUserInfoCard(state.currentUser),
          SizedBox(height: 32.h),
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
                        'Hola, ${user.name}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Saldo Disponible',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      FormatUtils.formatCurrency(user.balance),
                      style: TextStyle(
                        fontSize: 24.sp,
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
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No tienes fondos suscritos',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Explora los fondos disponibles para comenzar a invertir',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Fondos (${userFunds.length})',
              style: TextStyle(
                fontSize: 20.sp,
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
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.builder(
            itemCount: userFunds.length,
            itemBuilder: (context, index) {
              final userFund = userFunds[index];
              return _buildUserFundCard(context, userFund);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserFundCard(BuildContext context, UserFund userFund) {
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
                        userFund.fundName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: FormatUtils.getCategoryColor(userFund.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: FormatUtils.getCategoryColor(userFund.category).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          userFund.category,
                          style: TextStyle(
                            fontSize: 12.sp,
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
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      FormatUtils.formatCurrency(userFund.currentValue),
                      style: TextStyle(
                        fontSize: 18.sp,
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
                  child: _buildFundStat(
                    'Invertido',
                    FormatUtils.formatCurrency(userFund.investedAmount),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Rendimiento',
                    '${userFund.performance >= 0 ? '+' : ''}${userFund.performance.toStringAsFixed(2)}%',
                    Icons.trending_up,
                    color: userFund.performance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildFundStat(
                    'Fecha',
                    FormatUtils.formatDate(userFund.subscriptionDate),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Ver Detalles',
                    onPressed: () {
                      // Navegar a detalles del fondo
                    },
                    type: ButtonType.outline,
                  ),
                ),
                SizedBox(width: 12.w),
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
        Icon(icon, size: 20.sp, color: color ?? Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
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
