import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/service/google_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';


class NewUserDialog extends StatefulWidget {
  const NewUserDialog({super.key});

  @override
  NewUserDialogState createState() => NewUserDialogState();
}

class NewUserDialogState extends State<NewUserDialog> {

  late UserProvider userProvider;

  static const String NAME_HINT_TEXT = "Me diga seu nome.";
  static const String USERNAME_HINT_TEXT = "Defina um apelido.";
  static const String VALIDATION_NAME_ERROR_MSG = "Você precisa definir um nome com mais de 1 caractere.";
  static const String VALIDATION_USERNAME_ERROR_MSG = "Você precisa definir um nome de usuário sem espaço.";

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      child: userProvider.isLoading ?
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
                  decoration: const InputDecoration(
                    hintText: NAME_HINT_TEXT,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white10, width: 3.0),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white, width: 5.0
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (text) {
                    if(text == null || text.isEmpty || text.length < 2) return VALIDATION_NAME_ERROR_MSG;
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                      hintText: USERNAME_HINT_TEXT,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white10, width: 3.0),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white, width: 5.0
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  ),
                  validator: (text) {
                    if(text == null || text.isEmpty|| text.length < 3 || text.contains(" ")) return VALIDATION_USERNAME_ERROR_MSG;
                    try{
                      userProvider.checkUserExists(text);
                    } on UserExistsException catch(e){
                      return e.message;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                    height: 38.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          )),
                      onPressed:  () async {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          await userProvider.signUp(
                              name: _nameController.text,
                              username: _usernameController.text
                          );
                          userProvider.signIn(userModelDTO: userProvider.allUsers.firstWhere((u) => u.username == _nameController.text));
                        }
                      },
                      child: const Text("Prosseguir",
                          style: TextStyle(fontSize: 14.0, color:Colors.white)),
                    )),
                    
                const SizedBox(height: 16.0),
                SignInButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                  Buttons.Google,
                  text: "Entrar com Google",
                  onPressed: () async {
                    var googleUser = await GoogleLogin.login();
                    /* UserModelController.of(context).signUp(
                      name: googleUser?.displayName,
                      username: googleUser?.displayName,
                      context: context,
                      onSuccess: _onSuccess,
                      onFail: _onFail
                    ); */
                  },
                )
              ],
            ),
          ))
    );
  }
}
