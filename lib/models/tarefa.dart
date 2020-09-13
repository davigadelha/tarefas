class Tarefa {
  String titulo;
  String descricao;
  String status;

  Tarefa();

  Tarefa.fromTituloDescricao(String titulo, String descricao) {
    this.titulo = titulo;
    this.descricao = descricao;
    this.status = 'A';
  }

  Tarefa.fromJson(Map<String, dynamic> json)
    : titulo = json['titulo'],
      descricao = json['descricao'],
      status = json['status'];

  Map toJson() => {
    'titulo' : titulo,
    'descricao' : descricao,
    'status' : status
  };
}