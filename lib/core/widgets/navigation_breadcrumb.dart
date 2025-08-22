import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/navigation/app_router.dart';
import 'package:fund_manager/core/blocs/app_bloc.dart';

class NavigationBreadcrumb extends StatelessWidget {
  final AppRoute currentRoute;

  const NavigationBreadcrumb({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildBreadcrumbItem(
            context,
            'Bienvenida',
            Icons.home,
            AppRoute.welcome,
            isActive: currentRoute == AppRoute.welcome,
          ),
          _buildSeparator(context),
          _buildBreadcrumbItem(
            context,
            'Dashboard',
            Icons.dashboard,
            AppRoute.dashboard,
            isActive: currentRoute == AppRoute.dashboard,
          ),
          if (currentRoute == AppRoute.funds) ...[
            _buildSeparator(context),
            _buildBreadcrumbItem(
              context,
              'Fondos',
              Icons.account_balance,
              AppRoute.funds,
              isActive: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    String label,
    IconData icon,
    AppRoute route, {
    required bool isActive,
  }) {
    return InkWell(
      onTap: isActive ? null : () => _navigateToRoute(context, route),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
            ),
            SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        Icons.chevron_right,
        size: 16.0,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, AppRoute route) {
    context.read<AppBloc>().add(AppNavigateTo(route));
  }
}
