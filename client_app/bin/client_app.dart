import 'dart:io';

import 'client_socket.dart';

void main() async {
  // gets the username
  String name = _getUsername();
  // initializes the connection
  ClientSocket.init(name);
}

/// get the username to show to other clients
String _getUsername() {
  String name = '';
  while (name.isEmpty) {
    print('Enter your name: ');
    name = stdin.readLineSync() ?? '';
  }
  return name;
}
