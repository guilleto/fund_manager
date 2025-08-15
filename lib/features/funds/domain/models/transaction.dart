import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String fundId;
  final String fundName;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String? description;

  const Transaction({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        fundId,
        fundName,
        type,
        amount,
        date,
        status,
        description,
      ];
}

enum TransactionType {
  subscription,
  cancellation,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.subscription:
        return 'Suscripción';
      case TransactionType.cancellation:
        return 'Cancelación';
    }
  }

  String get actionName {
    switch (this) {
      case TransactionType.subscription:
        return 'Suscribirse';
      case TransactionType.cancellation:
        return 'Cancelar';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pendiente';
      case TransactionStatus.completed:
        return 'Completada';
      case TransactionStatus.failed:
        return 'Fallida';
      case TransactionStatus.cancelled:
        return 'Cancelada';
    }
  }
}
