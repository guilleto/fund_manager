import 'package:equatable/equatable.dart';

class UserFund extends Equatable {
  final String id;
  final String fundId;
  final String fundName;
  final String category;
  final double investedAmount;
  final DateTime subscriptionDate;
  final double currentValue;
  final double performance;
  final bool isActive;

  const UserFund({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.category,
    required this.investedAmount,
    required this.subscriptionDate,
    required this.currentValue,
    required this.performance,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        fundId,
        fundName,
        category,
        investedAmount,
        subscriptionDate,
        currentValue,
        performance,
        isActive,
      ];

  UserFund copyWith({
    String? id,
    String? fundId,
    String? fundName,
    String? category,
    double? investedAmount,
    DateTime? subscriptionDate,
    double? currentValue,
    double? performance,
    bool? isActive,
  }) {
    return UserFund(
      id: id ?? this.id,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      category: category ?? this.category,
      investedAmount: investedAmount ?? this.investedAmount,
      subscriptionDate: subscriptionDate ?? this.subscriptionDate,
      currentValue: currentValue ?? this.currentValue,
      performance: performance ?? this.performance,
      isActive: isActive ?? this.isActive,
    );
  }
}
