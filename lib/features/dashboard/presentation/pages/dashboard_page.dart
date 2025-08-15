import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/responsive_widget.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/di/injection.dart';
import '../blocs/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardBloc>()..add(const DashboardStarted()),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<DashboardBloc>().add(const DashboardRefresh()),
                  tooltip: 'Actualizar',
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance),
                  onPressed: () => AppRouter.goToFunds(),
                  tooltip: 'Ver Fondos',
                ),
              ],
            ),
            body: state is DashboardLoading
                ? const Center(child: CircularProgressIndicator())
                : state is DashboardLoaded
                    ? ResponsiveWidget(
                        mobile: _buildMobileLayout(context, state),
                        tablet: _buildTabletLayout(context, state),
                        desktop: _buildDesktopLayout(context, state),
                      )
                    : state is DashboardError
                        ? Center(child: Text('Error: ${state.message}'))
                        : const Center(child: Text('Cargando...')),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          SizedBox(height: 24.h),
          _buildStatsGrid(state.stats),
          SizedBox(height: 24.h),
          _buildRecentActivity(state.recentActivity),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _buildWelcomeCard(),
          SizedBox(height: 24.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildStatsGrid(state.stats),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  flex: 1,
                  child: _buildRecentActivity(state.recentActivity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          _buildWelcomeCard(),
          SizedBox(height: 32.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildStatsGrid(state.stats),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  flex: 1,
                  child: _buildRecentActivity(state.recentActivity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido de vuelta!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Aquí tienes un resumen de tus fondos y actividades recientes.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.8,
          children: [
            _buildStatCard(
              'Total de Fondos',
              '\$${_formatAmount(stats.totalFunds)}',
              Icons.account_balance,
              Colors.blue,
            ),
            _buildStatCard(
              'Rendimiento',
              '${stats.performance >= 0 ? '+' : ''}${stats.performance}%',
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Fondos Activos',
              '${stats.activeFunds}',
              Icons.check_circle,
              Colors.orange,
            ),
            _buildStatCard(
              'Transacciones',
              '${stats.totalTransactions}',
              Icons.receipt,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28.sp,
              color: color,
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<ActivityItem> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: activities.map((activity) {
                return Column(
                  children: [
                    _buildActivityItem(
                      activity.title,
                      activity.subtitle,
                      activity.time,
                      _getActivityIcon(activity.type),
                      _getActivityColor(activity.type),
                    ),
                    if (activity != activities.last) Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Método para formatear montos
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // Método para obtener el icono de la actividad
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.purchase:
        return Icons.shopping_cart;
      case ActivityType.sale:
        return Icons.sell;
      case ActivityType.dividend:
        return Icons.payments;
      case ActivityType.transfer:
        return Icons.swap_horiz;
    }
  }

  // Método para obtener el color de la actividad
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.purchase:
        return Colors.green;
      case ActivityType.sale:
        return Colors.red;
      case ActivityType.dividend:
        return Colors.blue;
      case ActivityType.transfer:
        return Colors.orange;
    }
  }
}
