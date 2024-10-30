import 'package:flutter/material.dart';

class PaymentCalculator extends StatefulWidget {
  final void Function(String) onAmountConfirmed;

  const PaymentCalculator({required this.onAmountConfirmed});

  @override
  _PaymentCalculatorState createState() => _PaymentCalculatorState();
}

class _PaymentCalculatorState extends State<PaymentCalculator> {
  String amountReceived = '';
  final TextEditingController _amountController = TextEditingController();

  void _updateAmount(String value) {
    setState(() {
      amountReceived += value;
      _amountController.text = amountReceived;
    });
  }

  void _deleteLast() {
    setState(() {
      if (amountReceived.isNotEmpty) {
        amountReceived = amountReceived.substring(0, amountReceived.length - 1);
        _amountController.text = amountReceived;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display de la cantidad ingresada
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                controller: _amountController,
                readOnly: true,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(children: [
              // Contenedor del teclado
              Expanded(
                flex: 3,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildNumberButton('1'),
                        _buildNumberButton('2'),
                        _buildNumberButton('3'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildNumberButton('4'),
                        _buildNumberButton('5'),
                        _buildNumberButton('6'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildNumberButton('7'),
                        _buildNumberButton('8'),
                        _buildNumberButton('9'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildNumberButton('00'),
                        _buildNumberButton('0'),
                        _buildNumberButton('.'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                      child: Column(
                    children: [
                      _buildSpecialButton(Icons.backspace, _deleteLast),
                      SizedBox(
                        height: 10,
                      ),
                      _buildSpecialButton(Icons.check, () {
                        widget.onAmountConfirmed(amountReceived);
                      })
                    ],
                  )))
            ])
          ],
        ),
      ),
    );
  }

  // Método para construir los botones de números
  Widget _buildNumberButton(String text) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: AspectRatio(
            aspectRatio: 1,
            child: ElevatedButton(
              onPressed: () => _updateAmount(text),
              child: Text(
                text,
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.grey[300],
              ),
            )));
  }

  // Método para construir botones especiales (borrar y confirmar)
  Widget _buildSpecialButton(IconData icon, VoidCallback onPressed) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: AspectRatio(
            aspectRatio: 1,
            child: TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Icon(icon, size: 30),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 40),
                ),
              ),
            )));
  }
}
