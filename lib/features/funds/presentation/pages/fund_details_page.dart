import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fund_manager/core/services/notification_service.dart';
import 'package:fund_manager/core/services/user_service.dart';

import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/custom_text_field.dart';
import 'package:fund_manager/core/widgets/responsive_widget.dart';
import 'package:fund_manager/core/widgets/app_scaffold.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/core/utils/validation_utils.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';

class FundDetailsPage extends StatelessWidget {
  final Fund fund;

  const FundDetailsPage({
    super.key,
    required this.fund,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FundsBloc(MockUserService(MockNotificationService()))
            ..add(const FundsStarted()),
      child: FundDetailsView(fund: fund),
    );
  }
}

class FundDetailsView extends StatefulWidget {
  final Fund fund;

  const FundDetailsView({
    super.key,
    required this.fund,
  });

  @override
  State<FundDetailsView> createState() => _FundDetailsViewState();
}

class _FundDetailsViewState extends State<FundDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  NotificationPreference _selectedNotificationPreference =
      NotificationPreference.email;
  bool _isSubscribing = false;

  @override
  void initState() {
    super.initState();
    // Los datos del usuario ya están cargados en AppBloc
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppLoaded) {
          // Manejar estado de carga
          if (state.isLoading && _isSubscribing) {
            // Mantener el estado de carga
          } else if (!state.isLoading && _isSubscribing) {
            // Proceso completado
            setState(() {
              _isSubscribing = false;
            });

            // Mostrar mensajes de error si existen
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else {
              // Éxito en la suscripción
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡Suscripción exitosa a ${widget.fund.name}!'),
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

              // Limpiar formulario
              _amountController.clear();
            }
          }
        }
      },
      child: AppScaffold(
        title: 'Detalles del Fondo',
        showDrawer: false, // No mostrar drawer en detalles
        body: ResponsiveWidget(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletDesktopLayout(),
          desktop: _buildTabletDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        if (appState is AppLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFundCard(context, appState.currentUser),
                SizedBox(height: 24.h),
                _buildSubscriptionForm(context, appState.currentUser),
                if (appState.errorMessage != null) ...[
                  SizedBox(height: 16.h),
                  _buildErrorMessage(appState.errorMessage!),
                ],
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTabletDesktopLayout() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        if (appState is AppLoaded) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: _buildFundCard(context, appState.currentUser),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suscribirse',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 24.h),
                      _buildSubscriptionForm(context, appState.currentUser),
                      if (appState.errorMessage != null) ...[
                        SizedBox(height: 16.h),
                        _buildErrorMessage(appState.errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFundCard(BuildContext context, User? currentUser) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: FormatUtils.getCategoryColor(widget.fund.category),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fund.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        widget.fund.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildInfoRow('Categoría', widget.fund.category),
            _buildInfoRow('Riesgo', widget.fund.risk),
            _buildInfoRow('Estado', widget.fund.status),
            _buildInfoRow('Monto Mínimo',
                FormatUtils.formatAmountInt(widget.fund.minAmount)),
            _buildInfoRow(
                'Valor Actual', FormatUtils.formatAmount(widget.fund.value)),
            _buildInfoRow('Rendimiento',
                '${widget.fund.performance.toStringAsFixed(2)}%'),
            if (currentUser != null) ...[
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              _buildInfoRow(
                  'Tu Saldo', FormatUtils.formatAmount(currentUser.balance)),
              _buildInfoRow('Preferencia de Notificación',
                  currentUser.notificationPreference.displayName),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionForm(BuildContext context, User? currentUser) {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suscribirse al Fondo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                controller: _amountController,
                label: 'Monto a invertir',
                hint: 'Ingrese el monto',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  final validation = ValidationUtils.validateAmount(value);
                  if (validation != null) return validation;

                  final amount = double.tryParse(value!);
                  if (amount! < widget.fund.minAmount) {
                    return 'El monto mínimo es ${FormatUtils.formatAmountInt(widget.fund.minAmount)}';
                  }

                  if (amount > currentUser.balance) {
                    return 'Saldo insuficiente. Saldo disponible: ${FormatUtils.formatAmount(currentUser.balance)}';
                  }

                  return null;
                },
              ),
              SizedBox(height: 20.h),
              Text(
                'Método de notificación',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12.h),
              ...NotificationPreference.values
                  .map((preference) => RadioListTile<NotificationPreference>(
                        title: Text(preference.displayName),
                        value: preference,
                        groupValue: _selectedNotificationPreference,
                        onChanged: (value) {
                          setState(() {
                            _selectedNotificationPreference = value!;
                          });
                        },
                      )),
              SizedBox(height: 24.h),
              CustomButton(
                text: _isSubscribing ? 'Procesando...' : 'Suscribirse',
                onPressed:
                    _isSubscribing ? null : () => _handleSubscription(context),
                type: ButtonType.primary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscription(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un monto válido'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validar monto mínimo
    if (amount < widget.fund.minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'El monto mínimo para este fondo es \$${widget.fund.minAmount.toStringAsFixed(0)}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubscribing = true;
    });

    // Actualizar preferencia de notificación si es necesario
    context
        .read<AppBloc>()
        .add(AppUpdateNotificationPreference(_selectedNotificationPreference));

    // Suscribirse al fondo
    context.read<AppBloc>().add(AppSubscribeToFund(
          fund: widget.fund,
          amount: amount,
        ));

    // El estado _isSubscribing se manejará en el BlocListener
  }
}
