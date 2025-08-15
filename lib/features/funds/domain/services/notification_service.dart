import '../models/user.dart';
import '../models/transaction.dart';

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
    final emailSubject =
        'Transacción ${transaction.type.displayName} - Fund Manager';
    final emailBody = _generateEmailBody(user, transaction);
    final smsMessage = _generateSMSMessage(user, transaction);

    bool emailSuccess = true;
    bool smsSuccess = true;

    // Enviar notificaciones según las preferencias del usuario
    switch (user.notificationPreference) {
      case NotificationPreference.email:
        emailSuccess = await sendEmail(
          to: user.email,
          subject: emailSubject,
          body: emailBody,
        );
        break;

      case NotificationPreference.sms:
        smsSuccess = await sendSMS(
          to: user.email, // En un caso real sería el número de teléfono
          message: smsMessage,
        );
        break;

      case NotificationPreference.both:
        emailSuccess = await sendEmail(
          to: user.email,
          subject: emailSubject,
          body: emailBody,
        );
        smsSuccess = await sendSMS(
          to: user.email, // En un caso real sería el número de teléfono
          message: smsMessage,
        );
        break;

      case NotificationPreference.none:
        return true; // No enviar notificaciones
    }

    return emailSuccess && smsSuccess;
  }

  String _generateEmailBody(User user, Transaction transaction) {
    final amount = _formatCurrency(transaction.amount);
    final date = _formatDate(transaction.date);

    return '''
Hola ${user.name},

Tu transacción ha sido procesada exitosamente:

📊 Detalles de la transacción:
• Tipo: ${transaction.type.displayName}
• Fondo: ${transaction.fundName}
• Monto: $amount
• Fecha: $date
• Estado: ${transaction.status.displayName}

${transaction.description != null ? '• Descripción: ${transaction.description}' : ''}

Saldo actual: ${_formatCurrency(user.balance)}

Gracias por usar Fund Manager.

Saludos,
El equipo de Fund Manager
    ''';
  }

  String _generateSMSMessage(User user, Transaction transaction) {
    final amount = _formatCurrency(transaction.amount);

    return '''
Fund Manager: ${transaction.type.displayName} exitosa en ${transaction.fundName} por $amount. Saldo: ${_formatCurrency(user.balance)}
    '''
        .trim();
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
