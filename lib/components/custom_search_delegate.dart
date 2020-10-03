import 'package:flutter/material.dart';
import 'package:tarefas/components/list_view_tarefas.dart';
import 'package:tarefas/models/tarefa.dart';
import 'package:tarefas/screens/lista_tarefas_screen.dart';
import 'package:tarefas/screens/tarefa_screen.dart';
import 'package:tarefas/util/constantes.dart';
import 'package:tarefas/util/data_util.dart';

class CustomSearchDelegate extends SearchDelegate {

  List<Tarefa> _tarefas;
  List<Tarefa> _tarefasFiltradas = [];

  CustomSearchDelegate(List<Tarefa> tarefas) :
      _tarefas = tarefas;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ListaTarefasScreen(),
            ));
      },
    );
  }

  Widget _retornarListaTarefas(){
    _tarefasFiltradas = _tarefas.where((tarefa) => tarefa.titulo.contains(query) || tarefa.descricao.contains(query)).toList();

    if (_tarefasFiltradas.isEmpty) {
      return Column(
        children: <Widget>[
          Text(
            "Nenhuma Tarefa encontrada.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    else{
      return ListViewTarefas(tarefas: _tarefas, tarefasFiltradas: _tarefasFiltradas);
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    // if (query.length < 3) {
    //   return Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Center(
    //         child: Text(
    //           "Search term must be longer than two letters.",
    //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //         ),
    //       )
    //     ],
    //   );
    // }
    return _retornarListaTarefas();

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    // return Column();
    return _retornarListaTarefas();
  }


}

