import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import 'historico.dart';
import 'historial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Científica Moderna',
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
          elevation: 1,
          centerTitle: true,
        ),
      ),
      home: MyHomePage(
        title: 'Calculadora Científica Moderna',
        isDarkMode: isDarkMode,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const MyHomePage({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _rawInput = '';
  String _output = '';
  bool showBasic = true;
  final formatter = NumberFormat('#,##0.########', 'en_US');

  void _agregarCaracter(String caracter) {
    setState(() {
      if (caracter == '×') {
        _rawInput += '*';
      } else if (caracter == '÷') {
        _rawInput += '/';
      } else if (caracter == '%') {
        int i = _rawInput.length - 1;
        String lastNumber = '';
        while (i >= 0 && '0123456789.'.contains(_rawInput[i])) {
          lastNumber = _rawInput[i] + lastNumber;
          i--;
        }
        if (lastNumber.isNotEmpty) {
          double num = double.tryParse(lastNumber) ?? 0;
          double porcentaje = num / 100;
          String operadorAnterior = i >= 0 ? _rawInput[i] : '';
          if (['+', '-', '*', '/'].contains(operadorAnterior)) {
            double base = double.tryParse(_rawInput.substring(0, i)) ?? 0;
            porcentaje = base * porcentaje;
          }
          _rawInput = _rawInput.substring(0, i + 1) + porcentaje.toString();
        } else {
          _rawInput += caracter;
        }
      } else {
        _rawInput += caracter;
      }
    });
  }

  void _limpiar() {
    setState(() {
      _rawInput = '';
      _output = '';
    });
  }

  void _borrar() {
    setState(() {
      if (_rawInput.isNotEmpty) {
        _rawInput = _rawInput.substring(0, _rawInput.length - 1);
      }
    });
  }

  void _calcular() {
    try {
      Parser p = Parser();
      String expression = _rawInput
          .replaceAll('π', '3.1416')
          .replaceAll('e', '2.7183')
          .replaceAll('√', 'sqrt');
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double resultado = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _output = formatter.format(resultado);
        historialDeResultados.add('${_formattedInput} = $_output');
      });
    } catch (e) {
      setState(() {
        _output = 'Error';
      });
    }
  }

  String get _formattedInput {
    final regex = RegExp(r'(\d+(\.\d+)?|\D+)');
    Iterable<RegExpMatch> matches = regex.allMatches(_rawInput);
    StringBuffer buffer = StringBuffer();

    for (final match in matches) {
      String token = match.group(0)!;
      if (RegExp(r'^\d+(\.\d+)?$').hasMatch(token)) {
        try {
          double num = double.parse(token);
          buffer.write(formatter.format(num));
        } catch (_) {
          buffer.write(token);
        }
      } else {
        buffer.write(token);
      }
    }
    return buffer.toString();
  }

  Widget _buildButton(String texto, {Color? color}) {
    final isOperator = [
      'C',
      '⌫',
      '(',
      ')',
      '+',
      '-',
      '×',
      '÷',
      '=',
      '%',
      'sin',
      'cos',
      'tan',
      'log',
      'π',
      'e',
      '^',
      '√',
    ].contains(texto);

    final buttonColor = widget.isDarkMode
        ? (isOperator ? Colors.orange : Colors.grey[900])
        : (isOperator ? Colors.orange : Colors.white);
    final textColor = widget.isDarkMode
        ? Colors.white
        : (isOperator ? Colors.white : Colors.black87);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? buttonColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onPressed: () {
            if (texto == '=') {
              _calcular();
            } else if (texto == 'C') {
              _limpiar();
            } else if (texto == '⌫') {
              _borrar();
            } else {
              _agregarCaracter(texto);
            }
          },
          child: Text(
            texto,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBasicButtons() {
    return [
      Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'Funciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                setState(() {
                  showBasic = !showBasic;
                });
              },
              child: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
          ),
        ],
      ),
      Row(children: [
        _buildButton('C'),
        _buildButton('⌫'),
        _buildButton('(', color: Colors.orange[200]),
        _buildButton(')', color: Colors.orange[200]),
        _buildButton('%', color: Colors.orange),
      ]),
      Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('÷')]),
      Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('×')]),
      Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('-')]),
      Row(children: [_buildButton('0'), _buildButton('.'), _buildButton('+'), _buildButton('=')]),
    ];
  }

  List<Widget> _buildAdvancedButtons() {
    return [
      Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'Funciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                setState(() {
                  showBasic = !showBasic;
                });
              },
              child: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
          ),
        ],
      ),
      Row(children: [_buildButton('sin'), _buildButton('cos'), _buildButton('tan'), _buildButton('log')]),
      Row(children: [_buildButton('π'), _buildButton('e'), _buildButton('^'), _buildButton('√')]),
    ];
  }

  void _goToHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HistoricoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
        centerTitle: true,
        leadingWidth: 200,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: widget.toggleTheme,
            ),
            TextButton(
              onPressed: _goToHistorico,
              child: Text(
                'Histórico',
                style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _formattedInput,
                      style: TextStyle(
                        fontSize: 28,
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _output,
                    style:
                        const TextStyle(fontSize: 32, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          ...?showBasic ? _buildBasicButtons() : _buildAdvancedButtons(),
        ],
      ),
    );
  }
}
