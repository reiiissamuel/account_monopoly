/* import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/domain/model/auction.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';

class SetAuctionScreen extends StatefulWidget {
  const SetAuctionScreen({super.key});

  @override
  SetAuctionScreenState createState() => SetAuctionScreenState();
}

class SetAuctionScreenState extends State<SetAuctionScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late GameProvider gameProvider;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    gameProvider = Provider.of<GameProvider>(context);
    return PopScope(
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Preparar Leilão",
                  style: TextStyle(letterSpacing: 2)),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            backgroundColor: Colors.black,
            body: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 3.0),
                                          borderRadius: BorderRadius.all(Radius.circular(20))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 5.0
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(20))
                                      ),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red)),
                                      hintText:
                                      "Digite o nome da propriedade"),
                                  keyboardType: TextInputType.text,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return "Este campo deve ser preenchido!";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 5.0
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(20))
                                      ),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red)),
                                      hintText: "Lance inicial"),
                                  keyboardType: TextInputType.number,
                                  validator: (text) {
                                    RegExp equal = RegExp(r'^[.0-9]+$');
                                    RegExp equal2 =
                                    RegExp(r'^((?!\.{2}|^\.|\.$).)+$');
                                    if (text == null ||
                                        !equal.hasMatch(text) ||
                                        !equal2.hasMatch(text) ||
                                        text.isEmpty) {
                                      return "Este campo só aceita números e ponto!";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32.0),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0)),
                                          backgroundColor: Theme.of(context).primaryColor,
                                        ),
                                        onPressed:() {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Voltar",
                                            style: TextStyle(
                                              color: Colors.white,
                                                fontSize: 17.0,
                                                letterSpacing: 2))),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                20.0)),
                                        backgroundColor: Theme.of(context).primaryColor
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          Auction auction = Auction(
                                              id: StringUtils.generateUUID(size: 7),
                                              auctionCaller: gameProvider.gameModelDTO!.player.username,
                                              propertyName: _nameController.text,
                                              startValue: int.parse(_priceController.text.replaceAll(".", "")),
                                              endValue: 0,
                                              currentValue: 0,
                                              mortgageId: ''
                                          );
                                          gameProvider.eventComposer(type: EventType.AUCTION_START, auction: auction);
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Text("Iniciar Leilão",
                                          style: TextStyle(
                                            color: Colors.white,
                                              fontSize: 17.0,
                                              letterSpacing: 2)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            )));
  }
}
 */