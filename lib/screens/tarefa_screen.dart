import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/models/menu_item.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/screens/lista_tarefas_screen.dart';
import 'package:tarefas/util/constantes.dart';
import 'package:tarefas/util/data_util.dart';
import 'package:tarefas/util/tarefa_util.dart';

class TarefaScreen extends StatefulWidget {
  final Tarefa tarefa;
  final int index;

  TarefaScreen({Key key, @required this.tarefa, @required this.index})
      : super(key: key);

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
  List<MenuItem> _menuItems;
  bool _edit;
  FocusNode _focusNode;

  _TarefaScreenState(Tarefa tarefa, int index) {
    this._tarefa = tarefa;
    this._index = index;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (_tarefa != null) {
      _edit = false;
      _tituloController.text = _tarefa.titulo;
      _descricaoController.text = _tarefa.descricao;
      _dataVencimento = _tarefa.dataVencimento;

      _menuItems = <MenuItem>[
        // MenuItem.fromAtributos(Constantes.editar, '',
        //     Icon(Icons.edit, size: 24, color: Colors.blue)),
        MenuItem.fromAtributos(Constantes.deletar, '',
            Icon(Icons.delete, size: 24, color: Colors.blue))
      ];

      if (_tarefa.status == 'A') {
        _menuItems.add(MenuItem.fromAtributos(Constantes.finalizar, '',
            Icon(Icons.check, size: 24, color: Colors.blue)));
      } else {
        _menuItems.add(MenuItem.fromAtributos(Constantes.recuperar, '',
            Icon(Icons.undo, size: 24, color: Colors.blue)));
      }
    } else {
      _edit = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  _saveItem(bool finalizarRecuperar) async {
    if (_tituloController.text.isEmpty) {
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

      if (finalizarRecuperar) {
        setState(() {
          if (_tarefa.status == 'A') {
            _tarefa.status = 'F';
          } else {
            _tarefa.status = 'A';
          }
        });
      } else {
        _tarefa = Tarefa.fromAtributos(_tituloController.text,
            _descricaoController.text, DateTime.now(), _dataVencimento);
      }

      if (_index != -1) {
        list[_index].titulo = _tarefa.titulo;
        list[_index].descricao = _tarefa.descricao;
        list[_index].status = _tarefa.status;
        list[_index].dataVencimento = _tarefa.dataVencimento;
      } else {
        list.add(_tarefa);
      }

      list.sort((a, b) {
        if (a.dataVencimento == null && b.dataVencimento == null) {
          return 0;
        } else if (a.dataVencimento != null && b.dataVencimento == null) {
          return -1;
        } else if (a.dataVencimento == null && b.dataVencimento != null) {
          return 1;
        } else {
          return a.dataVencimento.compareTo(b.dataVencimento);
        }
      });

      prefs.setString('list',   jsonEncode(list));
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ListaTarefasScreen(),
      //     ));
    }
  }

  _doneItem() async {
    _saveItem(true);
  }

  _removeItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Tarefa> list = [];
    var data = prefs.getString('list');
    if (data != null) {
      var objs = jsonDecode(data) as List;
      list = objs.map((obj) => Tarefa.fromJson(obj)).toList();
    }
    setState(() {
      list.removeAt(_index);
    });
    prefs.setString('list', jsonEncode(list));

    Navigator.pop(context);
  }

  void choiceAction(String choice) {
    if (choice == Constantes.editar) {
      setState(() {
        _edit = true;
      });
    } else if (choice == Constantes.deletar) {
      _removeItem();
    } else if (choice == Constantes.finalizar ||
        choice == Constantes.recuperar) {
      _doneItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Constantes.corPadrao,
        title: Text('Tarefa'),
        centerTitle: true,
        actions: [
          Visibility(
            visible: _tarefa != null,
            child: IconButton(
              icon: Icon(Icons.edit, size: 24, color: Colors.white),
              onPressed: () => choiceAction(Constantes.editar),
            ),
          ),
          Visibility(
            visible: _tarefa != null,
            child: PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return _menuItems.map((MenuItem item) {
                  return PopupMenuItem<String>(
                      value: item.chave,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [item.icone, Text('   ${item.chave}')],
                      ));
                }).toList();
              },
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: _edit != null && _edit
                  ? TextStyle(fontWeight: FontWeight.normal)
                  : TextStyle(fontWeight: FontWeight.w200),
              readOnly: _edit != null ? !_edit : false,
              maxLength: 30,
              controller: _tituloController,
              decoration: InputDecoration(
                  hintText: 'Título', enabled: _edit != null ? _edit : false
                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: _edit != null && _edit
                  ? TextStyle(fontWeight: FontWeight.normal)
                  : TextStyle(fontWeight: FontWeight.w200),
              focusNode: _focusNode,
              readOnly: _edit != null ? !_edit : false,
              controller: _descricaoController,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              enabled: _edit != null ? _edit : false,
              onTap: () {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                } else {
                  _focusNode.requestFocus(_focusNode);
                }
              },
              onEditingComplete: () {
                print("edit");
                _focusNode.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Descrição',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Data de Vencimento: ',
                    textAlign: TextAlign.start,
                    style: _edit != null && _edit
                        ? TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                        : TextStyle(fontSize: 15, fontWeight: FontWeight.w200)),
                Visibility(
                  visible: _edit != null ? _edit : false,
                  child: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(9999),
                      ).then((dataEscolhida) {
                        setState(() {
                          _dataVencimento = dataEscolhida;
                        });
                      });
                    },
                  ),
                ),
                Text(
                  (_dataVencimento == null && _edit != null && _edit)
                      ? 'Selecione uma data'
                      : _dataVencimento != null
                          ? DataUtil.getDataFormatada(_dataVencimento)
                          : '',
                  style: _edit != null && _edit
                      ? TextStyle(fontWeight: FontWeight.normal)
                      : TextStyle(fontWeight: FontWeight.w200),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Visibility(
                  visible: _tarefa != null && _tarefa.status != null,
                  child: Text('Status: ',
                      textAlign: TextAlign.start,
                      style: _edit != null && _edit
                          ? TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                          : TextStyle(fontSize: 15, fontWeight: FontWeight.w200)),
                ),
                Visibility(
                    visible: _tarefa != null && _tarefa.dataCriacao != null,
                    child: Text('${TarefaUtil.descricaoStatus(_tarefa)}',
                        style: _edit != null && _edit
                            ? TextStyle(
                                fontSize: 15, fontWeight: FontWeight.normal)
                            : TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w200)))
              ],
            ),
          ),
          Visibility(
            visible: _edit != null ? _edit : false,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Center(
                child: ButtonTheme(
                  minWidth: 60,
                  height: 60,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(color: Colors.white)),
                    child: Icon(
                      Icons.save,
                      size: 30,
                    ),
                    color: Constantes.corPadrao,
                    textColor: Colors.white,
                    onPressed: () => _saveItem(false),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
