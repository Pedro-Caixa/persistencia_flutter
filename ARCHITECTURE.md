# Arquitetura do Projeto

Este documento descreve a nova arquitetura do projeto de persistência local com Flutter, explicando as diferentes camadas e suas responsabilidades.

## Estrutura de Diretórios

```
lib/
├── main.dart
├── controllers/
│   ├── database_controller.dart    # Controle de acesso ao banco de dados
│   └── pessoa_controller.dart      # Gerenciamento de estado das pessoas
├── core/
│   ├── database_factory.dart       # Inicialização do banco por plataforma
│   └── result.dart                # Wrapper para resultados e erros
├── dao/
│   └── pessoa_dao.dart            # Acesso direto ao banco para Pessoas
├── models/
│   └── pessoa_model.dart          # Modelo de dados Pessoa
├── repository/
│   └── pessoa_repository.dart     # Camada de abstração de dados
└── views/
    ├── main_ui.dart              # Tela principal
    ├── pessoa_form.dart          # Componente de formulário
    └── pessoa_list.dart          # Componente de listagem
```

## Camadas da Aplicação

### 1. Camada de Apresentação (Views)
- Localização: `/views`
- Responsabilidade: Interface do usuário e interações
- Componentes:
  - `main_ui.dart`: Tela principal que coordena formulário e lista
  - `pessoa_form.dart`: Componente isolado para entrada de dados
  - `pessoa_list.dart`: Componente isolado para exibição dos dados

### 2. Camada de Controle (Controllers)
- Localização: `/controllers`
- Responsabilidade: Gerenciamento de estado e lógica de negócios
- Componentes:
  - `pessoa_controller.dart`: Gerencia o estado da aplicação usando ChangeNotifier
  - `database_controller.dart`: Controla operações do banco de dados

### 3. Camada de Repositório
- Localização: `/repository`
- Responsabilidade: Abstração de acesso aos dados
- Componentes:
  - `pessoa_repository.dart`: Interface e implementação do repositório
  - Usa `Result<T>` para tratamento consistente de erros

### 4. Camada de Acesso a Dados (DAO)
- Localização: `/dao`
- Responsabilidade: Operações diretas no banco de dados
- Componentes:
  - `pessoa_dao.dart`: Implementa queries SQL para CRUD de Pessoas

### 5. Camada de Modelo
- Localização: `/models`
- Responsabilidade: Definição das entidades
- Componentes:
  - `pessoa_model.dart`: Modelo de dados com métodos de serialização

### 6. Camada Core
- Localização: `/core`
- Responsabilidade: Funcionalidades base e utilitários
- Componentes:
  - `database_factory.dart`: Inicialização do banco específica por plataforma
  - `result.dart`: Wrapper para tratamento de resultados e erros

## Fluxo de Dados

1. UI (Views) → Interage com o usuário
2. Controller → Gerencia estado e ações
3. Repository → Coordena operações de dados
4. DAO → Executa operações no banco
5. Database → Armazena os dados

## Padrões Implementados

1. **DAO (Data Access Object)**
   - Isola operações SQL em classes específicas
   - Usa SQL raw para maior controle

2. **Repository Pattern**
   - Abstrai fonte de dados
   - Implementa tratamento de erros consistente

3. **Factory Pattern**
   - `DatabaseFactory` para criar instâncias do banco
   - Lida com diferentes plataformas (mobile, desktop, web)

4. **State Management**
   - Usa `ChangeNotifier` para gerenciamento de estado
   - Centraliza lógica de negócios no controller

## Tratamento de Erros

- Uso do tipo `Result<T>` para encapsular sucesso/erro
- Tratamento consistente em toda a aplicação
- Propagação adequada até a UI

## Multiplataforma

O projeto suporta múltiplas plataformas através do `DatabaseFactory`:
- Mobile (Android/iOS): SQLite padrão
- Desktop (Windows/Linux/macOS): SQLite FFI
- Web: SQLite WASM

## Dependências Principais

- `sqflite`: Banco de dados SQLite para mobile
- `sqflite_common_ffi`: Suporte a desktop
- `sqflite_common_ffi_web`: Suporte a web
- `path_provider`: Gerenciamento de caminhos multiplataforma