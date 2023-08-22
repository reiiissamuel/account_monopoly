import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/user_model.dart';

class NewUserDialog extends StatefulWidget {
  const NewUserDialog({super.key});

  @override
  NewUserDialogState createState() => NewUserDialogState();
}

class NewUserDialogState extends State<NewUserDialog> {
  static const String NAME_HINT_TEXT = "Me diga quem é você.";
  static const String USERNAME_HINT_TEXT = "Defina um apelido.";
  static const String VALIDATION_NAME_ERROR_MSG = "Você precisa definir um nome com mais de 1 caractere.";
  static const String VALIDATION_USERNAME_ERROR_MSG = "Você precisa definir um nome de usuário sem espaço.";

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      child: UserModelController.of(context).isLoading ?
     const Center(child: CircularProgressIndicator()) :
      Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          height: 300.0,
          child: Form(
            key: _formKey,
            //listview para poder das scroll no nos itens
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: NAME_HINT_TEXT),
                  keyboardType: TextInputType.text,
                  validator: (text) {
                    if(text == null || text.isEmpty || text.length < 2) return VALIDATION_NAME_ERROR_MSG;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(hintText: USERNAME_HINT_TEXT),
                  validator: (text) {
                    if(text == null || text.isEmpty|| text.length < 3 || text.contains(" ")) return VALIDATION_USERNAME_ERROR_MSG;
                  },
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black
                      ),
                      onPressed:  () {
                        if (_formKey.currentState!.validate()) {}
                        setState(() {
                          UserModelController.of(context).signUp(
                              name: _nameController.text,
                              username: _usernameController.text,
                              context: context,
                              onSuccess: _onSuccess,
                              onFail: _onFail
                          );
                        });
                      },
                      child: const Text("Prosseguir",
                          style: TextStyle(fontSize: 18.0, color:Colors.white)),
                    ))
              ],
            ),
          ))
    );
  }

  void _onSuccess(String msg, BuildContext context) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Future.delayed(const Duration(seconds: 2)).then((_){
      Navigator.of(context).pop();
    });
  }

  void _onFail(String msg, BuildContext context) {
    Navigator.of(context).pop();
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
