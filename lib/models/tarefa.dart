import 'package:tarefas/util/data_util.dart';

class Tarefa {
  String titulo;
  String descricao;
  String status;
  DateTime dataCriacao;
  DateTime dataVencimento;

  Tarefa();

  Tarefa.fromAtributos(String titulo, String descricao, DateTime dataCriacao, DateTime dataVencimento) {
    this.titulo = titulo;
    this.descricao = descricao;
    this.dataCriacao = dataCriacao;
    this.dataVencimento = dataVencimento;
    this.status = 'A';
  }

  Tarefa.fromJson(Map<String, dynamic> json)
    : titulo = json['titulo'],
      descricao = json['descricao'],
        dataCriacao = DataUtil.getDateTimeFromString(json['dataCriacao']),
        dataVencimento = DataUtil.getDateTimeFromString(json['dataVencimento']),
      status = json['status'];

  Map toJson() => {
    'titulo' : titulo,
    'descricao' : descricao,
    'dataCriacao' : DataUtil.getDataHoraFormatada(dataCriacao),
    'dataVencimento' : DataUtil.getDataHoraFormatada(dataVencimento),
    'status' : status
  };
}