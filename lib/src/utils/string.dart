extension StringChecks on String {
  bool isValidStringId() {
    return isNotEmpty &&
        trim().isNotEmpty &&
        replaceAll(
          RegExp(r'\p{Z}', unicode: true),
          '',
        ).isNotEmpty;
  }
}
