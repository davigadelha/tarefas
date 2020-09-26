import 'package:tarefas/models/tarefa.dart';

class TarefaUtil{

  static String descricaoStatus(Tarefa tarefa){
    if (tarefa == null || tarefa.status == null){
      return '';
    }
    if ( tarefa.status == 'A'){
      return 'Aberta';
    } else if ( tarefa.status == 'F'){
      return 'Finalizada';
    } else{
      return '';
    }
  }
}