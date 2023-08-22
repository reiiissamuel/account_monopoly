import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/user_model.dart';
import '../repository/user_repository.dart';
import 'new_user_dialog.dart';

class LoadUserDialog extends StatefulWidget {
  const LoadUserDialog({super.key});


  @override
  LoadUserDialogState createState() => LoadUserDialogState();
}

class LoadUserDialogState extends State<LoadUserDialog> {
  List<String> _localUsersNames = [];
  String? _dropdownValue = "";
  UserRepository userRepository =  GetIt.I.get();

  static const String CREATE_USER_LABEL = "Criar novo usuário";
  static const String SELECT_ONEOF_LABEL = "Selecionar";


  @override
  Widget build(BuildContext context) {
    _localUsersNames = UserModelController.of(context).allUsers!.map((user) => user.username).toList();
    _localUsersNames.add(CREATE_USER_LABEL);
    _localUsersNames.add(SELECT_ONEOF_LABEL);
    _dropdownValue = _localUsersNames.last;
    return Dialog(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)),
      child: UserModelController.of(context).isLoading ?
      const SizedBox(height: 30, child: Center(child: Text("Carregando...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),))) :
      SizedBox(
        height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Quem está aí?",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              DropdownButton<String>(
                value: _dropdownValue,
                icon: const Icon(Icons.arrow_downward, color: Colors.white),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    _dropdownValue = value;
                    if (_dropdownValue == CREATE_USER_LABEL) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const NewUserDialog();
                        },
                      ).whenComplete(() => Navigator.pop(context));// Mova o Navigator.pop para cá
                    } else if (_dropdownValue != SELECT_ONEOF_LABEL) {
                      UserModelController.of(context).signIn(
                        userModelDTO: UserModelController.of(context).allUsers!.firstWhere((u) => u.username == _dropdownValue),
                      );
                      Navigator.of(context).pop(); // Mova o Navigator.pop para cá
                    }
                  }
                  );
                },
                items: _localUsersNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              )
            ],
          )
      ));
  }
}
