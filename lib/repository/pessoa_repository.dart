import '../core/result.dart';
import '../dao/pessoa_dao.dart';
import '../models/pessoa_model.dart';

abstract class IPessoaRepository {
  Future<Result<int>> addPessoa(Pessoa pessoa);
  Future<Result<Pessoa?>> getPessoa(int id);
  Future<Result<List<Pessoa>>> getPessoas();
  Future<Result<int>> updatePessoa(Pessoa pessoa);
  Future<Result<int>> deletePessoa(int id);
}

class PessoaRepository implements IPessoaRepository {
  final PessoaDao _dao;

  PessoaRepository(this._dao);

  @override
  Future<Result<int>> addPessoa(Pessoa pessoa) async {
    try {
      final id = await _dao.insert(pessoa);
      return Result.success(id);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Pessoa?>> getPessoa(int id) async {
    try {
      final pessoa = await _dao.findById(id);
      return Result.success(pessoa);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Pessoa>>> getPessoas() async {
    try {
      final pessoas = await _dao.findAll();
      return Result.success(pessoas);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<int>> updatePessoa(Pessoa pessoa) async {
    try {
      final result = await _dao.update(pessoa);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<int>> deletePessoa(int id) async {
    try {
      final result = await _dao.delete(id);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
