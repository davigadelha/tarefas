import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/components/custom_search_delegate.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/screens/tarefa_screen.dart';
import 'package:tarefas/util/constantes.dart';
import 'package:tarefas/util/data_util.dart';

class ListaTarefasScreen extends StatefulWidget {
  @override
  _ListaTarefasScreenState createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends State<ListaTarefasScreen>
    with TickerProviderStateMixin<ListaTarefasScreen> {
  List<Tarefa> list = [];
  final _doneStyle = TextStyle(decoration: TextDecoration.lineThrough);

  // bool _itemSegurado = false;
  List<int> _tarefasSelecionadas;

  @override
  void initState() {
    super.initState();
    _tarefasSelecionadas = List<int>();
    _reloadList();
  }
  _reloadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = prefs.getString('list');
    if (data != null) {
      setState(() {
        var objs = jsonDecode(data) as List;
        list = objs.map((obj) => Tarefa.fromJson(obj)).toList();

        // s
      });
    }
  }

  _removeItem(List<int> listaIndex) {
    List<Tarefa> tarefasExcluir = [];
    for (int index in listaIndex){
      tarefasExcluir.add(list[index]);
    }
    setState(() {
      int count = 0;
      for (Tarefa tarefaExcluir in tarefasExcluir){
        list.remove(tarefaExcluir);
      }

      _tarefasSelecionadas.clear();
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('list', jsonEncode(list)));
  }

  _doneItem(List<int> listaIndex) {

      setState(() {
        for (int index in listaIndex) {
          if (list[index].status == 'A') {
            list[index].status = 'F';
          } else {
            list[index].status = 'A';
          }
        }
        _tarefasSelecionadas.clear();
      });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('list', jsonEncode(list)));
  }

  _cancelSelection(){
    setState(() {
      _tarefasSelecionadas.clear();
    });
  }

  _showAlertDialog(BuildContext context, String conteudo,
      Function confirmFunction, List<int> index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('Confirmação'),
            content: Text(conteudo),
            actions: [
              FlatButton(
                child: Text('Não'),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    confirmFunction(index);
                    Navigator.pop(context);
                  })
            ]);
      },
    );
  }

  int _diffInDays(DateTime date1, DateTime date2) {
    return ((date1.difference(date2) -
                    Duration(hours: date1.hour) +
                    Duration(hours: date2.hour))
                .inHours /
            24)
        .round();
  }

  Decoration _decorationListTyle(int index) {
    Color cor;

    if (_tarefasSelecionadas.contains(index)) {
      cor = Colors.blueGrey;
    } else {
      if (list[index].status == 'F') {
        cor = Color(0xAA2bfe72);
      } else {
        if (list[index].dataVencimento == null) {
          cor = null;
        } else {
          var diasVencimento = 100;
          if (list[index].dataVencimento != null) {
            diasVencimento =
                _diffInDays(list[index].dataVencimento, DateTime.now());
          }
          if (diasVencimento > 0 && diasVencimento < 3) {
            cor = Color(0xA8f5ea95);
          } else if (diasVencimento < 1) {
            cor = Color(0xB3f9260e);
          } else {
            cor = null;
          }
        }
      }
    }

    return new BoxDecoration(color: cor);
  }

  Icon _iconeDoneUndo() {
    Icon icon = Icon(
      Icons.check,
      color: Colors.white,
    );

    if (_tarefasSelecionadas.length > 0 &&
        list[_tarefasSelecionadas[0]].status == 'F') {
      icon = Icon(Icons.undo, color: Colors.white);
    }

    return icon;
  }

  _onLongPress(int index) {
    setState(() {
      _tarefasSelecionadas.add(index);
    });
  }

  _onTapItem(int index) {
    if (_tarefasSelecionadas.length > 0) {
      setState(() {
        if (_tarefasSelecionadas.contains(index)) {
          _tarefasSelecionadas.remove(index);
        } else {
          if (list[index].status == list[_tarefasSelecionadas[0]].status) {
            _tarefasSelecionadas.add(index);
          }
        }
      });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TarefaScreen(
              tarefa: list[index],
              index: index,
            ),
          )).then((value) => _reloadList());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constantes.corPadrao,
        title: Text('Lista de Tarefas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate(list));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: _decorationListTyle(index),
              child: ListTile(
                title: Text('${list[index].titulo}',
                    style: list[index].status == 'F' ? _doneStyle : null),
                subtitle: Text(
                    list[index].dataVencimento != null
                        ? 'Vence em ${DataUtil.getDataFormatada(list[index].dataVencimento)}'
                        : 'Sem Data de Vencimento',
                    maxLines: 2,
                    style: list[index].status == 'F' ? _doneStyle : null),
                onTap: () => _onTapItem(index),
                onLongPress: () => _onLongPress(index),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(list[index].dataCriacao != null
                        ? '${DataUtil.getDataFormatada(list[index].dataCriacao)}'
                        : '')
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: _tarefasSelecionadas.length > 0,
        child: BottomNavigationBar(
          iconSize: 30,
          backgroundColor: Constantes.corPadrao,
          onTap: (index) {
            if (index == 0) {
              _showAlertDialog(context, 'Tem certeza que deseja excluir a(s) tarefa(s) selecionada(s)?',
                  _removeItem, _tarefasSelecionadas);

            } else if (index == 1) {
              _cancelSelection();
            }
            else {
              _doneItem(_tarefasSelecionadas);
            }
          },
          items: [
            BottomNavigationBarItem(
              title: Text(
                '',
                style: TextStyle(fontSize: 1),
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                '',
                style: TextStyle(fontSize: 1),
              ),
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                '',
                style: TextStyle(fontSize: 1),
              ),
              icon: _iconeDoneUndo(),
            ),
          ],
        ),
      ),
      floatingActionButton:
          Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Constantes.corPadrao,
            child: Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TarefaScreen(
                    tarefa: null,
                    index: -1,
                  ),
                )).then((value) => _reloadList()),
          ),
        ],
      ),

      // )
    );
  }
}