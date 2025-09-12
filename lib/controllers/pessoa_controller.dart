import 'package:flutter/foundation.dart';
import '../models/pessoa_model.dart';
import '../repository/pessoa_repository.dart';
import '../core/result.dart';

class PessoaStore extends ChangeNotifier {
  final IPessoaRepository _repository;
  
  List<Pessoa> _pessoas = [];
  bool _isLoading = false;
  String? _error;
  
  PessoaStore(this._repository);
  
  List<Pessoa> get pessoas => _pessoas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadPessoas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _repository.getPessoas();
    if (result.isSuccess) {
      _pessoas = result.data ?? [];
    } else {
      _error = result.error;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> addPessoa(Pessoa pessoa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _repository.addPessoa(pessoa);
    _isLoading = false;
    
    if (result.isSuccess) {
      await loadPessoas();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updatePessoa(Pessoa pessoa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _repository.updatePessoa(pessoa);
    _isLoading = false;
    
    if (result.isSuccess) {
      await loadPessoas();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deletePessoa(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _repository.deletePessoa(id);
    _isLoading = false;
    
    if (result.isSuccess) {
      await loadPessoas();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }
}
