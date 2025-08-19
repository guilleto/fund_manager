import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionStatusBadge extends StatelessWidget {
  final bool isSubscribed;
  final String? customText;

  const SubscriptionStatusBadge({
    super.key,
    required this.isSubscribed,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSubscribed) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 12.sp,
            color: Colors.green,
          ),
          SizedBox(width: 4.w),
          Text(
            customText ?? 'Suscrito',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
