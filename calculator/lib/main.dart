import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
  
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool isArithmeticMode = true;
  String input = '';
  String output = '';
  String fromBase = 'DEC';
  String toBase = 'BIN';

  final List<String> arithmeticButtons = [
    'C', '/', '*', '-',
    '7', '8', '9', '+',
    '4', '5', '6', '=',
    '1', '2', '3', '.',
    'AC', '0', '<'
  ];

  final List<String> bases = ['BIN', 'OCT', 'DEC', 'HEX'];

  void _onButtonPressed(String value) {
  setState(() {
    if (value == 'C') {
      input = '';
      output = '';
      justCalculated = false;
    } else if (value == '<') {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    } else if (value == '=') {
      try {
        if (isArithmeticMode) {
          Parser p = Parser();
          Expression exp = p.parse(input);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          output = eval.toString().endsWith('.0')
              ? eval.toStringAsFixed(0)
              : eval.toString();
        } else {
          int num = int.parse(input, radix: _getRadix(fromBase));
          output = num.toRadixString(_getRadix(toBase)).toUpperCase();
        }
        justCalculated = true;
      } catch (e) {
        output = 'Error';
      }
    } else {
      if (justCalculated) {
        if (isArithmeticMode &&
            (value == '+' || value == '-' || value == '*' || value == '/')) {
          input = output + value;
        } else {
          input = value;
        }
        output = '';
        justCalculated = false;
      } else {
        // prevent multiple decimal points in a number
        if (value == '.' && input.isNotEmpty) {
          final lastToken = input.split(RegExp(r'[+\-*/]')).last;
          if (lastToken.contains('.')) return;
        }
        input += value;
      }
    }
  });
}


  int _getRadix(String base) {
    switch (base) {
      case 'BIN':
        return 2;
      case 'OCT':
        return 8;
      case 'DEC':
        return 10;
      case 'HEX':
        return 16;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 50), // Move navigation down
          SwitchListTile(
            title: Text(isArithmeticMode ? 'Arithmetic Mode' : 'Conversion Mode'),
            value: isArithmeticMode,
            onChanged: (bool value) {
              setState(() {
                isArithmeticMode = value;
                input = '';
                output = '';
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                input,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                output,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ),
          if (!isArithmeticMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: fromBase,
                  items: bases.map((String base) {
                    return DropdownMenuItem<String>(
                      value: base,
                      child: Text(base),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      fromBase = newValue!;
                    });
                  },
                ),
                Icon(Icons.arrow_right_alt),
                DropdownButton<String>(
                  value: toBase,
                  items: bases.map((String base) {
                    return DropdownMenuItem<String>(
                      value: base,
                      child: Text(base),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      toBase = newValue!;
                    });
                  },
                ),
              ],
            ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Four buttons per row
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: arithmeticButtons.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _onButtonPressed(arithmeticButtons[index]),
                  child: Text(
                    arithmeticButtons[index],
                    style: TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
