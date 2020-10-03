import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/screens/tarefa_screen.dart';
import 'package:tarefas/util/constantes.dart';
import 'package:tarefas/util/data_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListViewTarefas extends StatefulWidget {
  List<Tarefa> tarefas;
  List<Tarefa> tarefasFiltradas;

  ListViewTarefas({Key key, @required this.tarefas, @required this.tarefasFiltradas}) : super(key: key);

  @override
  _ListViewTarefasState createState() => _ListViewTarefasState(tarefas, tarefasFiltradas);
}

class _ListViewTarefasState extends State<ListViewTarefas> {
  List<Tarefa> _tarefas;
  List<Tarefa> _tarefasFiltradas;

  _ListViewTarefasState(List<Tarefa> tarefas, List<Tarefa> tarefasFiltradas) {
    this._tarefas = tarefas;
    this._tarefasFiltradas = tarefasFiltradas;
  }

  @override
  void initState() {
    super.initState();
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

    if (_tarefasFiltradas[index].status == 'F') {
      cor = Color(0xAA2bfe72);
    } else {
      if (_tarefasFiltradas[index].dataVencimento == null) {
        cor = null;
      } else {
        var diasVencimento = 100;
        if (_tarefasFiltradas[index].dataVencimento != null) {
          diasVencimento =
              _diffInDays(_tarefasFiltradas[index].dataVencimento, DateTime.now());
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

    return new BoxDecoration(color: cor);
  }

  _onTapItem(Tarefa tarefa) {
    int index = _tarefas.indexOf(tarefa);

    if (index > 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TarefaScreen(
                  tarefa: _tarefas[index],
                  index: index,
                ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: _tarefasFiltradas.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: _decorationListTyle(index),
          child: ListTile(
            title: Text('${_tarefasFiltradas[index].titulo}',
                style: _tarefasFiltradas[index].status == 'F' ? Constantes.doneStyle : null),
            subtitle: Text(
                _tarefasFiltradas[index].dataVencimento != null
                    ? 'Vence em ${DataUtil.getDataFormatada(_tarefasFiltradas[index].dataVencimento)}'
                    : 'Sem Data de Vencimento',
                maxLines: 2,
                style: _tarefasFiltradas[index].status == 'F' ? Constantes.doneStyle : null),
            onTap: () => _onTapItem(_tarefasFiltradas[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_tarefasFiltradas[index].dataCriacao != null
                    ? '${DataUtil.getDataFormatada(_tarefasFiltradas[index].dataCriacao)}'
                    : '')
              ],
            ),
          ),
        );
      },
    );
  }
}
