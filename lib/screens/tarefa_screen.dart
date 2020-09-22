import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/util/constantes.dart';
import 'package:tarefas/util/data_util.dart';

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
  DateTime _dataVencimento;

  _TarefaScreenState(Tarefa tarefa, int index){
    this._tarefa = tarefa;
    this._index = index;
  }

  @override
  void initState() {
    super.initState();
    if (_tarefa != null) {
      _tituloController.text = _tarefa.titulo;
      _descricaoController.text = _tarefa.descricao;
      _dataVencimento = _tarefa.dataVencimento;
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

      _tarefa = Tarefa.fromAtributos(
          _tituloController.text, _descricaoController.text, DateTime.now(), _dataVencimento);
      debugPrint('dataCriacao: ${_tarefa.dataCriacao}');
      debugPrint('dataVencimento: ${_dataVencimento}');

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
      appBar: AppBar(backgroundColor: Constantes.corPadrao, title: Text('Tarefa'),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 30,
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
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              decoration: InputDecoration(
                  hintText: 'Descrição',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Data de Vencimento:', textAlign: TextAlign.start, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    showDatePicker(
                        context: context,
                        initialDate: _dataVencimento == null ?  DateTime.now() : _dataVencimento,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(9999),

                    ).then((dataEscolhida) {
                      setState(() {
                        _dataVencimento = dataEscolhida;
                      });
                    });
                  },
                ),
                Text(_dataVencimento == null ? 'Selecione uma data' : DataUtil.getDataFormatada(_dataVencimento)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ButtonTheme(
                minWidth: 70,
                height: 70,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: Colors.white)
                    ),
                  child: Icon(Icons.save, size: 40,),
                  color: Constantes.corPadrao,
                  textColor: Colors.white,
                  onPressed: () => _saveItem(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
