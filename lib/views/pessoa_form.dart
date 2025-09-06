import 'package:flutter/material.dart';

class PessoaForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeCtrl;
  final TextEditingController idadeCtrl;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const PessoaForm({
    super.key,
    required this.formKey,
    required this.nomeCtrl,
    required this.idadeCtrl,
    required this.isEditing,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o nome';
                }
                if (v.trim().length < 2) {
                  return 'Nome muito curto';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: idadeCtrl,
              decoration: const InputDecoration(
                labelText: 'Idade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe a idade';
                }
                final n = int.tryParse(v.trim());
                if (n == null || n < 0 || n > 150) {
                  return 'Idade inválida';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (!isSaving) onSave();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(
                      isEditing ? 'Salvar alterações' : 'Adicionar',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isEditing)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar edição'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
