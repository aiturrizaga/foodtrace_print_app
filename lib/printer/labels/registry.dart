import 'base.dart';
import 'templates/production_template.dart';

/// Registry that maps template names to their implementations.
class TemplateRegistry {
  TemplateRegistry._();

  static final Map<String, BaseTemplate> _templates = {
    'production': ProductionTemplate(),
  };

  /// Returns the template for [name], or null if not registered.
  static BaseTemplate? get(String name) => _templates[name];

  /// Returns all registered template names with display names.
  static List<({String name, String displayName})> get all => _templates.entries
      .map((e) => (name: e.key, displayName: e.value.displayName))
      .toList();
}
