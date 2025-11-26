import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/new_property_screen.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';

class PropertiesScreen extends StatelessWidget {

  final String versionId;

  final _scafoldKey = GlobalKey<ScaffoldState>();
  PropertiesScreen({super.key, required this.versionId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scafoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Propriedades cadastradas", style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2),
              maxLines: 2,
              textAlign: TextAlign.center,
          ),
          centerTitle: true,
          actions: [
            const TipIconButton(title: "Cadastro de propriedades", tip: TipsResourse.PROPERTIES)
          ],
        ),
        backgroundColor: Colors.black,
        body: Consumer<UserProvider>(
          builder: (context, userProvider, Widget? child) {
            
            List<Property> properties = []; 
            if (userProvider.user!.propertiesVersion != null) {
                // Se a chave não existir no mapa, use uma lista vazia []
                properties = userProvider.user?.propertiesVersion![versionId] ?? [];
            }

            if(userProvider.isLoading){
              return const Center(child: CircularProgressIndicator());
            }
            
            return Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewPropertyScreen(
                          versionId: versionId,
                        )));
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Theme.of(context).primaryColor,
                        shadowColor: Theme.of(context).primaryColor,
                        elevation: 10,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
                
                // Lista de Propriedades (Expandida para ocupar o espaço restante)
                Expanded(
                  child:  ListView.builder(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            return _propertyTile(context, properties[index]);
                          }),
                ),
              ],
            );
          })
    );
  }

  Widget _propertyTile(BuildContext context, Property property){
    // Usar Provider.of com listen: false fora do build principal está OK aqui
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      height: 210.0,
      decoration: BoxDecoration(
        color: property.colorSignature,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          color: property.colorSignature,
        ),
        child: Stack(
          children: <Widget>[
            Row(
              spacing: 5,
              children: [
                Icon(property.iconSignature.icon),
                Text( property.name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 21
                  ) ,
                )
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // Informações adicionais
                "Valor inicial: ${StringUtils.currencyFormat(property.basePrice)} | "
                "Aluguel inicial: ${StringUtils.currencyFormat(property.currentRent)}",
                style: const TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botão de Usar/Selecionar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: property.colorSignature.withValues(alpha: 0.3),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPropertyScreen(property: property, versionId: versionId)));
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                    // Botão de Excluir
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: property.colorSignature.withValues(alpha: 0.3),
                      ),
                      onPressed: () async {
                        showDialog(context: context, builder: (BuildContext context){
                          return ConfirmActionDialog(
                            title: "Alerta de Exclusão!",
                            textContent: "Essa ação não poderá ser desfeita",
                            onConfirm: () async {
                              Navigator.pop(context);
                              try{
                                userProvider.deleteProperty(versionId, property.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Propriedade excluída."), backgroundColor: Colors.green));
                              } on Exception catch(e){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                              }
                            });
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
