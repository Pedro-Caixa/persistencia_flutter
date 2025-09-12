import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definindo as classes diretamente no teste para evitar problemas de import

// Classe Pessoa (copie da sua implementação)
class Pessoa {
  final int? id;
  final String nome;
  final int idade;

  const Pessoa({this.id, required this.nome, required this.idade});

  Pessoa copyWith({int? id, String? nome, int? idade}) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Pessoa &&
            other.id == id &&
            other.nome == nome &&
            other.idade == idade);
  }

  @override
  int get hashCode => Object.hash(id, nome, idade);
}

// Classe Result simplificada
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => switch (this) {
    Success<T> success => success.data,
    Failure<T> _ => null,
  };

  String? get message => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.message,
  };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

// Interface do DAO
abstract class PessoaDao {
  Future<int> insert(Pessoa pessoa);
  Future<Pessoa?> findById(int id);
  Future<List<Pessoa>> findAll();
  Future<int> update(Pessoa pessoa);
  Future<int> delete(int id);
}

// Repository implementado no teste
class PessoaRepository {
  final PessoaDao _dao;

  PessoaRepository(this._dao);

  Future<Result<int>> addPessoa(Pessoa pessoa) async {
    try {
      final id = await _dao.insert(pessoa);
      return Result.success(id);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<Pessoa>>> getPessoas() async {
    try {
      final pessoas = await _dao.findAll();
      return Result.success(pessoas);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Pessoa?>> getPessoa(int id) async {
    try {
      final pessoa = await _dao.findById(id);
      return Result.success(pessoa);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<int>> updatePessoa(Pessoa pessoa) async {
    try {
      final result = await _dao.update(pessoa);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<int>> deletePessoa(int id) async {
    try {
      final result = await _dao.delete(id);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

// Mock
class MockPessoaDao extends Mock implements PessoaDao {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Pessoa(nome: 'test', idade: 25));
  });

  group('PessoaRepository Tests', () {
    late MockPessoaDao mockDao;
    late PessoaRepository repository;

    setUp(() {
      mockDao = MockPessoaDao();
      repository = PessoaRepository(mockDao);
    });

    test('addPessoa deve retornar sucesso', () async {
      // Arrange
      const pessoa = Pessoa(nome: 'Alice', idade: 30);
      when(() => mockDao.insert(any())).thenAnswer((_) async => 1);

      // Act
      final result = await repository.addPessoa(pessoa);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(1));
      verify(() => mockDao.insert(pessoa)).called(1);
    });

    test('addPessoa deve retornar falha quando DAO falha', () async {
      // Arrange
      const pessoa = Pessoa(nome: 'Bob', idade: 25);
      when(() => mockDao.insert(any())).thenThrow(Exception('Erro no banco'));

      // Act
      final result = await repository.addPessoa(pessoa);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.message, contains('Erro no banco'));
    });

    test('getPessoas deve retornar lista com sucesso', () async {
      // Arrange
      final pessoas = [
        const Pessoa(id: 1, nome: 'Alice', idade: 30),
        const Pessoa(id: 2, nome: 'Bob', idade: 25),
      ];
      when(() => mockDao.findAll()).thenAnswer((_) async => pessoas);

      // Act
      final result = await repository.getPessoas();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.first.nome, equals('Alice'));
    });

    test('getPessoas deve retornar falha quando DAO falha', () async {
      // Arrange
      when(() => mockDao.findAll()).thenThrow(Exception('Conexão falhou'));

      // Act
      final result = await repository.getPessoas();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.message, contains('Conexão falhou'));
    });

    test('getPessoa deve retornar pessoa quando encontrada', () async {
      // Arrange
      const pessoa = Pessoa(id: 1, nome: 'Alice', idade: 30);
      when(() => mockDao.findById(1)).thenAnswer((_) async => pessoa);

      // Act
      final result = await repository.getPessoa(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.nome, equals('Alice'));
    });

    test('updatePessoa deve retornar sucesso', () async {
      // Arrange
      const pessoa = Pessoa(id: 1, nome: 'Alice Updated', idade: 31);
      when(() => mockDao.update(any())).thenAnswer((_) async => 1);

      // Act
      final result = await repository.updatePessoa(pessoa);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(1));
    });

    test('deletePessoa deve retornar sucesso', () async {
      // Arrange
      when(() => mockDao.delete(1)).thenAnswer((_) async => 1);

      // Act
      final result = await repository.deletePessoa(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(1));
    });
  });
}
