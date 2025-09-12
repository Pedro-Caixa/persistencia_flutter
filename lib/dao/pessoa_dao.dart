import 'package:sqflite/sqflite.dart';
import '../models/pessoa_model.dart';

abstract class PessoaDao {
  Future<int> insert(Pessoa pessoa);
  Future<Pessoa?> findById(int id);
  Future<List<Pessoa>> findAll();
  Future<int> update(Pessoa pessoa);
  Future<int> delete(int id);
}

class PessoaDaoImpl implements PessoaDao {
  final Database db;

  PessoaDaoImpl(this.db);

  @override
  Future<int> insert(Pessoa pessoa) async {
    return await db.rawInsert(
      'INSERT INTO pessoas (nome, idade) VALUES (?, ?)',
      [pessoa.nome, pessoa.idade],
    );
  }

  @override
  Future<Pessoa?> findById(int id) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM pessoas WHERE id = ?',
      [id],
    );
    if (maps.isEmpty) return null;
    return Pessoa.fromMap(maps.first);
  }

  @override
  Future<List<Pessoa>> findAll() async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM pessoas ORDER BY nome',
    );
    return maps.map((map) => Pessoa.fromMap(map)).toList();
  }

  @override
  Future<int> update(Pessoa pessoa) async {
    return await db.rawUpdate(
      'UPDATE pessoas SET nome = ?, idade = ? WHERE id = ?',
      [pessoa.nome, pessoa.idade, pessoa.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    return await db.rawDelete('DELETE FROM pessoas WHERE id = ?', [id]);
  }
}
