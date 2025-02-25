class Validators {
  static required(String? value) {
    return value?.isEmpty ?? false;
  }

  static minLength(String? value, int min) {
    return value != null && value.length <= min;
  }

  static maxLength(String? value, int max) {
    return value != null && value.length >= max;
  }

  static bool simpleEmail(String? value) {
    const pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regex = RegExp(pattern);

    // Si value es null o está vacío, retornamos true (indicando error)
    if (value == null || value.isEmpty) {
      return true;
    }

    // Si llegamos aquí, value no es null ni está vacío, verificamos el regex
    return !regex.hasMatch(value);
  }

  static bool email(String? value) {
    // const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'";
    const pattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    // Si value es null o está vacío, retornamos true (indicando error)
    if (value == null || value.isEmpty) {
      return true;
    }

    // Si llegamos aquí, value no es null ni está vacío, verificamos el regex
    return !regex.hasMatch(value);
  }

  static pattern(String? value, String pattern) {
    final regex = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return true;
    }
    return !regex.hasMatch(value);
  }
}
