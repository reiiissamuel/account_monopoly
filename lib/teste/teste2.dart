import 'dart:typed_data';

import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

class DataConnectionExample extends StatefulWidget {
  const DataConnectionExample({super.key});

  @override
  State<DataConnectionExample> createState() => _DataConnectionExampleState();
}

class _DataConnectionExampleState extends State<DataConnectionExample> {
  late Peer peer;//Peer(options: PeerOptions(debug: LogLevel.All));
  final TextEditingController _controllerPeerIdtxt = TextEditingController();
  final TextEditingController _msg_controller = TextEditingController();
  String? peerId;
  late DataConnection conn;
  bool connected = false;

  bool isServer = false;
  List<DataConnection> serverActiveConnections = [];

  @override
  void dispose() {
    peer.dispose();
    _controllerPeerIdtxt.dispose();
    _msg_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    peerId = StringUtils.generateUUID(size: 4);
    peer = Peer(id: peerId);
    openConect();
    //peerId = StringUtils.generateUUID(size: 5);
  }

  void openConect(){

    peer.on("open").listen((id) {
      setState(() {
        connected = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Coneccao aberta")));
    });

    peer.on("close").listen((id) {
      setState(() {
        connected = false;
      });
    });

    peer.on<DataConnection>("connection").listen((event) {
      conn = event;
      isServer = true;
      conn.on("data").listen((data) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data)));
      });

      conn.on("open").listen((data) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("SRV-Conecao recebida")));
      });

      conn.on("close").listen((event) {
        ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("SRV-Coneccao fechada")));
      setState(() {
        connected = false;
      });
      });

      serverActiveConnections.add(conn);
      setState(() {
        connected = true;
      });
    });
  }

  void connectToServer(String peerId) {
    print(peerId.toUpperCase());
    final connection = peer.connect(peerId);
    conn = connection;

    conn.on("open").listen((event) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Coneccao aberta aqui")));
      setState(() {
        connected = true;
      });

      connection.on("close").listen((event) {
        setState(() {
          ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Coneccao fechou")));
          connected = false;
        });
      });

      conn.on("data").listen((data) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data)));
      });
      conn.on("binary").listen((data) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Got binary!")));
      });
    });
  }

  void send(String msg){
    if(isServer){
      for(DataConnection dataConnection in serverActiveConnections){
        dataConnection.send(msg);
      }
    } else {
      conn.send(msg);
    }
  }

  void sendBinary() {
    final bytes = Uint8List(30);
    conn.sendBinary(bytes);
  }

  void closeConnection() {
    peer.dispose();
  }

  void reconnect() {
    peer = Peer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _renderState(),
              const Text(
                'Connection ID:',
              ),
              SelectableText(peerId!, style: TextStyle(backgroundColor: connected ? Colors.green : Colors.red),),
              TextField(
                controller: _controllerPeerIdtxt,
              ),
              ElevatedButton(onPressed: () => openConect, child: const Text("connect as server")),
              ElevatedButton(onPressed: () => connectToServer(_controllerPeerIdtxt.text), child: const Text("connect to")),
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

  Widget _renderState() {
    Color bgColor = connected ? Colors.green : Colors.grey;
    Color txtColor = Colors.white;
    String txt = connected ? "Connected" : "Standby";
    return Container(
      decoration: BoxDecoration(color: bgColor),
      child: Text(
        txt,
        style:
        Theme.of(context).textTheme.titleLarge?.copyWith(color: txtColor),
      ),
    );
  }
}