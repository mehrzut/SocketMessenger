import 'dart:io';
import 'dart:typed_data';

class MyServerSocket {
  static late ServerSocket serverSocket;
  List<Socket> clientsList = [];

  /// initializes the server socket
  init() async {
    // address and port
    var address = "127.0.0.1";
    var port = 8080;
    try {
      // binds the server socket at [address]:[port]
      serverSocket = await ServerSocket.bind(address, port);
      // listens for client connections to the server
      print('# Listening for connections on $address:$port');
      serverSocket.listen((client) {
        _checkClient(client);
      });
    } on Exception catch (e) {
      print('# Unable to bind: $e');
      stdin.readLineSync();
    }
  }

  /// listens to new client
  void _clientListener(Socket clientSocket) async {
    final newClientJoinMessage = '# New connection from'
        ' ${clientSocket.remoteAddress.address}:${clientSocket.remotePort}';
    print(newClientJoinMessage);
    // messages others that new client joined
    _publish(newClientJoinMessage, clientSocket);
    // listens for events from this client
    clientSocket.listen(
      // handles data from the client
      (Uint8List data) async {
        final message = String.fromCharCodes(data);
        print(message);
        _publish(message, clientSocket);
      },
      // handles errors
      onError: (error) {
        _clientLeaveHandler(clientSocket);
        print('# An error occurred: $error');
        // closes the client socket when an error occurred
        clientSocket.close();
      },
      // handles the client closing the connection
      onDone: () {
        _clientLeaveHandler(clientSocket);
        print(
            '# Client ${clientSocket.remoteAddress.address}:${clientSocket.remotePort} left');
        // closes the client socket when left
        clientSocket.close();
      },
    );
  }

  /// checks if the connection is from a new socket
  void _checkClient(Socket clientSocket) {
    if (!clientsList.any((element) =>
        '${clientSocket.remoteAddress.address}:${clientSocket.remotePort}' ==
        '${element.remoteAddress.address}:${element.remotePort}')) {
      // this is a new client socket
      _newClientHandler(clientSocket);
    }
  }

  /// adds the new socket to client socket list and listens to events from it
  void _newClientHandler(Socket clientSocket) {
    clientsList.add(clientSocket);
    _clientListener(clientSocket);
  }

  /// publishes the [message] to every client that is connected except the sender of it
  void _publish(String message, Socket senderSocket) {
    for (Socket element in clientsList) {
      if ('${senderSocket.remoteAddress.address}:${senderSocket.remotePort}' !=
          '${element.remoteAddress.address}:${element.remotePort}') {
        // this [message] contains the sender's name, like: "Name: Message..."
        element.write(message);
      }
    }
  }

  /// removes the client from list and alert others
  void _clientLeaveHandler(Socket clientSocket) {
    clientsList.removeWhere((element) =>
        element.remoteAddress.address == clientSocket.remoteAddress.address &&
        element.remotePort == clientSocket.remotePort);
    _publish(
        '# Client ${clientSocket.remoteAddress.address}:${clientSocket.remotePort} left',
        clientSocket);
  }
}
