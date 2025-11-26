import 'package:account_monopoly/dialogs/new_user_dialog.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadUserDialog extends StatefulWidget {
  const LoadUserDialog({super.key});

  @override
  LoadUserDialogState createState() => LoadUserDialogState();
}

class LoadUserDialogState extends State<LoadUserDialog> {
  String? _dropdownValue;

  static const String CREATE_USER_LABEL = "Criar novo usuário";
  static const String SELECT_ONEOF_LABEL = "Selecionar";

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    List<String> displayUsernames = userProvider.allUsers.map((user) => user.username).toList();
    displayUsernames.insert(0, CREATE_USER_LABEL);
    displayUsernames.insert(0, SELECT_ONEOF_LABEL);

    // Garante que _dropdownValue seja um valor válido da nova lista
    if (_dropdownValue == null || _dropdownValue!.isEmpty  || !displayUsernames.contains(_dropdownValue)) {
      _dropdownValue = SELECT_ONEOF_LABEL;
    }

    // Filtramos os itens que devem ter o botão de exclusão
    final List<String> selectableUsers = displayUsernames.where((name) =>
      name != CREATE_USER_LABEL && name != SELECT_ONEOF_LABEL
    ).toList();

    return Dialog(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)),
        child: userProvider.isLoading
            ? const SizedBox(
            height: 30,
            child: Center(
                child: Text(
                    "Carregando...",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                )
            )
        )
            : SizedBox(
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
                    setState(() {
                      _dropdownValue = value;
                      if (_dropdownValue == CREATE_USER_LABEL) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const NewUserDialog();
                          },
                        );
                      } else if (_dropdownValue != SELECT_ONEOF_LABEL) {
                        userProvider.signIn(
                          userModelDTO: userProvider.allUsers.firstWhere((u) => u.username == _dropdownValue),
                        );
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  items: displayUsernames.map<DropdownMenuItem<String>>((String value) {
                    final bool isUser = selectableUsers.contains(value);
                    Widget content = Text(value,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    );
                    if (isUser) {
                      content = Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(value,
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  try{
                                    var user = userProvider.allUsers.firstWhere((u) => u.username == value);
                                    await userProvider.deleteUser(user.id!);

                                  } on Exception catch(e){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Erro: $e"),
                                          backgroundColor: Colors.red,
                                        )
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                )
                            ),
                          ),
                        ],
                      );
                    }

                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 250,
                        child: content,
                      ),
                    );
                  }).toList(),
                )
              ],
            )
        )
    );
  }
}