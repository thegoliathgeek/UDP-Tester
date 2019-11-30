import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udp_app/udpmulti.dart';
import 'dart:io';

void main() => runApp(MaterialApp(
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  String status = 'Not Listening';
  List<String> data = [''];
  UDPTester ob;
  UDPTester obSend;
  final ipText = TextEditingController();
  final portText = TextEditingController();
  final sendText = TextEditingController();

  void sendData({data: String}) {
    obSend = new UDPTester.initialize(ipText.text, int.parse(portText.text));
    RawDatagramSocket.bind(ob.address, ob.port)
        .then((RawDatagramSocket socket) {
      socket.send(data.codeUnits, ob.address, ob.port);
      socket.close();
    });
    print('onSend set to null');
    obSend = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UDP APP'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      width: 150,
                      child: TextField(
                        controller: ipText,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Enter a IP'),
                      )),
//                  SizedBox(
//                    height: 18,
//                  ),
                  Container(
                      width: 150,
                      child: TextField(
                        controller: portText,
                        decoration: InputDecoration(
//                            icon: Icon(Icons.dashboard),
                            border: InputBorder.none,
                            hintText: 'Enter a PORT'),
                        keyboardType: TextInputType.number,
                      )),
                ]),
            SizedBox(
              height: 18,
            ),
            Text(status),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Text('Listen'),
                  onPressed: () {
                    if (ipText.text.length == 0 || portText.text.length == 0) {
                      setState(() {
                        status = 'Both fileds required';
                      });
                    } else {
                      setState(() {
                        status = 'Listening';
                        ob = new UDPTester.initialize(
                            ipText.text, int.parse(portText.text));
                      });
                      ob.bind().then((RawDatagramSocket socket) {
                        socket.joinMulticast(ob.address);

                        socket.listen((RawSocketEvent e) {
                          Datagram d = socket.receive();
                          if (d == null) return;
                          setState(() {
                            data.add(new String.fromCharCodes(d.data).trim());
                          });
                          String message =
                              new String.fromCharCodes(d.data).trim();
                          print(
                              'Datagram from ${d.address.address}:${d.port}: $message');
                          socket.send('Got message'.codeUnits,
                              new InternetAddress(d.address.address), d.port);
                        });
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text('Clear Console'),
                  onPressed: () {
                    setState(() {
                      data.clear();
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext coext, int index) {
                    return Text(
                      data[index],
                      style: TextStyle(fontSize: 15),
                    );
                  }),
            ),
//            Expanded(
//              child:
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextField(
                        controller: sendText,
                        decoration: InputDecoration(hintText: "Send Data")),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RaisedButton(
                      child: Text('Send'),
                      onPressed: () {
                        sendData(data: sendText.text);
                      },
                    ),
                  ),
                ),
              ],
            ),
//            ),
          ],
        ),
      ),
    );
  }
}
