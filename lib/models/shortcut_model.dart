/// Modelo que representa un atajo rápido para registrar gastos frecuentes.
///
/// Los atajos permiten al usuario registrar gastos comunes con un solo toque,
/// guardando la categoría, precio y etiqueta predefinidos.
///
/// Desarrollado por: Kevin y [Nombre del compañero/a]
/// Fecha: Noviembre 2025
class Shortcut {
  /// ID único del atajo
  final String id;

  /// Etiqueta descriptiva del atajo
  final String label;

  /// Código del icono (IconData.codePoint) para mostrar en la UI
  final int iconCode;

  /// Precio predefinido del gasto
  final double price;

  /// Categoría del transporte asociada al atajo
  final String category;

  /// Constructor de la clase Shortcut
  Shortcut({
    required this.id,
    required this.label,
    required this.iconCode,
    required this.price,
    required this.category,
  });

  /// Convierte el atajo a JSON para guardarlo en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'iconCode': iconCode,
      'price': price,
      'category': category,
    };
  }

  /// Crea un atajo desde datos JSON almacenados
  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(
      id: json['id'],
      label: json['label'],
      iconCode: json['iconCode'],
      price: json['price'].toDouble(),
      category: json['category'],
    );
  }
}
