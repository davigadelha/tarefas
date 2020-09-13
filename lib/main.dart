import 'package:flutter/material.dart';
import 'package:tarefas/screens/lista_tarefas_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaTarefasScreen(),
    );
  }
}