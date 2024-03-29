import 'package:flutter/material.dart';

class NoConnectionDialog extends StatelessWidget {
  const NoConnectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.8),
      child: Container(
          width: MediaQuery.of(context).size.width -50,
          height: MediaQuery.of(context).size.height -80,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black.withOpacity(0.8),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Sem Conexão!!"
                    , style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,letterSpacing: 2)),


                Container(
                    height: 150.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.signal_wifi_off, size: 60, color: Theme.of(context).primaryColor),
                        const Text("Por favor, verifique se está conectado!",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white,letterSpacing: 2)),
                      ],
                    )),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      backgroundColor: Colors.green,
                      splashFactory: InkRipple.splashFactory,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Tentar Novamente!", style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0)),
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }
                ),

              ])
      ),
    );
  }
}
