import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

/// Pantalla para registrar un nuevo gasto de transporte
///
/// Permite al usuario ingresar:
/// - Monto del gasto
/// - Categoría de transporte (Autobús, Metro, Taxi, etc.)
/// - Nota o descripción opcional
/// - Fecha del gasto
///
/// Puede recibir valores iniciales desde atajos rápidos.
///
/// Desarrollado por: Kevin y kerin
class AddExpenseScreen extends StatefulWidget {
  final String? initialCategory;
  final double? initialAmount;

  const AddExpenseScreen({super.key, this.initialCategory, this.initialAmount});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Autobús';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount.toString() : '',
    );
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }

    // If no initial amount, try to set default based on category
    if (widget.initialAmount == null) {
      // We need to wait for provider to be available.
      // Since we can't access provider in initState easily for logic, we'll do it in didChangeDependencies
      // or just use a post-frame callback.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePriceForCategory();
      });
    }
  }

  /// Actualiza el precio sugerido según la categoría seleccionada
  ///
  /// Obtiene el precio predeterminado del provider según si el usuario
  /// es estudiante o no, y lo muestra en el campo de monto.
  void _updatePriceForCategory() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final defaultPrice = provider.getDefaultPrice(_selectedCategory);
    if (defaultPrice > 0) {
      setState(() {
        _amountController.text = defaultPrice.toString();
      });
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Autobús', 'icon': FontAwesomeIcons.bus},
    {'name': 'Taxi/Uber', 'icon': FontAwesomeIcons.taxi},
    {'name': 'Metro', 'icon': FontAwesomeIcons.train},
    {'name': 'Colectivo', 'icon': FontAwesomeIcons.vanShuttle},
    {'name': 'Gasolina', 'icon': FontAwesomeIcons.gasPump},
    {'name': 'Otro', 'icon': FontAwesomeIcons.moneyBill},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Guarda el gasto en la base de datos
  ///
  /// Valida el formulario y crea un nuevo objeto Expense con los datos
  /// ingresados. Si no hay título, usa la categoría como título.
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final enteredAmount = double.parse(_amountController.text);
      final enteredTitle =
          _titleController.text.isEmpty
              ? _selectedCategory
              : _titleController.text;

      final newExpense = Expense(
        title: enteredTitle,
        amount: enteredAmount,
        date: _selectedDate,
        category: _selectedCategory,
      );

      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).addExpense(newExpense);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un monto';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['name'],
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'],
                              size: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 10),
                            Text(cat['name']),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    // Update price when category changes, if it's not a "Quick Add" (initialAmount is null)
                    // Or even if it is, maybe user wants to switch?
                    // Let's say if user manually changes category, we suggest the new price.
                    _updatePriceForCategory();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nota / Ruta (Opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Ej. Ruta 68 al centro',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Guardar Gasto',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
