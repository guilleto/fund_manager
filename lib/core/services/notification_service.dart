import 'package:fund_manager/features/funds/domain/models/user.dart';
import 'package:fund_manager/features/funds/domain/models/transaction.dart';

abstract class NotificationService {
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  });

  Future<bool> sendSMS({
    required String to,
    required String message,
  });

  Future<bool> sendTransactionNotification({
    required User user,
    required Transaction transaction,
  });
}

class MockNotificationService implements NotificationService {
  @override
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Simular envío de email
    await Future.delayed(const Duration(milliseconds: 500));

    // Simular éxito (90% de probabilidad)
    final success = DateTime.now().millisecondsSinceEpoch % 10 != 0;

    if (success) {
      print('📧 Email enviado exitosamente a: $to');
      print('📧 Asunto: $subject');
      print('📧 Contenido: $body');
    } else {
      print('❌ Error al enviar email a: $to');
    }

    return success;
  }

  @override
  Future<bool> sendSMS({
    required String to,
    required String message,
  }) async {
    // Simular envío de SMS
    await Future.delayed(const Duration(milliseconds: 300));

    // Simular éxito (95% de probabilidad)
    final success = DateTime.now().millisecondsSinceEpoch % 20 != 0;

    if (success) {
      print('📱 SMS enviado exitosamente a: $to');
      print('📱 Mensaje: $message');
    } else {
      print('❌ Error al enviar SMS a: $to');
    }

    return success;
  }

  @override
  Future<bool> sendTransactionNotification({
    required User user,
    required Transaction transaction,
  }) async {
    try {
      final subject = 'Transacción ${transaction.type.name} - ${transaction.fundName}';
      final body = '''
Hola ${user.name},

Se ha procesado tu transacción:

Fondo: ${transaction.fundName}
Tipo: ${transaction.type.name}
Monto: \$${transaction.amount.toStringAsFixed(0)}
Fecha: ${transaction.date.toString()}
Estado: ${transaction.status.name}

Saldo actual: \$${user.balance.toStringAsFixed(0)}

Gracias por usar nuestro servicio.
''';

      switch (user.notificationPreference) {
        case NotificationPreference.sms:
          // En un caso real, necesitarías el número de teléfono del usuario
          return await sendSMS(
            to: '+57XXXXXXXXX', // Número mock
            message: 'Transacción ${transaction.type.name} - ${transaction.fundName} - \$${transaction.amount.toStringAsFixed(0)}',
          );
        case NotificationPreference.both:
          final emailSuccess = await sendEmail(
            to: user.email,
            subject: subject,
            body: body,
          );
          final smsSuccess = await sendSMS(
            to: '+57XXXXXXXXX',
            message: 'Transacción ${transaction.type.name} - ${transaction.fundName} - \$${transaction.amount.toStringAsFixed(0)}',
          );
          return emailSuccess || smsSuccess;
          
        default:
          return await sendEmail(
            to: user.email,
            subject: subject,
            body: body,
          );
      }
    } catch (e) {
      print('Error al enviar notificación de transacción: $e');
      return false;
    }
  }
}
