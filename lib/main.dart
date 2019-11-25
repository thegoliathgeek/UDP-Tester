import 'package:flutter/material.dart';
import 'dart:io';

void main() => runApp(MaterialApp(
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
  String data = '';
  InternetAddress multicastAddress = new InternetAddress("224.9.9.9");
  int multicastPort = 3333;
  final ipText = TextEditingController();
  final portText = TextEditingController();

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
            TextField(
              controller: ipText,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter a IP'),
            ),
            TextField(
              controller: portText,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter a PORT'),
            ),
            Text(status),
            RaisedButton(
              child: Text('Listen'),
              onPressed: () {
                if (ipText.text.length == 0 || portText.text.length == 0) {
                  setState(() {
                    status = 'Both fileds required';
                  });
                } else {
                  setState(() {
                    multicastAddress = new InternetAddress(ipText.text);
                    multicastPort = int.parse(portText.text);
                    status = 'Listening';
                    RawDatagramSocket.bind(multicastAddress, multicastPort)
                        .then((RawDatagramSocket socket) {
                      print('Datagram socket ready to receive');
                      print('${socket.address.address}:${socket.port}');
                      socket.joinMulticast(multicastAddress);
                      print('Multicast group joined');
                      socket.listen((RawSocketEvent e) {
                        Datagram d = socket.receive();
                        if (d == null) return;
//                        print('Hello Dhanush'.codeUnits);
                        setState(() {
                          data = new String.fromCharCodes(d.data).trim();
                        });
//                        print('Datagram from ${d.address.address}:${d.port}: ${data}');
                        socket.send('Got message'.codeUnits,
                            new InternetAddress(d.address.address), d.port);
                      });
                    });
                  });
                }
              },
            ),
            Text(data)
          ],
        ),
      ),
    );
  }
}
