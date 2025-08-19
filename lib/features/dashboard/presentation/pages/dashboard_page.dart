import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/responsive_widget.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/blocs/app_bloc.dart';
import '../blocs/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(const DashboardStarted()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return AppScaffold(
          title: 'Dashboard',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<DashboardBloc>().add(const DashboardRefresh()),
              tooltip: 'Actualizar',
            ),
          ],
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
              '\$${FormatUtils.formatAmount(stats.totalFunds)}',
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
                      FormatUtils.getActivityIcon(activity.type.name),
                      FormatUtils.getActivityColor(activity.type.name),
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
}
