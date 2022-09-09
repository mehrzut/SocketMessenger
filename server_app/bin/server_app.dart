import 'server_socket.dart';

void main() async {
  MyServerSocket mySocket = MyServerSocket();
  // binds the server socket
  await mySocket.init();
}
