import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

void main() async {
  // gets the username
  String name = _getUsername();

  MySocket mySocket = MySocket.init(name);

}

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
            'Connected to: ${socket!.remoteAddress.address}:${socket!.remotePort}');
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
        print('$serverResponse');
      },

      // handles errors
      onError: (dynamic error) {
        print(error);
        socket?.destroy();
      },

      // handles server ending connection
      onDone: () {
        print('Server crashed');
        socket?.destroy();
      },
    );
  }

  _sendMessageHandler() async {
    if (socket != null) {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn<SendPort>(
          _inputMessage, receivePort.sendPort);
      print('* Enter "exit" to close connection');
      await for (final message in receivePort) {
        if (message == 'exit') break;
        if(message is String && message.trim().isNotEmpty) {
          await sendMessage(message);
        }
      }
      isolate.kill(priority: Isolate.immediate);
      socket?.close();
    }
  }

  static _inputMessage(SendPort port) {
    String message = '';
    while (message != 'exit') {
      message = stdin.readLineSync() ?? '';
      port.send(message);
    }
    Isolate.current.kill();
  }

  Future<void> sendMessage(String message) async {
    socket?.write('$name: $message');
    await Future<void>.delayed(Duration(milliseconds: 50));
  }
}


