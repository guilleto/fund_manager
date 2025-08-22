import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fund_manager/core/blocs/app_bloc.dart';
import 'package:fund_manager/core/blocs/theme_bloc.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/features/funds/domain/models/user.dart';

class UserHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const UserHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UserHeaderState extends State<UserHeader> {
  bool _isInfoVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppLoaded) {
              final user = state.currentUser;
              final userFunds = state.userFunds;
              
              if (user == null) {
                return _buildBasicHeader();
              }

              return _buildUserHeader(user, userFunds);
            }
            return _buildBasicHeader();
          },
        );
      },
    );
  }

  Widget _buildBasicHeader() {
    return AppBar(
      title: Center(
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Colors.white,
      actions: widget.actions,
    );
  }

  Widget _buildUserHeader(User user, List<dynamic> userFunds) {
    // Calcular capital en fondos
    final totalInvested = userFunds.fold<double>(
      0.0, 
      (sum, fund) => sum + (fund.investedAmount ?? 0.0)
    );

    // Obtener primer nombre
    final firstName = user.name.split(' ').first;

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      leading: _buildSidebar(),
      title: Center(
        child: Column(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hola, $firstName',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      actions: [
        _buildUserChip(user.balance, totalInvested),
        if (widget.actions != null) ...widget.actions!,
      ],
    );
  }

  Widget _buildSidebar() {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        tooltip: 'Menú de navegación',
      ),
    );
  }

  Widget _buildUserChip(double balance, double totalInvested) {
    return Container(
      margin: EdgeInsets.only(right: 8.0),
      child: PopupMenuButton<String>(
        offset: Offset(0, 50.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12.0,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16.0,
                color: Colors.white70,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'balance',
            child: _buildChipItem(
              'Saldo',
              _isInfoVisible 
                  ? '\$${FormatUtils.formatAmount(balance)}'
                  : '\$****',
              Icons.account_balance_wallet,
            ),
          ),
          if (totalInvested > 0)
            PopupMenuItem(
              value: 'invested',
              child: _buildChipItem(
                'Invertido',
                _isInfoVisible 
                    ? '\$${FormatUtils.formatAmount(totalInvested)}'
                    : '\$****',
                Icons.trending_up,
                color: Colors.green,
              ),
            ),
          PopupMenuItem(
            value: 'toggle',
            child: _buildChipItem(
              _isInfoVisible ? 'Ocultar montos' : 'Mostrar montos',
              '',
              _isInfoVisible ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'toggle') {
            setState(() {
              _isInfoVisible = !_isInfoVisible;
            });
          }
        },
      ),
    );
  }

  Widget _buildChipItem(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.0,
          color: color ?? Colors.grey[600],
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
