import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_bloc.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (context) => AppBloc()..add(const AppStarted()),
      child: child,
    );
  }
}
