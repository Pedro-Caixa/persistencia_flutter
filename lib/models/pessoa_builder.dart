class Pessoa {
  final int? id; // id opcional para permitir AUTOINCREMENT
  final String nome;
  final int idade;

  const Pessoa({this.id, required this.nome, required this.idade});
}
