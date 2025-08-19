import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/features/funds/presentation/blocs/funds_bloc.dart';

class AutoRefreshWidget extends StatefulWidget {
  final Widget child;
  final Duration refreshInterval;
  final bool enabled;

  const AutoRefreshWidget({
    super.key,
    required this.child,
    this.refreshInterval = const Duration(seconds: 30),
    this.enabled = true,
  });

  @override
  State<AutoRefreshWidget> createState() => _AutoRefreshWidgetState();
}

class _AutoRefreshWidgetState extends State<AutoRefreshWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.refreshInterval, (timer) {
      if (mounted) {
        // Actualizar datos del AppBloc
        context.read<AppBloc>().add(const AppLoadUserData());
        
        // Actualizar datos del FundsBloc si está disponible
        try {
          context.read<FundsBloc>().add(const FundsRefresh());
        } catch (e) {
          // FundsBloc puede no estar disponible en todas las páginas
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
