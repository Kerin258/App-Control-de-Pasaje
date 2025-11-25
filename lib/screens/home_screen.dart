import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/shortcut_model.dart';
import '../utils/colors.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import '../models/expense_model.dart';

/// Pantalla principal de la aplicación (Dashboard)
///
/// Hub central que muestra:
/// - Resumen de presupuesto y gastos del día
/// - Atajos rápidos personalizables para gastos frecuentes
/// - Últimos gastos registrados
/// - Navegación a otras secciones (Historial, Estadísticas, Perfil)
///
/// Incluye funcionalidad para crear, editar y eliminar atajos rápidos.
///
/// Desarrollado por: Kevin y [Nombre del compañero/a]
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = const DashboardTab();
        break;
      case 1:
        currentScreen = const HistoryScreen();
        break;
      case 2:
        currentScreen = const StatsScreen();
        break;
      case 3:
        currentScreen = const ProfileScreen();
        break;
      default:
        currentScreen = const DashboardTab();
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExpenseScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  ImageProvider? _getImageProvider(String? path) {
    if (path == null) return null;
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola,',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              provider.userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.deepPurple.shade100,
                backgroundImage: _getImageProvider(provider.profileImagePath),
                child:
                    provider.profileImagePath == null
                        ? const Icon(Icons.person, color: Colors.deepPurple)
                        : null,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tu Presupuesto',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                currencyFormat.format(provider.budget),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: CircularProgressIndicator(
                                  value:
                                      provider.budget > 0
                                          ? provider.totalSpent /
                                              provider.budget
                                          : 0,
                                  backgroundColor: Colors.grey[200],
                                  color:
                                      provider.remainingBudget <
                                              (provider.budget * 0.2)
                                          ? AppColors.budgetCritical
                                          : AppColors.budgetHealthy,
                                  strokeWidth: 12,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    currencyFormat.format(provider.totalSpent),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Gastado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Te quedan ${currencyFormat.format(provider.remainingBudget)}',
                            style: TextStyle(
                              color:
                                  provider.remainingBudget < 0
                                      ? Colors.red
                                      : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Accesos Rápidos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (provider.shortcuts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'No tienes atajos aún.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => _showAddShortcutDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Crear Atajo'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: provider.shortcuts.length + 1,
                          itemBuilder: (context, index) {
                            if (index == provider.shortcuts.length) {
                              return _QuickActionButton(
                                icon: Icons.add,
                                label: 'Nuevo',
                                onTap: () => _showAddShortcutDialog(context),
                                isAddButton: true,
                              );
                            }
                            final shortcut = provider.shortcuts[index];
                            return _QuickActionButton(
                              icon: IconData(
                                shortcut.iconCode,
                                fontFamily: 'FontAwesomeSolid',
                                fontPackage: 'font_awesome_flutter',
                              ),
                              label: shortcut.label,
                              onTap: () => _quickAdd(context, shortcut),
                              onLongPress:
                                  () => _showEditShortcutDialog(
                                    context,
                                    shortcut,
                                  ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Mantén presionado para editar',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Recent Transactions
                  const Text(
                    'Últimos Movimientos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.expenses.take(3).length,
                    itemBuilder: (context, index) {
                      final expense = provider.expenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
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
                            DateFormat('dd MMM, HH:mm').format(expense.date),
                          ),
                          trailing: Text(
                            '- ${currencyFormat.format(expense.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _quickAdd(BuildContext context, Shortcut shortcut) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final newExpense = Expense(
      title: shortcut.label,
      amount: shortcut.price,
      date: DateTime.now(),
      category: shortcut.category,
    );
    provider.addExpense(newExpense);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gasto añadido: ${shortcut.label} - \$${shortcut.price}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            provider.deleteExpense(newExpense.id!);
          },
        ),
      ),
    );
  }

  void _showAddShortcutDialog(BuildContext context) {
    final priceController = TextEditingController();
    String selectedCategory = 'Autobús';
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    void updatePrice() {
      final defaultPrice = provider.getDefaultPrice(selectedCategory);
      if (defaultPrice > 0) {
        priceController.text = defaultPrice.toStringAsFixed(0);
      } else {
        priceController.text = '';
      }
    }

    updatePrice();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Nuevo Atajo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.deepPurple,
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
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconForCategory(cat),
                                            size: 20,
                                            color: Colors.deepPurple,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(cat),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCategory = val!;
                              updatePrice();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (priceController.text.isNotEmpty) {
                    final newShortcut = Shortcut(
                      id: DateTime.now().toString(),
                      label: selectedCategory, // Use category as label
                      iconCode: _getIconForCategory(selectedCategory).codePoint,
                      price: double.parse(priceController.text),
                      category: selectedCategory,
                    );
                    provider.addShortcut(newShortcut);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showEditShortcutDialog(BuildContext context, Shortcut shortcut) {
    final priceController = TextEditingController(
      text: shortcut.price.toStringAsFixed(0),
    );
    String selectedCategory = shortcut.category;
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Editar Atajo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.deepPurple,
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
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconForCategory(cat),
                                            size: 20,
                                            color: Colors.deepPurple,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(cat),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCategory = val!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () {
                  provider.deleteShortcut(shortcut.id);
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (priceController.text.isNotEmpty) {
                    final updatedShortcut = Shortcut(
                      id: shortcut.id,
                      label: selectedCategory, // Use category as label
                      iconCode: _getIconForCategory(selectedCategory).codePoint,
                      price: double.parse(priceController.text),
                      category: selectedCategory,
                    );
                    provider.editShortcut(updatedShortcut);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Autobús':
        return FontAwesomeIcons.bus;
      case 'Metro':
        return FontAwesomeIcons.train;
      case 'Colectivo':
        return FontAwesomeIcons.vanShuttle;
      case 'Taxi/Uber':
        return FontAwesomeIcons.taxi;
      case 'Gasolina':
        return FontAwesomeIcons.gasPump;
      default:
        return FontAwesomeIcons.moneyBill;
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isAddButton;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color:
                  isAddButton
                      ? Colors.grey[200]
                      : Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  isAddButton ? Border.all(color: Colors.grey, width: 1) : null,
            ),
            child: Icon(
              icon,
              color: isAddButton ? Colors.grey : Colors.deepPurple,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isAddButton ? Colors.grey : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
