import 'package:equatable/equatable.dart';

class Fund extends Equatable {
  final int id;
  final String name;
  final int minAmount;
  final String category;
  final String type;
  final String risk;
  final String status;
  final double value;
  final double performance;

  const Fund({
    required this.id,
    required this.name,
    required this.minAmount,
    required this.category,
    required this.type,
    required this.risk,
    required this.status,
    required this.value,
    required this.performance,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        minAmount,
        category,
        type,
        risk,
        status,
        value,
        performance,
      ];
}
