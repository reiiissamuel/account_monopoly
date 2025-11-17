import 'package:flutter/material.dart';

class CounterStepper extends StatefulWidget{

  final ValueChanged<int> onChanged;
  final String title;
  final int maxValue;
  final int minValue;

  const CounterStepper({super.key, required this.title, required this.onChanged, required this.maxValue, required this.minValue});

  @override
  State<CounterStepper> createState() => _CounterStepperState();
}

class _CounterStepperState extends State<CounterStepper> {

  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.minValue;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: 185,
          height: 73,
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(40)
          ),
          child: Column(
            children: [
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed:()=> _updateCounter(-1), icon: const Icon(Icons.remove, size: 35, color: Colors.white)),
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    radius: 20,
                    child: Text(_value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  ),
                  IconButton(onPressed: ()=>_updateCounter(1), icon: const Icon(Icons.add, size: 35, color: Colors.white)),
                ],
              )
            ],
          ),
        ),
      );
  }

  void _updateCounter(int value){
    final newValue = _value + value;
    if(newValue > widget.maxValue || newValue < widget.minValue) return;
    setState(() {
      _value = newValue;
    });
    widget.onChanged(_value);
  }
}