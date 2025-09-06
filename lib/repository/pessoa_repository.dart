import 'package:exemplo/models/pessoa_model.dart';
import 'package:exemplo/controllers/database_controller.dart';

class PessoaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addPessoa(Pessoa p) => _dbHelper.insert(p);

  Future<Pessoa?> getPessoa(int id) => _dbHelper.getById(id);

  Future<List<Pessoa>> getPessoas() => _dbHelper.getAll();

  Future<int> updatePessoa(Pessoa p) => _dbHelper.update(p);

  Future<int> deletePessoa(int id) => _dbHelper.delete(id);
}
