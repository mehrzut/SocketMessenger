# Console Socket Messenger

This repository contains two Dart projects: a client-side app and a server-side app for a console-based socket messenger. The server-side app listens on IP `127.0.0.1` and port `8080` by default. The client app connects to the server, allowing users to send messages to each other through the console.

## Getting Started

### Prerequisites

- Dart SDK installed on your system

### Running the Server-side App

1. Navigate to the server-side app directory:
`cd server_app\bin`

2. Run the server-side app:
`dart run server_app.dart`

The server will start listening on IP `127.0.0.1` and port `8080` by default. You can change the IP and port in code.

### Running the Client-side App

1. Open a new terminal and navigate to the client-side app directory:
`cd client_app\bin`

2. Run the client-side app:
`dart run client_app.dart`

3. Enter your username when prompted.

4. Start typing messages in the console and press Enter to send them. The server app will receive the message, include the author's name, and send it to every user except the author.

5. To exit the client app, type `exit` and press Enter.

## Features

- Server-side app listens on IP `127.0.0.1` and port `8080` by default (modifiable in code)
- Client-side app connects to the server and sends the user's name
- Server-side app maintains a list of connected users and their names
- Users can send messages to each other through the console
- Server-side app broadcasts messages to all connected users, excluding the author
- Users can exit the client app by typing 'exit' and pressing Enter

## Contributing

Feel free to submit issues or pull requests to improve this project. Your contributions are welcome!

