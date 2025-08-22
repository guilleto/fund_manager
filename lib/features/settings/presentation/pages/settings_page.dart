import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/widgets/app_scaffold.dart';
import 'package:fund_manager/core/widgets/custom_button.dart';
import 'package:fund_manager/core/widgets/custom_text_field.dart';
import 'package:fund_manager/core/widgets/loading_overlay.dart';
import 'package:fund_manager/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:fund_manager/core/blocs/theme_bloc.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/navigation/app_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoadUser());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Configuración',
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            _nameController.text = state.user.name;
            _emailController.text = state.user.email;
            _phoneController.text = state.user.phone ?? '';
            _isDarkMode = state.isDarkMode;
          } else if (state is SettingsSaved) {
            // Actualizar el tema global cuando se guarda
            if (state.shouldUpdateTheme) {
              context.read<ThemeBloc>().add(ThemeUpdate(state.isDarkMode));
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuración guardada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Redirigir al dashboard después de guardar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AppBloc>().add(const AppNavigateTo(AppRoute.dashboard));
            });
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.0,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Error al cargar configuración',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  CustomButton(
                    onPressed: () {
                      context.read<SettingsBloc>().add(const SettingsLoadUser());
                    },
                    text: 'Reintentar',
                  ),
                ],
              ),
            );
          }

          if (state is SettingsLoaded || state is SettingsSaving) {
            return LoadingOverlay(
              isLoading: state is SettingsSaving,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Información Personal'),
                      SizedBox(height: 16.0),
                      _buildNameField(state),
                      SizedBox(height: 16.0),
                      _buildEmailField(state),
                      SizedBox(height: 16.0),
                      _buildPhoneField(state),
                      SizedBox(height: 32.0),
                      _buildSectionHeader('Preferencias'),
                      SizedBox(height: 16.0),
                      _buildThemeToggle(),
                      SizedBox(height: 32.0),
                      _buildSaveButton(state),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildNameField(SettingsState state) {
    final validationError = state is SettingsLoaded ? state.validationErrors['name'] : null;
    
    return CustomTextField(
      controller: _nameController,
      label: 'Nombre completo',
      hint: 'Ingrese su nombre completo',
      prefixIcon: Icon(Icons.person),
      validator: (value) => validationError,
      onChanged: (value) {
        if (state is SettingsLoaded) {
          // Marcar que hay cambios en el formulario
          final hasFormChanges = value != state.user.name || 
                                _emailController.text != state.user.email ||
                                _phoneController.text != (state.user.phone ?? '');
          
          if (hasFormChanges) {
            context.read<SettingsBloc>().add(const SettingsFieldChanged());
          } else {
            context.read<SettingsBloc>().add(const SettingsResetForm());
          }
        }
      },
    );
  }

  Widget _buildEmailField(SettingsState state) {
    final validationError = state is SettingsLoaded ? state.validationErrors['email'] : null;
    
    return CustomTextField(
      controller: _emailController,
      label: 'Correo electrónico',
      hint: 'ejemplo@correo.com',
      prefixIcon: Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
      validator: (value) => validationError,
      onChanged: (value) {
        if (state is SettingsLoaded) {
          // Marcar que hay cambios en el formulario
          final hasFormChanges = _nameController.text != state.user.name || 
                                value != state.user.email ||
                                _phoneController.text != (state.user.phone ?? '');
          
          if (hasFormChanges) {
            context.read<SettingsBloc>().add(const SettingsFieldChanged());
          } else {
            context.read<SettingsBloc>().add(const SettingsResetForm());
          }
        }
      },
    );
  }

  Widget _buildPhoneField(SettingsState state) {
    final validationError = state is SettingsLoaded ? state.validationErrors['phone'] : null;
    
    return CustomTextField(
      controller: _phoneController,
      label: 'Número de teléfono',
      hint: '+57 300 123 4567',
      prefixIcon: Icon(Icons.phone),
      keyboardType: TextInputType.phone,
      validator: (value) => validationError,
      onChanged: (value) {
        if (state is SettingsLoaded) {
          // Marcar que hay cambios en el formulario
          final hasFormChanges = _nameController.text != state.user.name || 
                                _emailController.text != state.user.email ||
                                value != (state.user.phone ?? '');
          
          if (hasFormChanges) {
            context.read<SettingsBloc>().add(const SettingsFieldChanged());
          } else {
            context.read<SettingsBloc>().add(const SettingsResetForm());
          }
        }
      },
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            _isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).primaryColor,
            size: 24.0,
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo oscuro',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _isDarkMode ? 'Activado' : 'Desactivado',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              context.read<SettingsBloc>().add(const SettingsToggleTheme());
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(SettingsState state) {
    if (state is! SettingsLoaded) {
      return const SizedBox.shrink();
    }
    
    final hasChanges = state.hasChanges;
    final hasValidationErrors = state.validationErrors.isNotEmpty;
    final hasFormChanges = _nameController.text != state.user.name || 
                          _emailController.text != state.user.email ||
                          _phoneController.text != (state.user.phone ?? '');
    
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: (hasChanges || hasFormChanges) && !hasValidationErrors
            ? _showSaveConfirmation
            : null,
        text: 'Guardar cambios',
        isLoading: state is SettingsSaving,
      ),
    );
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambios'),
        content: const Text(
          '¿Está seguro de que desea guardar los cambios en su configuración?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveSettings();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SettingsBloc>().add(
        SettingsUpdateUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          isDarkMode: _isDarkMode,
        ),
      );
    }
  }
}
