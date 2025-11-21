import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/player.dart'; // Certifique-se de que o modelo Player está acessível
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/screens/beneficiaries_screen.dart';
import 'package:account_monopoly/screens/game_balance_screen.dart';
import 'package:account_monopoly/screens/my_portfolio_screen.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/widgets/game_icon_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerSummaryScreen extends StatefulWidget {
  const PlayerSummaryScreen({super.key});

  @override
  State<PlayerSummaryScreen> createState() => _PlayerSummaryScreenState();
}

class _PlayerSummaryScreenState extends State<PlayerSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para reagir às mudanças no GameProvider e UserProvider
    return Consumer<GameProvider>(
        builder: (context, gameProvider, child) {

          // Assume que o jogador atual está no UserProvider, mas a lógica do GameProvider
          // para o 'currentPlayer' é mais segura neste contexto.
          final Player? player = gameProvider.currentPlayer;
          final Color primaryColor = Theme.of(context).primaryColor;

          if (player == null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Resumo do Jogador")),
              body: const Center(child: Text("Carregando dados do jogador...")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: const Text(
                // Você pode querer usar o nome do jogador se ele estiver disponível
                "Resumo Financeiro",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),

            backgroundColor: Colors.black, // Fundo escuro para contraste

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Destaque do Crédito Atual
                  _buildCreditCard(context, player, primaryColor),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Ações", primaryColor),
                  const SizedBox(height: 10),
                  Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        GameIconButtonBuilder(
                            imgPath: "icons/wallet.png",
                            title: "Minha carteira",
                            textFontSize: 13,
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPortfolioScreen()));
                            }
                        ),

                        GameIconButtonBuilder(
                            imgPath: "icons/pay.png",
                            title: "Transferir",
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const BeneficiariesScreen()));
                            }
                        ),
                        GameIconButtonBuilder(
                            imgPath: "icons/graph.png",
                            title: "Relatórios",
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const GameBalanceScreen()));
                            }
                        )
                      ]
                  ),
                  const SizedBox(height: 20),

                  // 2. Títulos Financeiros
                  _buildSectionTitle("Transações e Impostos", primaryColor),
                  const SizedBox(height: 10),
                  // 3. Totais Recebidos e Pagos
                  _buildTransactionRow(
                    icon: Icons.arrow_upward_rounded,
                    label: "Total Recebido (Ganhos)",
                    value: player.receivedFrom,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 10),
                  _buildTransactionRow(
                    icon: Icons.arrow_downward_rounded,
                    label: "Total Pago (Despesas)",
                    value: player.payedTo,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 20),

                  // 4. Seção de Impostos
                  _buildSectionTitle("Situação Fiscal", primaryColor),
                  const SizedBox(height: 10),

                  _buildTaxRow(
                    icon: Icons.gavel,
                    label: "Imposto de Renda (IR)",
                    value: player.incomeTax,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 10),
                  _buildTaxRow(
                    icon: Icons.local_atm,
                    label: "Restituição Fiscal",
                    value: player.taxRefund,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Empréstimos Ativos", primaryColor),
                  const SizedBox(height: 10),
                  _buildLoansList(context, player.loans.where((l) => !l.isPaidOff).toList(), gameProvider),
                ],
              ),
            ),
          );
        });
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildCreditCard(BuildContext context, Player player, Color primaryColor) {
    // Determina a cor do crédito com base na situação
    final double initialCredit = player.currentCredit + player.receivedFrom - player.payedTo; // Uma estimativa simplificada do crédito inicial
    final Color creditColor = _creditSituationColor(player.currentCredit, initialCredit);

    return Card(
      color: primaryColor.withValues(alpha: 0.1),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: primaryColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "CRÉDITO ATUAL",
              style: TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              StringUtils.currencyFormat(player.currentCredit),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: creditColor,
                letterSpacing: 2,
              ),
            ),
            const Divider(color: Colors.white12, height: 20),
            Text(
              "Patrimônio Líquido: ${StringUtils.currencyFormat(player.currentCredit)} + Ativos - Dívidas",
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildTransactionRow({required IconData icon, required String label, required double value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            StringUtils.currencyFormat(value),
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Reutiliza o estilo de linha para Impostos
  Widget _buildTaxRow({required IconData icon, required String label, required double value, required Color color}) {
    return _buildTransactionRow(icon: icon, label: label, value: value, color: color);
  }

  Widget _buildLoansList(BuildContext context, List<Loan> loans, GameProvider gameProvider) {
    if (loans.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Nenhum empréstimo ativo.", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
        ),
      );
    }

    // Lista de empréstimos
    return Column(
      children: loans.map((loan) {
        // Assume que Loan tem propriedades: amount, remainingTurns, interestRate
        final bool isMortgageLoan = loan.type == LoanType.mortgage; // Adaptar conforme sua estrutura
        final Color loanColor = loan.type == LoanType.mortgage ? Colors.lightBlue : Colors.purpleAccent;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: loanColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: loanColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Valor em aberto: ${StringUtils.currencyFormat(loan.remainingDebt)}",
                  style: TextStyle(color: loanColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "Valor quitado: ${StringUtils.currencyFormat(loan.principalPaid)}",
                  style: TextStyle(color: loanColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Valor emprestado:", style: TextStyle(color: Colors.white70)),
                    Text(StringUtils.currencyFormat(loan.principalBorrowed), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Rodadas restantes:", style: TextStyle(color: Colors.white70)),
                    Text("${loan.roundsToPayOff}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Garantia:", style: TextStyle(color: Colors.white70)),
                    Text(
                      isMortgageLoan ? "${loan.collateralAmountShares} ações de ${loan.collateralId!}" : "Bônus de Turno", // Adapte loan.collateralName
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.label),
                  label: const Text("Pagar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () {
                    // Ação: Abrir diálogo para criar oferta de venda (P2P)
                    _showPayLoanDialog(context, loan, gameProvider, loanColor);
                  },
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPayLoanDialog(BuildContext context, Loan loan, GameProvider gameProvider, Color loanColor) {
    final TextEditingController paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pagar Empréstimo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center
          ),
          backgroundColor: loanColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Dívida total: ${StringUtils.currencyFormat(loan.remainingDebt)}"),
              Text("Prazo (rodadas): ${loan.roundsToPayOff}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),
              const SizedBox(height: 10),
              TextField(
                  controller: paymentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Qual valor deseja pagar",
                      hintText: "Ex: 100.000",
                      labelStyle: TextStyle(color: Colors.white54),
                      hoverColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(
                              color: Colors.white, width: 5.0
                          )
                      ),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(
                              color: Colors.blueGrey, width: 3.0
                          )
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(
                              color: Colors.blueGrey, width: 3.0
                          )
                      )
                  )
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Confirmar pagamento", style: TextStyle(color: Colors.black)),
              onPressed: () {
                try {
                  final double? payment = double.tryParse(paymentController.text);
                  if (payment == null || payment! < 0) {
                    throw MissValueException("Você não preencheu os campos ou a quantidade é inválida.");
                  }
                  gameProvider.eventComposer(
                      type: EventType.loanPayment,
                      loan: loan,
                      value: payment
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pagamento realizado"), backgroundColor: Colors.green));
                  Navigator.of(context).pop();
                } on DomainException catch(e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Função para determinar a cor do crédito (copiada da GameScreen)
  Color _creditSituationColor(double value, double initialCredit){
    if(value >= (initialCredit * .6)){ //60%
      return Colors.green;
    } else if(value >= (initialCredit * .5)){
      return Colors.yellow;
    } else if(value >= (initialCredit * .3)){
      return Colors.orange;
    }else{
      return Colors.red;
    }
  }
}