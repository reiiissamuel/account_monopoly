import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart'; 

class NewPropertyScreen extends StatelessWidget {
  final String? versionId;
  final Property? property; 

  const NewPropertyScreen({super.key, this.versionId, this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(versionId == null ? 'Cadastrar Nova Propriedade' : 'Atualizar Propriedade', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          const TipIconButton(title: "Cadastro de propriedades", tip: TipsResourse.PROPERTIES)
        ]
      ),
      backgroundColor: Colors.black,
      body: PropertyRegistrationForm(
        versionId: versionId,
        property: property,
      ),
    );
  }
}

class PropertyRegistrationForm extends StatefulWidget {
  final String? versionId;
  final Property? property;

  const PropertyRegistrationForm({
    super.key, 
    this.versionId,
    this.property,
  });

  @override
  State<PropertyRegistrationForm> createState() => _PropertyRegistrationFormState();
}

class _PropertyRegistrationFormState extends State<PropertyRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Variáveis para armazenar os valores dos campos
  String _name = '';
  String _basePrice = '';
  String _versionid = '';
  PropertyType _propertyType = PropertyType.reit; // Valor inicial
  Color _colorSignature = Colors.grey; // Valor inicial
  Icon _iconSignatureData = const Icon(Bootstrap.building); // Valor inicial
  String _propertyId = '';
  String _rentPrice = '';
  String _buildingCost = '';

  // Lista de cores pré-definidas para seleção
  final List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.yellow,
    Colors.teal,
    Colors.pink,
    Colors.black,
    Colors.white,
    Colors.brown,
    Colors.indigo,
    Colors.cyan,
    Colors.deepPurple,
    Colors.grey,
    Colors.purple,
    Colors.deepPurpleAccent,
    Colors.cyanAccent,
    Colors.lime,
    Colors.blueGrey
  ];

  final List<Icon> availableIconsData = [
    const Icon(Bootstrap.minecart_loaded),
    const Icon(BoxIcons.bx_taxi),
    const Icon(BoxIcons.bx_train),
    const Icon(BoxIcons.bx_bus),
    const Icon(BoxIcons.bxs_tree_alt),
    const Icon(BoxIcons.bx_bolt_circle),
    const Icon(Bootstrap.fuel_pump_fill),
    const Icon(Bootstrap.bank),
    const Icon(Bootstrap.airplane_fill),
    const Icon(Bootstrap.water),
    const Icon(Bootstrap.telephone_fill),
  ];

  @override
  void initState(){
    super.initState();
    _versionid = widget.versionId ?? '';
    if(widget.property != null){
      _name = widget.property!.name;
      _basePrice = StringUtils.currencyFormat(widget.property!.basePrice);
      _propertyType = widget.property!.propertyType;
      _colorSignature = widget.property!.colorSignature;
      _iconSignatureData = widget.property!.iconSignature; // Valor inicial
      _propertyId = widget.property!.id;
      _rentPrice = StringUtils.currencyFormat(widget.property!.currentRent);
      _buildingCost = StringUtils.currencyFormat(widget.property!.currentBuildingCost);
    }
  }

  // Helper para criar TextFormFields para texto (String)
  Widget _buildField({required String label, required ValueChanged<dynamic> onSave, required List<TextInputFormatter> inputsTypes,
   required String alertMsg, bool? enabled, int? maxLength, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        enabled: enabled,
        maxLength: maxLength,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          fillColor: Colors.grey.shade900,
          filled: true,
          hintText: alertMsg,
        ),
        style: const TextStyle(color: Colors.white),
        inputFormatters: inputsTypes,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return alertMsg;
          }
          return null;
        },
        onSaved: (value) {
          if (value != null) {
            onSave(value);
          }
        },
      ),
    );
  }
  
  // Seletor de Cores
  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assinatura de Cor do tabuleiro:',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _colorSignature = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _colorSignature == color ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

   Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icone da propriedade:',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableIconsData.length,
            itemBuilder: (context, index) {
              final iconData = availableIconsData[index]; 
              final isSelected = _iconSignatureData == iconData; 
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _iconSignatureData = iconData; // Armazena IconData
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700, 
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent, 
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    iconData.icon, // Exibe IconData
                    size: 20, 
                    color: Colors.white, 
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  // Dropdown para Tipo de Propriedade
  Widget _buildTypeDropdown({required PropertyType? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<PropertyType>(
        decoration: InputDecoration(
          labelText: 'Tipo de Propriedade',
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          fillColor: Colors.grey.shade900,
          filled: true,
        ),
        dropdownColor: Colors.grey.shade900,
        initialValue: initialValue,
        style: const TextStyle(color: Colors.white),
        items: PropertyType.values.map((PropertyType type) {
          return DropdownMenuItem<PropertyType>(
            value: type,
            child: Text(
              type.description, // Exibe apenas o nome do enum
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (PropertyType? newValue) {
          if (newValue != null) {
            setState(() {
              _propertyType = newValue;
            });
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Selecione o tipo de propriedade.';
          }
          return null;
        },
        onSaved: (newValue) {
          if (newValue != null) {
            _propertyType = newValue;
          }
        },
      ),
    );
  }

  // Lógica de Submissão
  void _submitForm() {
    try{
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        // Crie o objeto Property
        final newProperty = Property(
          id: _propertyId,
          name: _name,
          basePrice: StringUtils.currencyAsDouble(_basePrice),
          colorSignature: _colorSignature,
          propertyType: _propertyType,
          iconSignature: _iconSignatureData,
          currentRent: StringUtils.currencyAsDouble(_rentPrice),
          currentBuildingCost: _propertyType == PropertyType.reit ? StringUtils.currencyAsDouble(_rentPrice) : 0
        );
        
        Provider.of<UserProvider>(context, listen: false).newProperty(_versionid, newProperty);

        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Propriedade "$_name" registrada com sucesso!''Atualização concluída.'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on Exception catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na tentativa de cadastro: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildField(
              label:'Versão do tabuleiro', 
              onSave: (value) => _versionid = value,
              inputsTypes: [
                FilteringTextInputFormatter.allow(RegExp(r'[\w \s \^\~\´\`Ç]'))
              ],
              alertMsg: "Nome sem caracteres especiais",
              initialValue: _versionid,
              enabled: widget.property == null
            ),
            _buildField(
              label: 'Nome da Propriedade', 
              onSave: (value) => _name = value,
              inputsTypes: [
                FilteringTextInputFormatter.allow(RegExp(r'[\w \s \^\~\´\`Ç]'))
              ],
              alertMsg: "Nome sem caracteres especiais",
              initialValue: _name
            ),
            _buildField(
                label:'Escolha um código de 4 letras', 
                onSave:(value) => _propertyId = value,
                inputsTypes: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z]'))
                ],
                alertMsg: 'O código deve ter 4 letras maiúsculas',
                maxLength: 4,
                initialValue: _propertyId,
                enabled: widget.property == null
              )
            ,
            _buildTypeDropdown(initialValue: _propertyType),

            _propertyType == PropertyType.reit ? _buildColorSelector() : _buildIconSelector(),
          
            const Divider(color: Colors.white30, height: 40),
            
            // Campos INICIAIS (Não-finais, mas necessários para instanciar a classe)
            const Text(
              'Valores Iniciais', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Preço Base', 
              onSave: (value) => _basePrice = value,
              inputsTypes:  [
                FilteringTextInputFormatter.digitsOnly,
                StringUtils()
              ],
              alertMsg: "insira um número válido",
              initialValue: _basePrice.toString()
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Aluguel inicial', 
              onSave: (value) => _rentPrice = value, 
              inputsTypes:  [
                FilteringTextInputFormatter.digitsOnly,
                StringUtils()
              ],
              alertMsg: "insira um número válido",
              initialValue: _rentPrice.toString()
            ),
            _propertyType == PropertyType.reit ? 
              _buildField(
                label: 'Custo de construção', 
                onSave: (value) => _buildingCost = value,
                inputsTypes:  [
                  FilteringTextInputFormatter.digitsOnly,
                  StringUtils()
                ],
                alertMsg: "insira um número válido",
                initialValue: _buildingCost.toString()
              ) : const SizedBox(height: 0),
            
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(widget.property == null ? 'Cadastrar Propriedade' : 'Atualizar Propriedade'),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
