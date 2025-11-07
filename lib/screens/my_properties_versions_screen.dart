import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/new_property_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/domain/model/property.dart'; // Import assumido para 'Property'

class MyPropertiesVesionsScreen extends StatelessWidget {

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
  MyPropertiesVesionsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scafoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Propriedades cadastradas", style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2)),
          centerTitle: true,
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: GestureDetector(
                    child: const Icon(Icons.question_mark_rounded, color: Colors.white),
                    onTap: () => {}))
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
      decoration: const BoxDecoration(
        color: Color(0xff0087a8),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Ação para carregar a versão
                        Fluttertoast.showToast(
                           msg: "Carregando ${summary["version"]}...",
                           backgroundColor: Colors.blueAccent,
                        );
                        // Exemplo: userProvider.loadProperties(summary["version"]);
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                        size: 50.0,
                      ),
                    ),
                    // Botão de Excluir
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        showDialog(context: context, builder: (BuildContext context){
                          return ConfirmActionDialog(
                            title: "Alerta de Exclusão!",
                            textContent: "Essa ação não poderá ser desfeita",
                            onConfirm: () async {
                              userProvider.deleteProperties(summary["version"]);
                              // A navegação/fechamento do diálogo deve ser aqui,
                              // mas como o `ConfirmActionDialog` geralmente faz isso internamente,
                              // mantemos apenas o toast e a ação do provider.
                              Fluttertoast.showToast(
                                  msg: "Lote de propriedades excluído com sucesso",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            });
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
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
