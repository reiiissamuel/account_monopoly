import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

class ConnectionExample extends StatefulWidget {
  const ConnectionExample({super.key});
  @override
  State<ConnectionExample> createState() => _ConnectionExampleState();
}

class _ConnectionExampleState extends State<ConnectionExample> {
  late Peer peer;
  late DataConnection connWithServer;
  bool connected = false;
  final TextEditingController _controllerPeerIdtxt = TextEditingController();
  final TextEditingController _msg_controller = TextEditingController();
  String peerId = "";
  bool isServer = false;
  
  List<DataConnection> serverActiveConnections = [];


  @override
  void dispose() {
    peer.dispose();
    _controllerPeerIdtxt.dispose();
    _msg_controller.dispose();
    connWithServer.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    peerId = StringUtils.generateUUID(size: 4);
    //openConect();

  }

  void openConect(){
    peer = Peer(id: peerId);
    peer.on("open").listen((event) {
      setState(() {
        connected = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("TODOS - Aberto a conexoes")));});

    peer.on("close").listen((id) {
      setState(() {
        closeConnection();
        print("FECHADO!!!!!!");
      });
    });

    peer.on<DataConnection>("connection").listen((event) {
      //DataConnection dc = event;
      serverActiveConnections.add(event);

      event.on("open").listen((id) {
        connected = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("SRV-Vc recebeu uma conexão")));
      });
      event.on("data").listen((data) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data)));
      });

      event.on("close").listen((event) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("SRV-O peer $event caiu.")));
        send("SRV-O peer $event caiu.");
      });
      print("PEER RECEBIDO ${event.peer}");
      setState(() {
        isServer = true;
      });
    });
  }

  void connectToServer(String peeridtoconnect){
    print("PEER para conexao: $peeridtoconnect");

    setState(() {
      peer = Peer(id: peerId);
    });
    final connection = peer.connect(peeridtoconnect);
    connWithServer = connection;

    connWithServer.on("open").listen((event) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Coneccao aberta aqui")));
      setState(() {
        connected = true;
      });

      connWithServer.on("close").listen((event) {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Client-Coneccao com srv fechou")));
          closeConnection();
          //se for o proximo da lista abro a conexão como srv.
        });
      });

      connWithServer.on("data").listen((data) {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data)));
        });
      });});
  }

  void closeConnection(){
    if(isServer){
      serverActiveConnections = [];
    } else {
      connWithServer.close();
    }

    peer.dispose();
    connected = false;
  }

  void send(String msg){
    if(isServer){
      for(DataConnection dataConnection in serverActiveConnections){
        dataConnection.send(msg);
      }
    } else {
      connWithServer.send(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Connection ID:',
              ),
              SelectableText(peerId, style: TextStyle(backgroundColor: connected ? Colors.green : Colors.red),),
              TextField( 
                controller: _controllerPeerIdtxt,
              ),
              ElevatedButton(onPressed: openConect, child: const Text("connect as server")),
              ElevatedButton(onPressed: (){connectToServer(_controllerPeerIdtxt.text);}, child: const Text("connect to")),
              ElevatedButton(
                  onPressed: () => send(_msg_controller.text), child: const Text("send message")),const Text(
                'Mensagem abaixo:',
              ),
              TextField( 
                controller: _msg_controller,
              ),
              const SizedBox(height: 20),
              isServer ? const Icon(Icons.computer, color: Colors.blue) : const Icon(Icons.mobile_screen_share,  color: Colors.black)


            ],
          ),
        ));
  }

}