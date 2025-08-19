import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';

class FundCard extends StatelessWidget {
  final Fund fund;
  final UserFund? userFund;
  final VoidCallback? onSubscribe;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  final bool showActions;

  const FundCard({
    super.key,
    required this.fund,
    this.userFund,
    this.onSubscribe,
    this.onCancel,
    this.onViewDetails,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscribed = userFund != null && userFund!.isActive;

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
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: FormatUtils.getCategoryColor(fund.category)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: FormatUtils.getCategoryColor(fund.category)
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        fund.category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: FormatUtils.getCategoryColor(fund.category),
                        ),
                      ),
                    ),
                    if (isSubscribed) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Suscrito',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildFundDetail('Monto Mínimo',
                      '\$${FormatUtils.formatAmountInt(fund.minAmount)}'),
                ),
                Expanded(
                  child: _buildFundDetail('Riesgo', fund.risk),
                ),
                Expanded(
                  child: _buildFundDetail(
                      'Estado', isSubscribed ? 'Suscrito' : fund.status),
                ),
              ],
            ),
            if (isSubscribed && userFund != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inversión Actual',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${FormatUtils.formatAmount(userFund!.investedAmount)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showActions) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Ver Detalles',
                      onPressed: onViewDetails ??
                          () {
                            context.read<AppBloc>().add(AppNavigateTo(
                                AppRoute.fundDetails,
                                arguments: {'fund': fund}));
                          },
                      type: ButtonType.outline,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomButton(
                      text: isSubscribed ? 'Cancelar' : 'Suscribirse',
                      onPressed: isSubscribed
                          ? (onCancel ?? () => _showCancelDialog(context))
                          : (onSubscribe ??
                              () => _showSubscribeDialog(context)),
                      type:
                          isSubscribed ? ButtonType.danger : ButtonType.primary,
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

  void _showSubscribeDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    amountController.text = fund.minAmount.toString();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppLoaded) {
            if (!state.isLoading) {
              // Proceso completado
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              } else {
                // Éxito en la suscripción
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Suscripción exitosa a ${fund.name}!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Ver Mis Fondos',
                      textColor: Colors.white,
                      onPressed: () {
                        context
                            .read<AppBloc>()
                            .add(const AppNavigateTo(AppRoute.myFunds));
                      },
                    ),
                  ),
                );
              }
            }
          }
        },
        child: AlertDialog(
          title: Text('Suscribirse a ${fund.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monto mínimo: \$${fund.minAmount.toStringAsFixed(0)}'),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto a invertir',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                final isLoading = state is AppLoaded && state.isLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Por favor, ingresa un monto válido'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (amount < fund.minAmount) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'El monto debe ser al menos \$${fund.minAmount.toStringAsFixed(0)}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          context.read<AppBloc>().add(AppSubscribeToFund(
                                fund: fund,
                                amount: amount,
                              ));
                        },
                  child: Text(isLoading ? 'Procesando...' : 'Confirmar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppLoaded) {
            if (!state.isLoading) {
              // Proceso completado
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              } else {
                // Éxito en la cancelación
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Suscripción cancelada exitosamente'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          }
        },
        child: AlertDialog(
          title: Text('Cancelar Suscripción'),
          content: Text(
            '¿Estás seguro de que quieres cancelar tu suscripción a ${fund.name}? '
            'Se te reembolsará el monto invertido de \$${FormatUtils.formatAmount(userFund?.investedAmount ?? 0)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No, mantener'),
            ),
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                final isLoading = state is AppLoaded && state.isLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (userFund != null) {
                            context
                                .read<AppBloc>()
                                .add(AppCancelFund(userFund!));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isLoading ? 'Procesando...' : 'Sí, cancelar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
