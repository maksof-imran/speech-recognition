class PagePath {
  /// Unauthenticated Routes
  static const String slash = '/';
  static const String stores = '/stores';
  static const String home = '/home';
}

extension ContextExtensionss on String {
  String get toRoute => '/$this';
}
