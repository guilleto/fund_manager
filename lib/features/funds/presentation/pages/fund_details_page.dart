import 'package:flutter/material.dart';

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
  const FundDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FundDetailsView();
  }
}

class FundDetailsView extends StatefulWidget {
  const FundDetailsView({super.key});

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
    print('DEBUG: FundDetailsView initState');
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
    return BlocBuilder<FundsBloc, FundsState>(
      builder: (context, fundsState) {
        if (fundsState is! FundsLoaded || fundsState.selectedFund == null) {
          // Forzar navegación hacia atrás cuando no hay fondo seleccionado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('DEBUG: FundDetailsPage - No hay fondo seleccionado, navegando hacia atrás');
              context.read<AppBloc>().add(const AppNavigateTo(AppRoute.funds));
            }
          });
          
          return const AppScaffold(
            title: 'Detalles del Fondo',
            showDrawer: true,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Redirigiendo...'),
                ],
              ),
            ),
          );
        }

        final fund = fundsState.selectedFund!;

                return MultiBlocListener(
          listeners: [
            BlocListener<AppBloc, AppState>(
              listener: (context, state) {
                if (state is AppLoaded) {
                                // Verificar si el fondo seleccionado ya no está activo
              final selectedFundId = fund.id.toString();
              final userFund = state.userFunds
                  .where((uf) => uf.fundId == selectedFundId && uf.isActive)
                  .firstOrNull;
              
              print('DEBUG: FundDetailsPage - Verificando fondo $selectedFundId');
              print('DEBUG: FundDetailsPage - UserFund activo: ${userFund != null}');
              print('DEBUG: FundDetailsPage - Total userFunds: ${state.userFunds.length}');
              
              // Si el usuario estaba suscrito al fondo pero ya no está activo, navegar hacia atrás
              if (userFund == null) {
                // Buscar si había una suscripción previa que ya no existe
                final wasSubscribed = state.userFunds
                    .where((uf) => uf.fundId == selectedFundId)
                    .isNotEmpty;
                
                print('DEBUG: FundDetailsPage - ¿Había suscripción previa? $wasSubscribed');
                
                if (wasSubscribed) {
                      print('DEBUG: FundDetailsPage - Fondo cancelado, navegando hacia atrás');
                      // Guardar el AppBloc antes del async gap
                      final appBloc = context.read<AppBloc>();
                      
                      // Mostrar mensaje y navegar hacia atrás
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El fondo ha sido cancelado. Redirigiendo...'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      
                      // Navegar hacia atrás después de un breve delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          appBloc.add(const AppNavigateBack());
                        }
                      });
                      return;
                    }
                  }

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

                      // Limpiar formulario
                      _amountController.clear();
                    }
                  }
                }
              },
            ),
          ],
          child: AppScaffold(
            title: 'Detalles del Fondo',
            showDrawer: true,
            body: ResponsiveWidget(
              mobile: _buildMobileLayout(fund),
              tablet: _buildTabletDesktopLayout(fund),
              desktop: _buildTabletDesktopLayout(fund),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(Fund fund) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        if (appState is AppLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFundCard(context, appState.currentUser, fund),
                SizedBox(height: 24.0),
                _buildSubscriptionForm(context, appState.currentUser, fund),
                if (appState.errorMessage != null) ...[
                  SizedBox(height: 16.0),
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

  Widget _buildTabletDesktopLayout(Fund fund) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        if (appState is AppLoaded) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.0),
                  child: _buildFundCard(context, appState.currentUser, fund),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(24.0),
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
                      SizedBox(height: 24.0),
                      _buildSubscriptionForm(context, appState.currentUser, fund),
                      if (appState.errorMessage != null) ...[
                        SizedBox(height: 16.0),
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

  Widget _buildFundCard(BuildContext context, User? currentUser, Fund fund) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: FormatUtils.getCategoryColor(fund.category),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        fund.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            _buildInfoRow('Categoría', fund.category),
            _buildInfoRow('Riesgo', fund.risk),
            _buildInfoRow('Estado', fund.status),
            _buildInfoRow('Monto Mínimo',
                FormatUtils.formatAmountInt(fund.minAmount)),
            _buildInfoRow('Rendimiento',
                '${fund.performance.toStringAsFixed(2)}% por minuto'),
            if (currentUser != null) ...[
              SizedBox(height: 16.0),
              Divider(),
              SizedBox(height: 16.0),
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionForm(BuildContext context, User? currentUser, Fund fund) {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suscribirse al Fondo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20.0),
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
                  if (amount! < fund.minAmount) {
                    return 'El monto mínimo es ${FormatUtils.formatAmountInt(fund.minAmount)}';
                  }

                  if (amount > currentUser.balance) {
                    return 'Saldo insuficiente. Saldo disponible: ${FormatUtils.formatAmount(currentUser.balance)}';
                  }

                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Método de notificación',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12.0),
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
              SizedBox(height: 24.0),
              CustomButton(
                text: _isSubscribing ? 'Procesando...' : 'Suscribirse',
                onPressed:
                    _isSubscribing ? null : () => _handleSubscription(context, fund),
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
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          SizedBox(width: 12.0),
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

  void _handleSubscription(BuildContext context, Fund fund) {
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
    if (amount < fund.minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'El monto mínimo para este fondo es \$${fund.minAmount.toStringAsFixed(0)}'),
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
          fund: fund,
          amount: amount,
        ));

    // El estado _isSubscribing se manejará en el BlocListener
  }
}
