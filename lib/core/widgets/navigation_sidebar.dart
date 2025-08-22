import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/blocs/theme_bloc.dart';
import 'package:fund_manager/core/navigation/app_router.dart';

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Drawer(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildNavigationItems(context),
              ),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppLoaded && state.currentUser != null) {
          final user = state.currentUser!;
          final firstName = user.name.split(' ').first;
          
          return DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    firstName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  'Hola, $firstName',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }
        
        return DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                'Fund Manager',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildNavigationItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          subtitle: 'Panel principal',
          route: AppRoute.dashboard,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.account_balance,
          title: 'Fondos Disponibles',
          subtitle: 'Explorar fondos',
          route: AppRoute.funds,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Mis Fondos',
          subtitle: 'Mis inversiones',
          route: AppRoute.myFunds,
        ),
        Divider(height: 32.0),
        _buildNavigationItem(
          context,
          icon: Icons.history,
          title: 'Historial',
          subtitle: 'Transacciones',
          route: AppRoute.transactions,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.settings,
          title: 'Configuración',
          subtitle: 'Preferencias',
          route: AppRoute.settings,
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required AppRoute route,
    VoidCallback? onTap,
  }) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final isActive = state is AppLoaded && state.currentRoute == route;
        
        return ListTile(
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isActive 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: isActive 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 20.0,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive 
                  ? Theme.of(context).primaryColor
                  : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
          onTap: onTap ?? () {
            context.read<AppBloc>().add(AppNavigateTo(route));
            Navigator.of(context).pop(); // Cerrar drawer
          },
          selected: isActive,
          selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.05),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.0,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Fund Manager v1.0',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
