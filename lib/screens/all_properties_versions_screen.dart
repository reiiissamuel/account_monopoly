import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/new_property_screen.dart';
import 'package:account_monopoly/screens/properties_screen.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/domain/model/property.dart';

class AllPropertiesVesionsScreen extends StatelessWidget {

  List<Map<String, dynamic>> _getPropertieSummary(UserProvider userprovider) {
    var propertiesResume = <Map<String, dynamic>>[];
    userprovider.user?.propertiesVersion?.forEach((key, values) {
      final List<Property> propertiesList = values.cast<Property>();
      propertiesResume.add(
        Map.from({
          "version": key,
          "properties": propertiesList,
          "size": propertiesList.length.toString(),
          "stocks" : propertiesList.where((value) => value.propertyType == PropertyType.stocks).length.toString(),
          "reits" : propertiesList.where((value) => value.propertyType == PropertyType.reit).length.toString()
        })
      );
    });
    return propertiesResume;
  }


  final _scafoldKey = GlobalKey<ScaffoldState>();
  AllPropertiesVesionsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scafoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Versões Cadastradas",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2
            ),
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
            
            if(userProvider.isLoading){
              return const Center(child: CircularProgressIndicator());
            } 
            
            final List<Map<String, dynamic>> summary = _getPropertieSummary(userProvider);
            
            return Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPropertyScreen()));
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
                  child: summary.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhuma lote de propriedades cadastrado.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: summary.length,
                          itemBuilder: (context, index) {
                            return _gameTile(context, summary[index]);
                          }),
                ),
              ],
            );
          })
    );
  }

  Widget _gameTile(BuildContext context, Map<String, dynamic> summary){
    // Usar Provider.of com listen: false fora do build principal está OK aqui
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      height: 210.0,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: .3),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          color: Theme.of(context).primaryColor,
        ),
        child: Stack(
          children: <Widget>[
            Text(
              'Versão: ${summary["version"]}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // Informações adicionais
                "${summary["size"]} propriedades cadastradas\n"
                "${summary["stocks"]} Ações | ${summary["reits"]} FIIs",
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
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .3),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PropertiesScreen(versionId: summary["version"])));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 40.0,
                        ),
                      ),
                    ),
                    // Botão de Excluir
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .3),
                      ),
                      onPressed: () async {
                        showDialog(context: context, builder: (BuildContext context){
                          return ConfirmActionDialog(
                            title: "Alerta de Exclusão!",
                            textContent: "Essa ação não poderá ser desfeita",
                            onConfirm: () async {

                              Navigator.pop(context);
                              try {
                                userProvider.deletePropertiesCollection(
                                    summary["version"]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Exclusão realizada com sucesso."), backgroundColor: Colors.green));
                              } on Exception{
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Erro interno ao tentar efetuar a exclusão."), backgroundColor: Colors.red));
                              }
                            });
                        });
                      },
                      child: const Padding(
                          padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40.0,
                        ),
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
