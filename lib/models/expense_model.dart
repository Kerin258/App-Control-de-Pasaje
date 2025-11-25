/// Modelo que representa un gasto de transporte en la aplicación.
///
/// Esta clase almacena la información de cada gasto registrado por el usuario,
/// incluyendo el monto, la fecha, la categoría de transporte y una descripción.
///
/// Desarrollado por: Kevin y kerin
/// Fecha: Noviembre 2025
class Expense {
  /// ID único del gasto en la base de datos (null si aún no se ha guardado)
  final int? id;

  /// Título o descripción del gasto (ej: "Ruta 68 al centro")
  final String title;

  /// Monto del gasto en pesos mexicanos
  final double amount;

  /// Fecha en que se realizó el gasto
  final DateTime date;

  /// Categoría del transporte (Autobús, Metro, Taxi/Uber, etc.)
  final String category;

  /// Constructor de la clase Expense
  ///
  /// Todos los campos son requeridos excepto [id], que se asigna automáticamente
  /// al guardar en la base de datos.
  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  /// Convierte el objeto Expense a un Map
  ///
  /// Retorna un Map con todos los campos del gasto, convirtiendo
  /// la fecha a formato ISO 8601 para almacenamiento.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  /// Crea un objeto Expense desde un Map de la base de datos
  ///
  /// Factory constructor que reconstruye un gasto desde los datos
  /// almacenados en SQLite, parseando la fecha desde formato ISO 8601.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }

  /// Crea una copia del gasto con campos modificados
  ///
  /// Útil para actualizar gastos existentes sin modificar el original.
  /// Solo se actualizan los campos que se pasen como parámetros.
  Expense copy({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
