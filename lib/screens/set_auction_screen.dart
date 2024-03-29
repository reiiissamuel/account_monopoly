import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dto/auction.dart';
import '../enums/log_msg_type.dart';
import '../model/game_model.dart';

class SetAuctionScreen extends StatefulWidget {
  const SetAuctionScreen({super.key});

  @override
  SetAuctionScreenState createState() => SetAuctionScreenState();
}

class SetAuctionScreenState extends State<SetAuctionScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: ScopedModelDescendant<GameModelController>(
          builder: (context, child, model) {
            return Scaffold(
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
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
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
                                      },
                                    ),
                                    const SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: _priceController,
                                      decoration: const InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
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
                                      },
                                    ),
                                    const SizedBox(height: 32.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              backgroundColor: Colors.white,
                                            ),
                                            onPressed:() {
                                                    Navigator.of(context).pop();
                                                  },
                                            child: const Text("Voltar",
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    letterSpacing: 2))),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                            backgroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    Auction auction = Auction(
                                                        id: StringUtils.generateUUID(size: 4),
                                                        auctionCaller: model.player.username,
                                                        propertyName: _priceController.text.replaceAll(".", ""),
                                                        startValue: int.parse(_priceController.text.replaceAll(".", "")),
                                                        endValue: 0,
                                                        currentValue: 0
                                                    );
                                                    model.eventComposer(type: LogMsgType.AUCTION_START, auction: auction);
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                          child: const Text("Iniciar Leilão",
                                              style: TextStyle(
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
                ));
          },
        ));
  }
}
