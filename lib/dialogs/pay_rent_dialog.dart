import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/widgets/counter_stepper.dart';
import 'package:flutter/material.dart';

class PayRentDialog extends StatefulWidget{
  final GameProvider provider;
  final List<Property> properties;
  const PayRentDialog({super.key, required this.properties, required this.provider});

  @override
  State<PayRentDialog> createState() => _PayRentDialogState();
}

class _PayRentDialogState extends State<PayRentDialog> {
  
  late Property _selectedProperty;
  List<Property> _properties = [];
  late GameProvider _provider;
  // Multiplicador inicial, deve corresponder ao minValue do CounterStepper
  int _multiplier = 2; 
  late double _rentToPay;

  static const int _minMultiplier = 2; 

  @override
  void initState() {
    super.initState();
    _properties = widget.properties;
    if(_properties != null && _properties.isNotEmpty) {
      _selectedProperty = _properties.first;
      _rentToPay = _calculateRent(_selectedProperty, _multiplier);
    }
    _provider = widget.provider;
  }
  
  // Função auxiliar para calcular o aluguel baseado no tipo de propriedade e multiplicador
  double _calculateRent(Property property, int multiplier) {
    if (property.propertyType == PropertyType.reit) {
      // REIT: aluguel é igual ao currentRent
      return property.currentRent;
    } else if (property.propertyType == PropertyType.stocks) {
      // STOCKS: aluguel é currentRent * multiplicador
      return property.currentRent * multiplier;
    }
    // Caso padrão para outros tipos, se existirem
    return property.currentRent;
  }

  // Atualiza _rentToPay usando a função de cálculo e o estado atual
  void _updateRentToPay(){
    setState((){
      _rentToPay = _calculateRent(_selectedProperty, _multiplier);
    });
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("💸 Pagamento de alugel",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,),
          content: (_properties != null && _properties.isNotEmpty)
              ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.white70),
              const SizedBox(height: 10),
              // Dropdown para selecionar a Propriedade
              DropdownButtonFormField<Property>(
                  initialValue: _selectedProperty, // Use 'value' em vez de 'initialValue' para um StatefullWidget
                  decoration: InputDecoration(
                    labelText: "Propriedade",
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.0,
                    ),
                    prefixIcon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white, width: 5.0
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.blueGrey, width: 3.0
                      )
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colors.blueGrey, width: 3.0
                      )
                    ),
                  ), 
                  dropdownColor: Colors.black, // Cor do menu dropdown para visibilidade
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0),
                  items: _properties.map<DropdownMenuItem<Property>>((Property property) {
                    return DropdownMenuItem<Property>(
                      value: property,
                      child: Text(property.name),
                    );
                  }).toList(),
                  onChanged: (Property? newProperty) {
                    if (newProperty != null) {
                      setState(() {
                        _selectedProperty = newProperty;
                        _multiplier = _minMultiplier; 
                        _updateRentToPay();
                      });
                    }
                  },
              ),
              const SizedBox(height: 20),
              if (_selectedProperty.propertyType == PropertyType.stocks) 
                CounterStepper(
                  title: 'Multiplicador',
                  minValue: _minMultiplier, 
                  maxValue: 12,
                  // Captura o valor do Stepper e atualiza o estado e o aluguel
                  onChanged: (value) {
                    setState(() {
                      _multiplier = value;
                      _updateRentToPay();
                    });
                  }, 
                ),
              _selectedProperty.propertyType != PropertyType.stocks 
                ? const SizedBox(height: 5) 
                : const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Valor do alugel:", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .5),),
                    ),
                    child: Padding(
                       padding: const EdgeInsets.all(5.0),
                       child: Text(
                        (StringUtils.currencyFormat(_rentToPay)),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 17),
              //const Center(child: TipIconButton(title: "Construções", tip: TipsResourse.BUILDINGS, width: 25.0, height: 25.0, iconSize: 19.0)),
              const Divider(color: Colors.white70),
            ],
          ) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty_outlined, size: 60.0, color: Colors.white),
                const SizedBox(height: 10),
                Text("Não há propriedades cadastradas neste jogo.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),

            if(_properties != null && _properties.isNotEmpty) ...[
              ElevatedButton(
                child: Text("Pagar Aluguel", style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  try{
                    double rentToPay = _calculateRent(_selectedProperty, _multiplier);

                     _provider.eventComposer(
                      type: EventType.payRent,
                      propertyId: _selectedProperty.id,
                      price: rentToPay
                    );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pagamento realizado"), backgroundColor: Colors.green));
                  } on DomainException catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                  }

                  Navigator.pop(context);
                },
              )
            ]
          ],
    );
  }
}