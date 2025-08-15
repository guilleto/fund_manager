import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final double balance;
  final NotificationPreference notificationPreference;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.notificationPreference,
  });

  @override
  List<Object?> get props => [id, name, email, balance, notificationPreference];

  User copyWith({
    String? id,
    String? name,
    String? email,
    double? balance,
    NotificationPreference? notificationPreference,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      notificationPreference:
          notificationPreference ?? this.notificationPreference,
    );
  }
}

enum NotificationPreference {
  email,
  sms,
  both,
  none,
}

extension NotificationPreferenceExtension on NotificationPreference {
  String get displayName {
    switch (this) {
      case NotificationPreference.email:
        return 'Email';
      case NotificationPreference.sms:
        return 'SMS';
      case NotificationPreference.both:
        return 'Email y SMS';
      case NotificationPreference.none:
        return 'Sin notificaciones';
    }
  }
}
