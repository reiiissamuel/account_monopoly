import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/domain/enums/tutorial_item_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/utils/tutorial_manager.dart';
import 'package:account_monopoly/widgets/counter_stepper.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:account_monopoly/utils/tutorial_fake_objetcs.dart';

class PayRentDialog extends StatefulWidget {
  final GameProvider provider;
  final List<Property> properties;
  const PayRentDialog({super.key, required this.properties, required this.provider});

  @override
  State<PayRentDialog> createState() => _PayRentDialogState();
}

class _PayRentDialogState extends State<PayRentDialog> {
  
  final _payRentDialogTutorialManager = TutorialManager.payRentDialog();
  late Property _selectedProperty;
  List<Property> _properties = [];
  late GameProvider _provider;
  int _multiplier = 2; 
  late double _rentToPay;

  final int _minMultiplier = 2; 

  @override
  void initState() {
    super.initState();
    _provider = widget.provider;
    _loadProperties();
  }

  // Filtra apenas as propriedades que já foram compradas (onde availableShares < totalShares)
  void _loadProperties() {
    _properties = widget.properties
        .where((property) => property.availableShares < property.totalShares)
        .toList();

    if (_properties.isNotEmpty) {
      _selectedProperty = _properties.first;
      _multiplier = _minMultiplier;
      _rentToPay = _calculateRent(_selectedProperty, _multiplier);
    }
  }

  double _calculateRent(Property property, int multiplier) {
    if (property.propertyType == PropertyType.reit) {
      return property.currentRent;
    } else if (property.propertyType == PropertyType.stocks) {
      return property.currentRent * multiplier;
    }
    return property.currentRent;
  }

  void _updateRentToPay() {
    setState(() {
      _rentToPay = _calculateRent(_selectedProperty, _multiplier);
    });
  }

  @override
  Widget build(BuildContext context) {

    return ShowCaseWidget(
      // descarta a fake e volta às propriedades reais
      onFinish: () {
        if (mounted) setState(_loadProperties);
      },
      builder: (showCaseContext) {

      if (!_provider.isPayRentDialogOnBoarded) {
        _provider.userModelController
            .setOnBoardedOnScreen(isPayRentDialogOnBoarded: true);

        // O multiplicador só existe em propriedades stocks. Sem uma delas, o passo
        // do multiplicador ficaria sem alvo, então entra a fake.
        if (!_properties.any((p) => p.propertyType == PropertyType.stocks)) {
          _properties.insert(0, TutorialFakeObjects.getFakeProperty());
        }
        _selectedProperty = _properties.firstWhere((p) => p.propertyType == PropertyType.stocks);
        _multiplier = _minMultiplier;
        _rentToPay = _calculateRent(_selectedProperty, _multiplier);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _payRentDialogTutorialManager.startTutorial(showCaseContext);
        });
      }

      final bool hasValidProperties = _properties.isNotEmpty;
      final Widget title = Row(
        children: [
          // espaço do tamanho do botão para manter o título centralizado
          const SizedBox(width: 36),
          const Expanded(
            child: Text(
              "💸 Pagamento de aluguel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
          child: SizedBox(
            height: 20.0,
            width: 20.0,
            child: Icon(Icons.question_mark_rounded, color: Theme.of(context).colorScheme.onInverseSurface)
          ),
          onTap: (){
            _provider.userModelController
                        .setOnBoardedOnScreen(isPayRentDialogOnBoarded: false);
            setState(() {}); // o dialog não escuta o provider, então reconstrói localmente
          })
        ],
      );

      final Widget content = hasValidProperties
            ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Divider(color: Colors.white70),
                const SizedBox(height: 10),
                _payRentDialogTutorialManager.buildShowcase(
                  type: TutorialItemType.payRentDialogList,
                  child: DropdownButtonFormField<Property>(
                    key: ValueKey(_selectedProperty.id),
                    initialValue: _selectedProperty,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Propriedade",
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 5.0),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.blueGrey, width: 3.0),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.blueGrey, width: 3.0),
                      ),
                    ), 
                    dropdownColor: Colors.black,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.0,
                    ),
                    items: _properties.map<DropdownMenuItem<Property>>((Property property) {
                      return DropdownMenuItem<Property>(
                                value: property,
                        child: Text(property.name, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                ),
                const SizedBox(height: 20),
                if (_selectedProperty.propertyType == PropertyType.stocks) 
                  _payRentDialogTutorialManager.buildShowcase(
                    type: TutorialItemType.valueRentMultiplier,
                    child: CounterStepper(
                      title: 'Multiplicador',
                      minValue: _minMultiplier, 
                      maxValue: 12,
                      onChanged: (value) {
                        setState(() {
                          _multiplier = value;
                          _updateRentToPay();
                        });
                      }, 
                    )
                  ),
                _selectedProperty.propertyType != PropertyType.stocks 
                    ? const SizedBox(height: 5) 
                    : const SizedBox(height: 20),
                _payRentDialogTutorialManager.buildShowcase(
                  type: TutorialItemType.valueRentViewer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Valor do aluguel:", 
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            StringUtils.currencyFormat(_rentToPay),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 17),
                const Divider(color: Colors.white70),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_empty_outlined, size: 60.0, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    "Não há propriedades compradas disponíveis para pagar aluguel.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );

      final List<Widget> actions = <Widget>[
          TextButton(
          child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
        ),
        if (hasValidProperties)
          ElevatedButton(
            child: Text("Pagar Aluguel", style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              try {
                double rentToPay = _calculateRent(_selectedProperty, _multiplier);

                _provider.eventComposer(
                  type: EventType.payRent,
                  propertyId: _selectedProperty.id,
                  price: rentToPay,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pagamento realizado"), backgroundColor: Colors.green),
                );
              } on DomainException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message), backgroundColor: Colors.red),
                );
              }

              Navigator.pop(context);
            },
          ),
        ];

      // Dialog em vez de AlertDialog: o AlertDialog mede o conteúdo por dimensões
      // intrínsecas, e o Showcase usa LayoutBuilder, que não suporta isso.
      return Dialog(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: 16),
                Flexible(child: SingleChildScrollView(child: content)),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}