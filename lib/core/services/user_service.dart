import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/user_fund.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';
import 'package:fund_manager/features/funds/domain/models/fund.dart';
import 'package:fund_manager/core/services/notification_service.dart';
import 'dart:math';

abstract class UserService {
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
  Future<bool> updateUser(User user);
}

class MockUserService implements UserService {
  final NotificationService _notificationService;

  // Datos mock del usuario
  User _currentUser = const User(
    id: '1',
    name: 'Guillermo C',
    email: 'guilleccubillos@hotmail.com',
    phone: '+57 300 123 4567',
    balance: 500000.0, // Saldo inicial de COP $500.000
    notificationPreference: NotificationPreference.email,
  );

  // Lista de fondos del usuario
  final List<UserFund> _userFunds = [];

  // Historial de transacciones
  final List<Transaction> _transactions = [];

  MockUserService(this._notificationService);

  @override
  Future<User> getCurrentUser() async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 200));
      return _currentUser;
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return _currentUser;
    }
  }

  @override
  Future<List<UserFund>> getUserFunds() async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('DEBUG: Obteniendo fondos del usuario - Total: ${_userFunds.length}');
      
      // Actualizar los valores de las suscripciones activas
      for (int i = 0; i < _userFunds.length; i++) {
        if (_userFunds[i].isActive) {
          final oldValue = _userFunds[i].currentValue;
          _userFunds[i] = _updateUserFundValue(_userFunds[i]);
          final newValue = _userFunds[i].currentValue;
          
          if (oldValue != newValue) {
            print('DEBUG: Valor actualizado para ${_userFunds[i].fundName}: \$${oldValue} -> \$${newValue}');
          }
        }
      }
      
      final activeFunds = _userFunds.where((fund) => fund.isActive).toList();
      print('DEBUG: Fondos activos retornados: ${activeFunds.length}');
      
      return activeFunds;
    } catch (e) {
      print('Error al obtener fondos del usuario: $e');
      return [];
    }
  }

  @override
  Future<List<Transaction>> getTransactionHistory() async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 250));
      return _transactions.reversed.toList(); // Más recientes primero
    } catch (e) {
      print('Error al obtener historial de transacciones: $e');
      return [];
    }
  }

  @override
  Future<bool> subscribeToFund({
    required Fund fund,
    required double amount,
  }) async {
    try {
      // Validar si ya está suscrito al fondo
      final existingSubscriptions = _userFunds.where(
        (uf) => uf.fundId == fund.id.toString() && uf.isActive,
      ).toList();
      
      if (existingSubscriptions.isNotEmpty) {
        throw Exception(
            'Ya estás suscrito al fondo ${fund.name}. No puedes suscribirte múltiples veces al mismo fondo.');
      }

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

      // Agregar fondo a la lista del usuario con rendimiento fijo
      final userFund = UserFund(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fundId: fund.id.toString(),
        fundName: fund.name,
        category: fund.category,
        investedAmount: amount,
        subscriptionDate: DateTime.now(),
        currentValue: amount, // Inicialmente igual al monto invertido
        performance: 0.0, // Sin rendimiento inicial
        fixedPerformance: fund.performance, // Rendimiento fijo al momento de suscripción
        isActive: true,
      );
      
      print('DEBUG: Suscribiendo a fondo ${fund.name}');
      print('DEBUG: Monto invertido: \$${amount}');
      print('DEBUG: Rendimiento fijo guardado: ${fund.performance}% por minuto');
      print('DEBUG: Fecha de suscripción: ${DateTime.now()}');

      _userFunds.add(userFund);
      _transactions.add(transaction);

      // Enviar notificación (sin bloquear si falla)
      try {
        await _notificationService.sendTransactionNotification(
          user: _currentUser,
          transaction: transaction,
        );
      } catch (notificationError) {
        print('Error al enviar notificación: $notificationError');
      }

      return true;
    } catch (e) {
      print('Error en subscribeToFund: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelFund({
    required UserFund userFund,
  }) async {
    try {
      // Simular procesamiento
      await Future.delayed(const Duration(milliseconds: 800));

      // Calcular el valor actual basado en el rendimiento fijo y tiempo transcurrido
      final updatedUserFund = _updateUserFundValue(userFund);
      final calculatedValue = updatedUserFund.currentValue;
      final gains = calculatedValue - userFund.investedAmount;
      
      print('DEBUG: Cancelando fondo ${userFund.fundName}');
      print('DEBUG: Valor invertido: \$${userFund.investedAmount}');
      print('DEBUG: Valor calculado: \$${calculatedValue}');
      print('DEBUG: Ganancias: \$${gains}');
      print('DEBUG: Rendimiento fijo: ${userFund.fixedPerformance}% por minuto');
      
      // Crear transacción de cancelación
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fundId: userFund.fundId,
        fundName: userFund.fundName,
        type: TransactionType.cancellation,
        amount: calculatedValue,
        date: DateTime.now(),
        status: TransactionStatus.completed,
        description: 'Cancelación del fondo ${userFund.fundName} - Ganancias: \$${gains.toStringAsFixed(2)}',
      );

      // Actualizar saldo del usuario (devolver el valor calculado)
      _currentUser = _currentUser.copyWith(
        balance: _currentUser.balance + calculatedValue,
      );

      // Marcar fondo como inactivo
      final index = _userFunds.indexWhere((fund) => fund.id == userFund.id);
      if (index != -1) {
        _userFunds[index] = _userFunds[index].copyWith(isActive: false);
      }

      _transactions.add(transaction);

      // Enviar notificación (sin bloquear si falla)
      try {
        await _notificationService.sendTransactionNotification(
          user: _currentUser,
          transaction: transaction,
        );
      } catch (notificationError) {
        print('Error al enviar notificación: $notificationError');
      }

      return true;
    } catch (e) {
      print('Error en cancelFund: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateNotificationPreference({
    required NotificationPreference preference,
  }) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 150));

      _currentUser = _currentUser.copyWith(
        notificationPreference: preference,
      );

      return true;
    } catch (e) {
      print('Error al actualizar preferencias de notificación: $e');
      return false;
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));

      _currentUser = user;

      return true;
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return false;
    }
  }

  /// Actualiza el valor actual de un UserFund basado en el rendimiento fijo y tiempo transcurrido
  UserFund _updateUserFundValue(UserFund userFund) {
    if (!userFund.isActive) return userFund;
    
    final now = DateTime.now();
    final duration = now.difference(userFund.subscriptionDate);
    final minutesElapsed = duration.inMinutes;
    
    // Si no han pasado minutos, retornar el valor invertido
    if (minutesElapsed <= 0) return userFund;
    
    // El rendimiento fijo ya es por minuto
    final performancePerMinute = userFund.fixedPerformance;
    
    // Calcular el valor actual con interés compuesto por minuto
    final calculatedValue = userFund.investedAmount * pow(1 + performancePerMinute / 100, minutesElapsed);
    
    print('DEBUG: Actualizando UserFund ${userFund.fundName}');
    print('DEBUG: Minutos transcurridos: $minutesElapsed');
    print('DEBUG: Rendimiento por minuto: ${performancePerMinute}%');
    print('DEBUG: Valor invertido: \$${userFund.investedAmount}');
    print('DEBUG: Valor calculado: \$${calculatedValue}');
    print('DEBUG: Ganancias: \$${calculatedValue - userFund.investedAmount}');
    
    return userFund.copyWith(currentValue: calculatedValue);
  }
}
