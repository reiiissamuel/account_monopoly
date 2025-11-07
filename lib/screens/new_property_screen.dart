import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart'; 

class NewPropertyScreen extends StatelessWidget {
  const NewPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Nova Propriedade'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: const PropertyRegistrationForm(),
    );
  }
}

class PropertyRegistrationForm extends StatefulWidget {
  const PropertyRegistrationForm({super.key});

  @override
  State<PropertyRegistrationForm> createState() => _PropertyRegistrationFormState();
}

class _PropertyRegistrationFormState extends State<PropertyRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Variáveis para armazenar os valores dos campos
  String _name = '';
  double _basePrice = 0.0;
  String _versionid = '';
  PropertyType _propertyType = PropertyType.stocks; // Valor inicial
  Color _colorSignature = Colors.grey; // Valor inicial
  Icon _iconSignature = Icon(Bootstrap.building); // Valor inicial
  String _propertyId = '';

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
    Colors.lime
  ];

  final List<Icon> availableIcons = [
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

  // Helper para criar TextFormFields para texto (String)
  Widget _buildField({required String label, required ValueChanged<dynamic> onSave, required TextInputFormatter inputType, required String alertMsg, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        maxLength: maxLength,
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
        inputFormatters: [
          inputType,
          FilteringTextInputFormatter.singleLineFormatter
        ],
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
  // 💡 Assumindo que 'availableIcons' é uma List<IconData>
  final List<IconData> availableIcons = [
    Icons.home,
    Icons.business,
    Icons.train,
    Icons.local_shipping,
    Icons.apartment,
    Icons.airport_shuttle,
  ];

  // 💡 Assumindo que '_iconSignature' é um IconData? (o ícone atualmente selecionado)
  IconData? _iconSignature = Icons.home; // Exemplo de estado inicial

  // Lógica de setState e Color/Border (simplificada para demonstração)
  void setState(VoidCallback fn) {
    // No ambiente de produção do Flutter, isso atualizará o widget
    fn();
  }

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
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final icon = availableIcons[index]; 
            final isSelected = _iconSignature == icon; 
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _iconSignature = icon;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade700, 
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent, 
                    width: 3,
                  ),
                ),
                child: Icon(
                  icon,
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
  Widget _buildTypeDropdown() {
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
        value: _propertyType,
        style: const TextStyle(color: Colors.white),
        items: PropertyType.values.map((PropertyType type) {
          return DropdownMenuItem<PropertyType>(
            value: type,
            child: Text(
              type.toString().split('.').last, // Exibe apenas o nome do enum
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

        // Crie o objeto Property (Assumindo que a classe Property está acessível)
        final newProperty = Property(
          id: _propertyId,
          name: _name,
          basePrice: _basePrice,
          colorSignature: _colorSignature,
          propertyType: _propertyType,
          iconSignature: _iconSignature
        );
        
        Provider.of<UserProvider>(context, listen: false).newProperty(_versionid, newProperty);

        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Propriedade "$_name" registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on Exception catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na tentativa de cadastro: ${e.toString()}'),
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
              inputType: FilteringTextInputFormatter.allow(RegExp(r'[\w \s]')),
              alertMsg: "Nome sem caracteres especiais"
            ),
            _buildField(
              label: 'Nome da Propriedade', 
              onSave: (value) => _name = value,
              inputType: FilteringTextInputFormatter.allow(RegExp(r'[\w \s]')),
              alertMsg: "Nome sem caracteres especiais"
            ),
            _buildField(
              label:'Escolha um código de 4 letras', 
              onSave:(value) => _propertyId = value,
              inputType: FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
              alertMsg: 'O código deve ter 4 letras maiúsculas',
              maxLength: 4
            ),
            _buildTypeDropdown(),

            _propertyType == PropertyType.stocks ? _buildColorSelector() : _buildIconSelector(),
          
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
              inputType:  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              alertMsg: "insira um número válido"
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Cadastrar Propriedade'),
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
