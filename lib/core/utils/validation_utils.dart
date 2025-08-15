class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // Mínimo 8 caracteres, al menos una letra mayúscula, una minúscula y un número
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidAmount(String amount) {
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    return amountRegex.hasMatch(amount);
  }

  static bool isValidPercentage(String percentage) {
    final percentageRegex =
        RegExp(r'^(100(\.0{1,2})?|([0-9]|[1-9][0-9])(\.[0-9]{1,2})?)$');
    return percentageRegex.hasMatch(percentage);
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }
    if (!isValidEmail(email)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!isValidPassword(password)) {
      return 'La contraseña debe contener al menos una letra mayúscula, una minúscula y un número';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede tener más de $maxLength caracteres';
    }
    return null;
  }

  static String? validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'El monto es requerido';
    }
    if (!isValidAmount(amount)) {
      return 'Ingrese un monto válido';
    }
    final doubleValue = double.tryParse(amount);
    if (doubleValue == null || doubleValue <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    return null;
  }

  static String? validatePercentage(String? percentage) {
    if (percentage == null || percentage.isEmpty) {
      return 'El porcentaje es requerido';
    }
    if (!isValidPercentage(percentage)) {
      return 'Ingrese un porcentaje válido (0-100)';
    }
    return null;
  }
}
