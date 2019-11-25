import 'dart:io';

abstract class Udp {
  InternetAddress get address;

  int get port;

  Future<RawDatagramSocket> bind();
}

class UDPTester extends Udp {
  int multicastPort;
  InternetAddress multicastAddress;

  UDPTester() {
    multicastPort = 3333;
    multicastAddress = new InternetAddress('224.9.9.9');
  }

  UDPTester.initialize(String addr, int port) {
    this.multicastPort = port;
    this.multicastAddress = new InternetAddress(addr);
  }

  UDPTester.setMulticastPort(this.multicastPort);

  UDPTester.setMulticastAddress(this.multicastAddress);

  @override
  InternetAddress get address => multicastAddress;

  @override
  int get port => multicastPort;

  @override
  Future<RawDatagramSocket> bind() {
    return RawDatagramSocket.bind(this.multicastAddress, this.multicastPort);
  }
}
