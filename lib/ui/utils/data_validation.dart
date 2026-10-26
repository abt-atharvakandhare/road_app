class DataValidation {
  static bool validatePassword(String? value) {
    if (value == null || value.isEmpty) return false;
    bool hasMinLength = value.length >= 8;
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    // Backend special chars - !#$%&'()*+,\-./:;<=>?@[\]^_`{|}~
    bool hasSpecialCharacter = value.contains(RegExp('[!#\$%&\'()*+,\\-./:;<=>?@[\\]^_`{|}~"]'));

    if (!hasMinLength || !(hasUppercase || hasLowercase) || !hasDigits || !hasSpecialCharacter) {
      return false;
    }

    return true;
  }
}
