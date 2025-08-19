import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/widgets/user_header.dart';
import 'package:fund_manager/core/widgets/navigation_sidebar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showDrawer;
  final bool showHeader;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showDrawer = true,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        // Si no hay usuario o estamos en welcome, mostrar scaffold básico
        if (state is! AppLoaded || 
            state.currentUser == null || 
            state.currentRoute == AppRoute.welcome) {
          return Scaffold(
            appBar: showHeader ? AppBar(
              title: Text(title),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: actions,
            ) : null,
            body: body,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: bottomNavigationBar,
          );
        }

        // Scaffold completo con header y sidebar
        return Scaffold(
          drawer: showDrawer ? const NavigationSidebar() : null,
          appBar: showHeader ? UserHeader(
            title: title,
            actions: actions,
          ) : null,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
        );
      },
    );
  }
}
