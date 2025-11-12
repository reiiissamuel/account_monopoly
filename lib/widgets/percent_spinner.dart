import 'package:flutter/material.dart';

// Este widget é um marcador de porcentagem com um botão de incremento.
class PercentSpinner extends StatefulWidget {
  // Callback para notificar o widget pai sobre a mudança de valor
  final ValueChanged<int> onChanged;
  final int initialValue;
  final int step;
  final int maxValue;
  final String label;

  const PercentSpinner({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    this.step = 5,
    this.maxValue = 100,
    this.label = 'Porcentagem',
  });

  @override
  State<PercentSpinner> createState() => _PercentSpinnerState();
}

class _PercentSpinnerState extends State<PercentSpinner> {
  // Estado interno para armazenar a porcentagem atual
  late int _currentPercentage;

  @override
  void initState() {
    super.initState();
    _currentPercentage = widget.initialValue.clamp(0, widget.maxValue);
  }

  // Método para aumentar a porcentagem
  void _increasePercentage() {
    setState(() {
      final newValue = _currentPercentage + widget.step;
      // Garante que o novo valor não exceda o máximo (100%)
      if (newValue <= widget.maxValue) {
        _currentPercentage = newValue;
        widget.onChanged(_currentPercentage);
      } else {
        // Opcional: define para o máximo se tentar ultrapassar
        _currentPercentage = widget.maxValue;
        widget.onChanged(_currentPercentage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definindo o tema de cores
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rótulo
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. MARCADOR DE PORCENTAGEM (DISPLAY)
              Container(
                width: 120, // Largura fixa para o texto
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                ),
                child: Text(
                  '$_currentPercentage%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              
              // 2. BOTÃO DE INCREMENTO
              ElevatedButton.icon(
                onPressed: _currentPercentage < widget.maxValue
                    ? _increasePercentage
                    : null, // Desativa o botão quando atinge o máximo
                icon: const Icon(Icons.add_rounded, size: 24),
                label: Text(
                  '+${widget.step}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, 
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
          
          // Opcional: Slider para um controle mais visual (se o passo for 5)
          Slider(
            activeColor: Colors.white,
            value: _currentPercentage.toDouble(),
            min: 0,
            max: widget.maxValue.toDouble(),
            divisions: widget.maxValue ~/ widget.step, // 20 divisões (100/5)
            label: '$_currentPercentage%',
            onChanged: (double newValue) {
              setState(() {
                // Arredonda para o múltiplo mais próximo do step (5)
                final snappedValue = (newValue / widget.step).round() * widget.step;
                _currentPercentage = snappedValue.toInt().clamp(0, widget.maxValue);
                widget.onChanged(_currentPercentage);
              });
            },
          ),
        ],
      ),
    );
  }
}