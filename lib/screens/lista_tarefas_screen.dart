import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/screens/tarefa_screen.dart';

class ListaTarefasScreen extends StatefulWidget {
  @override
  _ListaTarefasScreenState createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends State<ListaTarefasScreen>
    with TickerProviderStateMixin<ListaTarefasScreen> {
  List<Tarefa> list = [];
  final _doneStyle = TextStyle(decoration: TextDecoration.lineThrough);
  AnimationController _hideFabAnimation;

  @override
  void initState() {
    super.initState();
    _reloadList();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  _reloadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = prefs.getString('list');
    if (data != null) {
      setState(() {
        var objs = jsonDecode(data) as List;
        list = objs.map((obj) => Tarefa.fromJson(obj)).toList();
      });
    }
  }

  _removeItem(int index) {
    setState(() {
      list.removeAt(index);
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('list', jsonEncode(list)));
  }

  _doneItem(int index) {
    setState(() {
      list[index].status = 'F';
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('list', jsonEncode(list)));
  }

  _redoItem(int index) {
    setState(() {
      list[index].status = 'A';
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('list', jsonEncode(list)));
  }

  _showAlertDialog(BuildContext context, String conteudo,
      Function confirmFunction, int index) {
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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.teal,
              title: Text('Tarefas a fazer'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: new BoxDecoration(
                        color: list[index].status == 'F'
                            ? Colors.greenAccent
                            : null),
                    child: ListTile(
                      title: Text('${list[index].titulo}',
                          style: list[index].status == 'F' ? _doneStyle : null),
                      subtitle: Text('${list[index].descricao}',
                          maxLines: 2,
                          style: list[index].status == 'F' ? _doneStyle : null),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TarefaScreen(
                              tarefa: list[index],
                              index: index,
                            ),
                          )).then((value) => _reloadList()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
//                    Visibility(
//                      visible: list[index].status == 'A' ? true : false,
//                      child:
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => _showAlertDialog(
                                context,
                                'Confirma a exclusão deste item?',
                                _removeItem,
                                index),
                          ),
//                    ),
                          IconButton(
                            icon: list[index].status == 'A'
                                ? Icon(Icons.check)
                                : Icon(Icons.undo),
                            onPressed: () => list[index].status == 'A'
                                ? _doneItem(index)
                                : _redoItem(index),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton:
            // ScaleTransition(
            //   scale: _hideFabAnimation,
            //   alignment: Alignment.bottomCenter,
            //   child:
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                        backgroundColor: Colors.teal,
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
            ],
          ),
            // )
    )
    );
  }
}
