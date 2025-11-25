import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Semana'), Tab(text: 'Mes'), Tab(text: 'Todo')],
          ),
        ),
        body: const TabBarView(
          children: [
            _ExpenseList(filter: 'week'),
            _ExpenseList(filter: 'month'),
            _ExpenseList(filter: 'all'),
          ],
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final String filter;

  const _ExpenseList({required this.filter});

  void _showEditDialog(BuildContext context, Expense expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    String selectedCategory = expense.category;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Gasto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items:
                        [
                              'Autobús',
                              'Metro',
                              'Colectivo',
                              'Taxi/Uber',
                              'Gasolina',
                              'Otro',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getIconForCategory(category),
                                      size: 18,
                                      color: Colors.deepPurple,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(category),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newTitle = titleController.text;
                  final newAmount =
                      double.tryParse(amountController.text) ?? expense.amount;

                  if (newTitle.isNotEmpty && newAmount > 0) {
                    final updatedExpense = expense.copy(
                      title: newTitle,
                      amount: newAmount,
                      category: selectedCategory,
                    );
                    Provider.of<ExpenseProvider>(
                      context,
                      listen: false,
                    ).updateExpense(updatedExpense);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gasto actualizado')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        List<Expense> expenses = provider.expenses;
        final now = DateTime.now();

        if (filter == 'week') {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          expenses =
              expenses
                  .where(
                    (e) => e.date.isAfter(
                      startOfWeek.subtract(const Duration(days: 1)),
                    ),
                  )
                  .toList();
        } else if (filter == 'month') {
          expenses =
              expenses
                  .where(
                    (e) => e.date.month == now.month && e.date.year == now.year,
                  )
                  .toList();
        }

        final totalAmount = expenses.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );
        final dateRangeText = _getDateRangeText(filter);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Gastado:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            dateRangeText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Mantén presionado para editar',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Dismissible(
                    key: Key(expense.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      provider.deleteExpense(expense.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gasto eliminado')),
                      );
                    },
                    child: ListTile(
                      onLongPress: () => _showEditDialog(context, expense),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          _getIconForCategory(expense.category),
                          color: Colors.deepPurple,
                        ),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(expense.date),
                      ),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDateRangeText(String filter) {
    final now = DateTime.now();
    if (filter == 'week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final dateFormat = DateFormat('d MMM yyyy');
      return 'Semana ${dateFormat.format(startOfWeek)} - ${dateFormat.format(endOfWeek)}';
    } else if (filter == 'month') {
      return DateFormat('MMMM yyyy', 'es_MX').format(now).toUpperCase();
    } else {
      return 'Historial Completo';
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Autobús':
        return FontAwesomeIcons.bus;
      case 'Taxi/Uber':
        return FontAwesomeIcons.taxi;
      case 'Metro':
        return FontAwesomeIcons.train;
      case 'Colectivo':
        return FontAwesomeIcons.vanShuttle;
      case 'Gasolina':
        return FontAwesomeIcons.gasPump;
      default:
        return FontAwesomeIcons.moneyBill;
    }
  }
}
