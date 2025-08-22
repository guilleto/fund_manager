import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/responsive_service.dart';

import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/subscription_status_badge.dart';
import 'package:fund_manager/core/widgets/subscription_info_card.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';

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
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        // Obtener el userFund actualizado del AppBloc
        UserFund? currentUserFund;
        if (appState is AppLoaded) {
          currentUserFund = appState.userFunds
              .where((uf) => uf.fundId == fund.id.toString() && uf.isActive)
              .firstOrNull;
        }
        
        // Usar el userFund actualizado o el pasado como prop
        final effectiveUserFund = currentUserFund ?? userFund;
        final isSubscribed = effectiveUserFund != null && effectiveUserFund.isActive;

        return Card(
          margin: EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.0),
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
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            fund.type,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: FormatUtils.getCategoryColor(fund.category)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FormatUtils.getCategoryColor(fund.category)
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            fund.category,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: FormatUtils.getCategoryColor(fund.category),
                            ),
                          ),
                        ),
                        if (isSubscribed) ...[
                          SizedBox(height: 4.0),
                          SubscriptionStatusBadge(isSubscribed: isSubscribed),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
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
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildFundDetail('Rendimiento',
                          '${fund.performance.toStringAsFixed(2)}% por minuto'),
                    ),
                  ],
                ),
                if (isSubscribed && effectiveUserFund != null) ...[
                  SizedBox(height: 8.0),
                  SubscriptionInfoCard(effectiveUserFund: effectiveUserFund),
                ],
                if (showActions) ...[
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Ver Detalles',
                          onPressed: onViewDetails ??
                              () {
                                // Seleccionar el fondo en el FundsBloc
                                context.read<FundsBloc>().add(FundsSelectFund(fund: fund));
                                // Navegar a la página de detalles
                                context.read<AppBloc>().add(const AppNavigateTo(AppRoute.fundDetails));
                              },
                          type: ButtonType.outline,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: CustomButton(
                          text: isSubscribed ? 'Cancelar Suscripción' : 'Suscribirse',
                          onPressed: isSubscribed
                              ? (onCancel ?? () => _showCancelDialog(context, effectiveUserFund))
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
      },
    );
  }

  Widget _buildFundDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.0,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.0,
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
              SizedBox(height: 16.0),
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

  void _showCancelDialog(BuildContext context, UserFund? userFund) {
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
