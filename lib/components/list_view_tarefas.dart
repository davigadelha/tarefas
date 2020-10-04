import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/screens/tarefa_screen.dart';
import 'package:tarefas/util/constantes.dart';
import 'package:tarefas/util/data_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListViewTarefas extends StatelessWidget {
  List<Tarefa> tarefas;
  List<Tarefa> tarefasFiltradas;

  ListViewTarefas({Key key, @required this.tarefas, @required this.tarefasFiltradas}) : super(key: key);

  // @override
  // _ListViewTarefasState createState() => _ListViewTarefasState(tarefas, tarefasFiltradas);
  // List<Tarefa> _tarefas;
  // List<Tarefa> _tarefasFiltradas;

  // _ListViewTarefasState(List<Tarefa> tarefas, List<Tarefa> tarefasFiltradas) {
    // this._tarefas = tarefas;
    // this._tarefasFiltradas = tarefasFiltradas;
  // }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {

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

      if (tarefasFiltradas[index].status == 'F') {
        cor = Color(0xAA2bfe72);
      } else {
        if (tarefasFiltradas[index].dataVencimento == null) {
          cor = null;
        } else {
          var diasVencimento = 100;
          if (tarefasFiltradas[index].dataVencimento != null) {
            diasVencimento =
                _diffInDays(tarefasFiltradas[index].dataVencimento, DateTime.now());
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
      int index = tarefas.indexOf(tarefa);

      if (index > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TarefaScreen(
                    tarefa: tarefas[index],
                    index: index,
                  ),
            ));
      }
    }

    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: tarefasFiltradas.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: _decorationListTyle(index),
          child: ListTile(
            title: Text('${tarefasFiltradas[index].titulo}',
                style: tarefasFiltradas[index].status == 'F' ? Constantes.doneStyle : null),
            subtitle: Text(
                tarefasFiltradas[index].dataVencimento != null
                    ? 'Vence em ${DataUtil.getDataFormatada(tarefasFiltradas[index].dataVencimento)}'
                    : 'Sem Data de Vencimento',
                maxLines: 2,
                style: tarefasFiltradas[index].status == 'F' ? Constantes.doneStyle : null),
            onTap: () => _onTapItem(tarefasFiltradas[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tarefasFiltradas[index].dataCriacao != null
                    ? '${DataUtil.getDataFormatada(tarefasFiltradas[index].dataCriacao)}'
                    : '')
              ],
            ),
          ),
        );
      },
    );
  }
}
