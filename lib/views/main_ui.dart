import 'package:exemplo/controllers/database_controller.dart';
import 'package:exemplo/models/pessoa_model.dart';
import 'package:flutter/material.dart';
import 'package:exemplo/views/pessoa_form.dart';
import 'package:exemplo/views/pessoa_list.dart';

// ---------------------------
// 4) UI (CRUD)
// ---------------------------
class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();

  int? _editingId; // se != null, estamos editando
  late Future<List<Pessoa>> _futurePessoas;
  bool _isSaving = false;
  int _reloadTick = 0; // <--- NOVO

  @override
  void initState() {
    super.initState();
    _futurePessoas = DatabaseHelper.instance.getAll();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeCtrl.clear();
    _idadeCtrl.clear();
    _editingId = null;

    // desfoca teclado (especialmente no Web)
    FocusScope.of(context).unfocus();

    // avisa a UI que mudou (para atualizar botão/estado)
    setState(() {});
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePessoas = DatabaseHelper.instance.getAll();
      _reloadTick++; // muda a key e força rebuild do FutureBuilder
    });
  }

  Future<void> _salvar() async {
    if (_isSaving) return; // evita duplo clique / enter+clique
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final nome = _nomeCtrl.text.trim();
      final idade = int.parse(_idadeCtrl.text.trim());

      if (_editingId == null) {
        await DatabaseHelper.instance.insert(Pessoa(nome: nome, idade: idade));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pessoa adicionada!')),
        );
      } else {
        await DatabaseHelper.instance.update(
          Pessoa(id: _editingId, nome: nome, idade: idade),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pessoa atualizada!')),
        );
      }

      _limparFormulario();
      // deixa a UI respirar, e o FutureBuilder atualiza assim que o Future completar
      _refresh(); // dispara o FutureBuilder atualizar
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _apagar(int id) async {
    await DatabaseHelper.instance.delete(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pessoa removida.')),
    );
    await _refresh();
  }

  void _carregarParaEdicao(Pessoa p) {
    setState(() {
      _editingId = p.id;
      _nomeCtrl.text = p.nome;
      _idadeCtrl.text = p.idade.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas (SQLite)'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            PessoaForm(
              formKey: _formKey,
              nomeCtrl: _nomeCtrl,
              idadeCtrl: _idadeCtrl,
              isEditing: isEditing,
              isSaving: _isSaving,
              onSave: _salvar,
              onCancel: _limparFormulario,
            ),
            const Divider(height: 1),
            // Lista de pessoas
            Expanded(
              child: FutureBuilder<List<Pessoa>>(
                key: ValueKey(_reloadTick),
                future: _futurePessoas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  final pessoas = snapshot.data ?? const <Pessoa>[];
                  return PessoaList(
                    pessoas: pessoas,
                    onEdit: _carregarParaEdicao,
                    onDelete: _apagar,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
