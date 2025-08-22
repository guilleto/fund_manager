import 'package:flutter/material.dart';

import 'package:fund_manager/core/utils/format_utils.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';

class SubscriptionInfoCard extends StatelessWidget {

  final UserFund? effectiveUserFund;
  const SubscriptionInfoCard({
    super.key,
    required this.effectiveUserFund,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 14.0,
                color: Colors.green[700],
              ),
              SizedBox(width: 4.0),
              Text(
                'Tu Inversión',
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.0),
          Row(
            children: [
              Expanded(
                child: _buildSubscriptionDetail(
                  'Invertido',
                  '\$${FormatUtils.formatAmount(effectiveUserFund?.investedAmount ?? 0)}',
                  Colors.blue[700]!,
                ),
              ),
              Expanded(
                child: _buildSubscriptionDetail(
                  'Valor Actual',
                  '\$${FormatUtils.formatAmount(effectiveUserFund?.getCalculatedCurrentValue() ?? 0)}',
                  Colors.green[700]!,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: _buildSubscriptionDetail(
                  'Ganancias',
                  '\$${FormatUtils.formatAmount(effectiveUserFund?.getTotalGains() ?? 0)}',
                  (effectiveUserFund?.getTotalGains() ?? 0) >= 0 ? Colors.green[700]! : Colors.red[700]!,
                ),
              ),
              Expanded(
                child: _buildSubscriptionDetail(
                  'Rendimiento',
                  '${effectiveUserFund?.getCurrentPerformance().toStringAsFixed(2)}%',
                  Colors.orange[700]!,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12.0,
                color: Colors.green[600],
              ),
              SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  'Actualizado cada minuto - Rendimiento fijo: ${effectiveUserFund?.fixedPerformance.toStringAsFixed(2)}% por minuto',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.0,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

}
