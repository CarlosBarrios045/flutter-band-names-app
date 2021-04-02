import 'package:band_names_app/src/providers/socket_provider.dart';
import 'package:flutter/material.dart';

// Pages
import 'package:band_names_app/src/pages/home_page.dart';
import 'package:band_names_app/src/pages/status_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Band Names App',
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(),
          'status': (_) => StatusPage(),
        },
      ),
    );
  }
}