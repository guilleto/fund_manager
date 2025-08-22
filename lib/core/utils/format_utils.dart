import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class FormatUtils {
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime date,
      {String format = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(format).format(date);
  }

  static String formatCurrency(double amount, {String currency = 'USD'}) {
    return NumberFormat.currency(
      symbol: currency == 'USD' ? '\$' : currency,
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatCurrencyInt(int amount, {String currency = 'USD'}) {
    return NumberFormat.currency(
      symbol: currency == 'USD' ? '\$' : currency,
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  static DateTime parseDate(String dateString, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).parse(dateString);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos';
    } else {
      return 'Ahora';
    }
  }

  // Método para formatear montos de manera abreviada (K, M)
  static String formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // Método para formatear montos enteros de manera abreviada
  static String formatAmountInt(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toString();
    }
  }

  // Método para obtener el icono de la actividad
  static IconData getActivityIcon(String type) {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'sale':
        return Icons.sell;
      case 'dividend':
        return Icons.payments;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.info;
    }
  }

  // Método para obtener el color de la actividad
  static Color getActivityColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.green;
      case 'sale':
        return Colors.red;
      case 'dividend':
        return Colors.blue;
      case 'transfer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Método para obtener el color de la categoría
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'FPV':
        return Colors.blue;
      case 'FIC':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
