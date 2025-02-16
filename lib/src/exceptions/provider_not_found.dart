class ProviderNotFound implements Exception {
  @override
  String toString() {
    return '''TreeNotifierProvider was not found on the tree of the widgets. 
    Please, ensure that you are wrapping your tree of widget before 
    use context.readTree or context.watchTree''';
  }
}
