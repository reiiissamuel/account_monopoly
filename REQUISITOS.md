Aqui está o documento `README.md` atualizado, com o acréscimo das regras de negócio mapeadas e especificadas com base na documentação técnica do TCC e nos componentes da arquitetura Peer-to-Peer do seu repositório:

```markdown
# Carteira de Monopólio

O aplicativo **Carteira de Monopólio** é um complemento inovador ao tradicional jogo de tabuleiro (Banco Imobiliário), integrando-o com mecânicas realistas do mercado financeiro e educacional para promover a educação financeira.

---

## 📋 Sobre a Aplicação

O projeto tem como objetivo principal mitigar a carência de conhecimento prático sobre investimentos e finanças da população, simulando ativos reais do mercado financeiro (como Fundos de Investimento Imobiliário - FIIs, ações e títulos públicos) diretamente associados às dinâmicas de uma partida de jogo de tabuleiro. 

### Principais Características e Tecnologias:
* **Framework:** Flutter (com linguagem Dart) para compatibilidade multiplataforma.
* **Arquitetura de Dados / Persistência:** Banco de dados NoSQL **Sembast**, otimizado para modelo de documentos.
* **Arquitetura de Conexão:** Conexão Ponto a Ponto (P2P), garantindo descentralização, resiliência e custo zero de servidor.
* **Modelagem:** Guiado pelo padrão *Domain-Driven Design* (DDD) para isolar e estruturar as complexas regras de negócio em domínios bem definidos.

---

## ⚙️ Regras de Negócio e Arquitetura do Jogo

### 1. Regras de Conexão e Eleição Peer-to-Peer (P2P)
* **Arquitetura Descentralizada:** A aplicação opera sem a necessidade de um servidor central de jogo (*Serverless*), eliminando custos de infraestrutura e dependências externas durante as partidas.
* **Descobrimento e Pareamento P2P (`peer_connection_controller.dart` / `peer_connection_controller_v2.dart`):** Os dispositivos estabelecem comunicação direta na rede local ou via protocolos P2P para sincronização do estado da partida em tempo real.
* **Eleição de Host / Nó Líder:** 
  * Um dos nós assume o papel de coordenador da sessão (Host) para validar a sequência de rodadas e consolidação dos estados de ativos/jogadores.
  * Em caso de desconexão ou falha do nóHost, a arquitetura P2P garante resiliência, utilizando sincronização do banco de dados local (**Sembast**) presente nos dispositivos dos demais pares para retomar a sessão sem perda do progresso do jogo.

---

### 2. Regras de Negócio do Jogo (`game_provider.dart` / `game.dart` / `game_screen.dart`)
* **Gestão de Carteira e Ativos Financeiros:**
  * **Fundos de Investimento Imobiliário (FIIs):** Cada propriedade possui uma quantidade fixa de cotas e valor de lançamento inicial. Os dividendos cobrados dos adversários ao pararem nas casas são distribuídos proporcionalmente aos cotistas (*Payout*).
  * **Valorização por Lucro Retido:** Os valores retidos e não distribuídos revertem em valorização do preço base da cota da propriedade/fundo.
  * **Ações e Títulos:** Simulação de volatilidade, permitindo compra, venda e negociação direta entre jogadores.

* **Dinâmicas de Empréstimo e Liquidez (`loan_dialog.dart` / `pay_rent_dialog.dart`):**
  * **Solicitação e Pagamento de Empréstimos:** Jogadores podem tomar empréstimos para obter liquidez imediata, sujeitos a taxas e prazos simulados durante a partida.
  * **Cobrança Automática de Aluguel/Rendimento:** Cômputo e liquidação direta das transferências entre a carteira do pagador e os detentores dos ativos.

* **Impostos, Riscos e Eventos:**
  * **Risco de Tributação e Custos:** Mecanismos que simulam imposto de renda, custos operacionais e taxa de manutenção de construções.
  * **Eventos Locais (Sorte ou Revés):** Flutuações imprevisíveis que alteram pontualmente o valor de mercado das propriedades ou a liquidez do jogador.

---

## 📂 Estrutura do Projeto (`lib`)

* **`dialogs/`**: Modais e diálogos interativos do usuário:
  * `loan_dialog.dart` (Gestão e solicitação de empréstimos)
  * `pay_rent_dialog.dart` (Liquidação e pagamento de rendimentos)
  * `load_user_dialog.dart` / `new_user_dialog.dart` (Gerenciamento de perfil e entrada)
  * `more_options_dialog.dart` / `custom_keyboard_dialog.dart` (Utilitários de interface)
  * `gamescreen_tutorial_dialog.dart` / `table_info_dialog.dart` / `winner_dialog.dart` (Auxiliares do jogo)

* **`widgets/`**: Componentes visuais e relatórios de desempenho:
  * `chart_property_report.dart`, `chart_two.dart`, `chart_three.dart` (Gráficos de evolução patrimonial e valor das cotas)
  * `counter_stepper.dart`, `percent_spinner.dart` (Seleção e ajuste de cotas/valores)

* **`repository/` & `service/`**:
  * `user_repository.dart` (Persistência Sembast do usuário)
  * `google_login.dart` (Autenticação externa)

* **`teste/`**:
  * `teste.dart`, `teste2.dart` (Arquivos de teste)

---

## 🤖 Contexto para Análise do Código por IA

> **Prompt de Contexto para IAs:**
> "Este é o código-fonte do aplicativo **'Carteira de Monopólio'**, construído em **Flutter (Dart)** com persistência local em **Sembast (NoSQL)** e modelagem orientada a **Domain-Driven Design (DDD)**. O sistema gerencia rodadas, partidas e sincronização **P2P** através do `PeerConnectionController` sem dependência de servidor central. As regras financeiras simulam FIIs, cotas, valorização por lucro retido, *payout*, empréstimos (`loan_dialog.dart`), cobrança de rendimentos (`pay_rent_dialog.dart`) e relatórios gráficos patrimoniais (`chart_property_report.dart`). Analise o código considerando a eficiência do sincronismo P2P, isolamento dos domínios do DDD e integridade dos cálculos financeiros do jogo."

```