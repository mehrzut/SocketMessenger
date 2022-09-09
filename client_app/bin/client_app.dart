import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

void main() async {
  // gets the username
  String name = _getUsername();
  // initializes the connection
  MySocket.init(name);
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

class MySocket {
  String name;

  MySocket.init(this.name) {
    _initialize();
  }
  // address and port
  var address = "127.0.0.1";
  var port = 8080;
  Socket? socket;

  /// initializes the connection
  _initialize() async {
    await _connectionHandler();
    await _sendMessageHandler();
  }

  Future<void> _connectionHandler() async {
    try {
      // connects to the server socket
      socket = await Socket.connect(address, port);
      if (socket != null) {
        print(
            '# Connected to: ${socket!.remoteAddress.address}:${socket!.remotePort}');
        _messageReceiver();
      }
    } on Exception catch (e) {
      print('Unable to connect: $e');
      stdin.readLineSync();
    }
  }

  /// listens for messages on server socket
  void _messageReceiver() {
    socket!.listen(
      // handles data from server
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        print(serverResponse);
      },

      // handles errors
      onError: (dynamic error) {
        print(error);
        socket?.destroy();
      },

      // handles server ending connection
      onDone: () {
        print('# Connection stopped.');
        socket?.destroy();
      },
    );
  }

  _sendMessageHandler() async {
    if (socket != null) {
      // isolates the input message method
      final receivePort = ReceivePort();
      final isolate =
          await Isolate.spawn<SendPort>(_inputMessage, receivePort.sendPort);
      // hints
      print("* Now you can type your message and hit /Enter/ to send it.");
      print("* Type 'exit' and hit /Enter/ to close connection.");
      // handles input messages
      await for (final message in receivePort) {
        // breaks the loop on 'exit'
        if (message == 'exit') break;
        // sends the message if it is not empty
        if (message is String && message.trim().isNotEmpty) {
          await sendMessage(message);
        }
      }
      // kills isolate on exit
      isolate.kill(priority: Isolate.immediate);
      // closes socket on exit
      socket?.close();
    }
  }

  /// gets input messages
  static _inputMessage(SendPort port) {
    String message = '';
    while (message != 'exit') {
      message = stdin.readLineSync() ?? '';
      port.send(message);
    }
    Isolate.current.kill();
  }

  /// sends messages to server
  Future<void> sendMessage(String message) async {
    socket?.write('$name: $message');
  }
}
