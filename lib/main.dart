import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udp_app/udpmulti.dart';
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
  List<String> data = [''];
  UDPTester ob;
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
                      child: TextFormField(
                        controller: portText,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Enter a PORT'),
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
                  child: Text('Clear'),
                  onPressed: () {
                    setState(() {
                      data.clear();
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Send'),
                  onPressed: () {
                    RawDatagramSocket.bind(ob.address, ob.port)
                        .then((RawDatagramSocket socket) {
                      socket.send('Something'.codeUnits, ob.address, ob.port);
                      socket.close();
                    });
                  },
                )
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
            )
          ],
        ),
      ),
    );
  }
}
