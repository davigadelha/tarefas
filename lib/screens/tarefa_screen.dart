import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/models/tarefa.dart';

class TarefaScreen extends StatefulWidget {

  final Tarefa tarefa;
  final int index;

  TarefaScreen({Key key, @required this.tarefa, @required this.index}) : super(key: key);

  @override
  _TarefaScreenState createState() => _TarefaScreenState(tarefa, index);
}

class _TarefaScreenState extends State<TarefaScreen> {
  Tarefa _tarefa;
  int _index;
  final key = GlobalKey<ScaffoldState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  _TarefaScreenState(Tarefa tarefa, int index){
    this._tarefa = tarefa;
    this._index = index;
    if (_tarefa != null) {
      _tituloController.text = _tarefa.titulo;
      _descricaoController.text = _tarefa.descricao;
    }
  }

  _saveItem() async {
    if (_tituloController.text.isEmpty){
      key.currentState.showSnackBar(SnackBar(
        content: Text('O campo Título é obrigatório!!'),
      ));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Tarefa> list = [];
      var data = prefs.getString('list');
      if (data != null) {
        var objs = jsonDecode(data) as List;
        list = objs.map((obj) => Tarefa.fromJson(obj)).toList();
      }

      _tarefa = Tarefa.fromTituloDescricao(
          _tituloController.text, _descricaoController.text);

      if (_index != -1) {
        list[_index] = _tarefa;
      } else {
        list.add(_tarefa);
      }

      prefs.setString('list', jsonEncode(list));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(backgroundColor: Colors.teal, title: Text('Tarefa'),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Título',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descricaoController,
              maxLines: 8,
              maxLength: 400,
              decoration: InputDecoration(
                  hintText: 'Descrição',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              minWidth: 90,
              height: 90,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(color: Colors.white)
                  ),
                child: Icon(Icons.save, size: 50,),
                color: Colors.teal,
                textColor: Colors.white,
                onPressed: () => _saveItem(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
