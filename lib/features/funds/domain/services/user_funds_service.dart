import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/features/funds/domain/services/notification_service.dart';

abstract class UserFundsService {
  Future<User> getCurrentUser();
  Future<List<UserFund>> getUserFunds();
  Future<List<Transaction>> getTransactionHistory();
  Future<bool> subscribeToFund({
    required Fund fund,
    required double amount,
  });
  Future<bool> cancelFund({
    required UserFund userFund,
  });
  Future<bool> updateNotificationPreference({
    required NotificationPreference preference,
  });
}

class MockUserFundsService implements UserFundsService {
  final NotificationService _notificationService;

  // Datos mock del usuario
  User _currentUser = const User(
    id: '1',
    name: 'Guillermo C',
    email: 'guilleccubillos@hotmail.com',
    balance: 500000.0, // Saldo inicial de COP $500.000
    notificationPreference: NotificationPreference.email,
  );

  // Lista de fondos del usuario
  final List<UserFund> _userFunds = [];

  // Historial de transacciones
  final List<Transaction> _transactions = [];

  MockUserFundsService(this._notificationService);

  @override
  Future<User> getCurrentUser() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<List<UserFund>> getUserFunds() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    return _userFunds.where((fund) => fund.isActive).toList();
  }

  @override
  Future<List<Transaction>> getTransactionHistory() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 250));
    return _transactions.reversed.toList(); // Más recientes primero
  }

  @override
  Future<bool> subscribeToFund({
    required Fund fund,
    required double amount,
  }) async {
    // Validar saldo suficiente
    if (_currentUser.balance < amount) {
      throw Exception(
          'Saldo insuficiente. Saldo actual: \$${_currentUser.balance.toStringAsFixed(0)}');
    }

    // Validar monto mínimo
    if (amount < fund.minAmount) {
      throw Exception(
          'El monto debe ser al menos \$${fund.minAmount.toStringAsFixed(0)}');
    }

    // Simular procesamiento
    await Future.delayed(const Duration(milliseconds: 1000));

    // Crear transacción
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fundId: fund.id.toString(),
      fundName: fund.name,
      type: TransactionType.subscription,
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      description: 'Suscripción al fondo ${fund.name}',
    );

    // Actualizar saldo del usuario
    _currentUser = _currentUser.copyWith(
      balance: _currentUser.balance - amount,
    );

    // Agregar fondo a la lista del usuario
    final userFund = UserFund(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fundId: fund.id.toString(),
      fundName: fund.name,
      category: fund.category,
      investedAmount: amount,
      subscriptionDate: DateTime.now(),
      currentValue: amount, // Inicialmente igual al monto invertido
      performance: 0.0, // Sin rendimiento inicial
      isActive: true,
    );

    _userFunds.add(userFund);
    _transactions.add(transaction);

    // Enviar notificación
    await _notificationService.sendTransactionNotification(
      user: _currentUser,
      transaction: transaction,
    );

    return true;
  }

  @override
  Future<bool> cancelFund({
    required UserFund userFund,
  }) async {
    // Simular procesamiento
    await Future.delayed(const Duration(milliseconds: 800));

    // Crear transacción de cancelación
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fundId: userFund.fundId,
      fundName: userFund.fundName,
      type: TransactionType.cancellation,
      amount: userFund.currentValue,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      description: 'Cancelación del fondo ${userFund.fundName}',
    );

    // Actualizar saldo del usuario (devolver el valor actual)
    _currentUser = _currentUser.copyWith(
      balance: _currentUser.balance + userFund.currentValue,
    );

    // Marcar fondo como inactivo
    final index = _userFunds.indexWhere((fund) => fund.id == userFund.id);
    if (index != -1) {
      _userFunds[index] = _userFunds[index].copyWith(isActive: false);
    }

    _transactions.add(transaction);

    // Enviar notificación
    await _notificationService.sendTransactionNotification(
      user: _currentUser,
      transaction: transaction,
    );

    return true;
  }

  @override
  Future<bool> updateNotificationPreference({
    required NotificationPreference preference,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 150));

    _currentUser = _currentUser.copyWith(
      notificationPreference: preference,
    );

    return true;
  }
}
