import 'package:band_names_app/src/providers/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server status: ${socketProvider.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketProvider.socket.emit(
              "emitir", {"name": "Flutter", "mensaje": "Hola desde Flutter"});
        },
      ),
    );
  }
}
