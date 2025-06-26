import 'package:flutter/material.dart';
import 'historial.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: historialDeResultados.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay cálculos realizados.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historialDeResultados.length,
              itemBuilder: (context, index) {
                final item = historialDeResultados[historialDeResultados.length - 1 - index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
