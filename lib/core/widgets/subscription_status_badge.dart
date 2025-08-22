import 'package:flutter/material.dart';


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
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
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
            size: 12.0,
            color: Colors.green,
          ),
          SizedBox(width: 4.0),
          Text(
            customText ?? 'Suscrito',
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
