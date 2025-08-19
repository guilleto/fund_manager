import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';

class SubscriptionInfoCard extends StatelessWidget {
  final UserFund userFund;

  const SubscriptionInfoCard({
    super.key,
    required this.userFund,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 16.sp,
                color: Colors.blue,
              ),
              SizedBox(width: 8.w),
              Text(
                'Tu Inversión',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Monto Invertido',
                  '\$${FormatUtils.formatAmount(userFund.investedAmount)}',
                  Colors.blue[700]!,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildInfoItem(
                  'Valor Actual',
                  '\$${FormatUtils.formatAmount(userFund.currentValue)}',
                  Colors.green[700]!,
                ),
              ),
            ],
          ),
          if (userFund.performance != 0) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  userFund.performance > 0 
                      ? Icons.trending_up 
                      : Icons.trending_down,
                  size: 14.sp,
                  color: userFund.performance > 0 ? Colors.green : Colors.red,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Rendimiento: ${userFund.performance > 0 ? '+' : ''}${userFund.performance.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: userFund.performance > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
