import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categoryTotals = _calculateCategoryTotals(provider.expenses);
    final totalSpent = provider.totalSpent;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Distribución de Gastos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child:
                  categoryTotals.isEmpty
                      ? const Center(child: Text('No hay datos suficientes'))
                      : PieChart(
                        PieChartData(
                          sections:
                              categoryTotals.entries.map((entry) {
                                final percentage =
                                    (entry.value / totalSpent) * 100;
                                return PieChartSectionData(
                                  color: _getColorForCategory(entry.key),
                                  value: entry.value,
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
            ),
            const SizedBox(height: 24),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  categoryTotals.keys.map((category) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: _getColorForCategory(category),
                        ),
                        const SizedBox(width: 4),
                        Text(category),
                      ],
                    );
                  }).toList(),
            ),
            const SizedBox(height: 32),
            // Insight Card
            Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Insight',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _generateInsight(
                        categoryTotals,
                        provider.budget,
                        totalSpent,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List expenses) {
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Autobús':
        return Colors.blue;
      case 'Taxi/Uber':
        return Colors.orange;
      case 'Metro':
        return Colors.red;
      case 'Colectivo':
        return Colors.green;
      case 'Gasolina':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _generateInsight(
    Map<String, double> totals,
    double budget,
    double totalSpent,
  ) {
    if (budget > 0 && totalSpent > budget) {
      return '¡Alerta! Has excedido tu presupuesto de \$${budget.toStringAsFixed(0)}. Considera ajustar tus viajes para la próxima semana.';
    }

    if (budget > 0 && totalSpent > (budget * 0.8)) {
      return 'Ten cuidado, ya has gastado el ${(totalSpent / budget * 100).toStringAsFixed(0)}% de tu presupuesto.';
    }

    final taxiSpent = totals['Taxi/Uber'] ?? 0;
    if (taxiSpent > 100) {
      return 'Esta semana gastaste \$$taxiSpent en taxis. Si hubieras usado camión, habrías ahorrado aproximadamente \$${(taxiSpent * 0.8).toStringAsFixed(0)}.';
    } else if (totals.isEmpty) {
      return 'Registra tus gastos para obtener consejos de ahorro.';
    } else {
      return '¡Vas bien! Mantén tus gastos de transporte bajo control.';
    }
  }
}
