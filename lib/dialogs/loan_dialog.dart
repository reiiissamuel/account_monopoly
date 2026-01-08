// dialogs/loan_dialog.dart (CÓDIGO COMPLETO)

import 'dart:async'; // Mantido caso haja uso futuro de Future.delayed

import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanDialog extends StatefulWidget {
  const LoanDialog({super.key});

  @override
  LoanDialogState createState() => LoanDialogState();
}

class LoanDialogState extends State<LoanDialog> {

  final String bonusLabel = "Bonus da rodada";
  int _roundValueSelected = 3;
  final List<int> _turnValueList = [2, 3, 4, 5];

  final TextEditingController _totalDueController = TextEditingController(); // Valor total a pagar (Display)
  LoanType _selectedLoanType = LoanType.mortgage;


  // Variável de Estado para a Propriedade (preenchida se _selectedLoanType for um Ativo)
  late ShareHolder _selectedPropertyCollateral;

  late GameProvider gameProvider;

  // --- CONSTANTES DE NEGÓCIO ---

  static const double ASSET_LIQUIDATION_FACTOR = 0.80; // porcentagem do ativo hipotecado para emprestimo
  static const double ASSET_INTEREST_PER_TURN = 0.05;  // 5% de juros por roundo
  static const int BONUS_FIXED_TURNS = 3;              // 3 roundos fixos para bônus
  static const double BONUS_FIXED_INTEREST = 0.15;      // 15% de juros fixos para bônus

  // --- GETTERS DE VALOR CALCULADO ---

  // Valor Disponível para Empréstimo, determinado pela garantia
  double get _loanAmountAvailable {
    if (_selectedLoanType == LoanType.bankLoan) {
      // Valor do bônus do jogador
      return gameProvider.ledger.roundBonus;
    } else if (_selectedLoanType == LoanType.mortgage) {
      // 80% do valor atual do ativo
      return _selectetShareHolderValue * ASSET_LIQUIDATION_FACTOR;
    }
    return 0.0;
  }

  double get _selectetShareHolderValue => gameProvider.ledger.calculateShareHolderValue(_selectedPropertyCollateral);


  @override
  void initState() {
    super.initState();
    gameProvider = Provider.of<GameProvider>(context, listen: false);
    _selectedPropertyCollateral = gameProvider.currentPlayer.portfolio.values.first;
    Future.delayed(Duration.zero, (){
      _updateValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usar watch para reconstruir se o provedor mudar (e.g., carteira, bônus)
    gameProvider = context.watch<GameProvider>();
    final List<ShareHolder> portfolio = gameProvider.currentPlayer.portfolio.values.toList();

    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20.0)),
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 350),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Text("🤝🏾Empréstimo",
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                ),
              ),
              const Divider(color: Colors.white70),
              const SizedBox(height: 15),

              _buildLoanDropdown(context),
              const SizedBox(height: 15),

              if(_selectedLoanType == LoanType.mortgage) ...[
                // 1. SELEÇÃO DE GARANTIA
                _buildCollateralDropdown(context, portfolio),
                const SizedBox(height: 15)
              ],

              // 2. VALOR DISPONÍVEL (CALCULADO PELA GARANTIA)
              _buildCalculatedAmountDisplay(context),
              const SizedBox(height: 15),

              // 3. SELEÇÃO DE PARCELAS (APENAS SE FOR GARANTIA DE ATIVO)
              if (_selectedLoanType != LoanType.bankLoan && _selectedPropertyCollateral != null)
                _buildTurnsDropdown(context, gameProvider),

              const SizedBox(height: 15),

              // 4. INFORMAÇÕES DO EMPRÉSTIMO (Juros e Detalhes da Garantia)
              _buildRateInfoCard(context),

              if (_selectedPropertyCollateral != null && _selectedPropertyCollateral != null) ...[
                const SizedBox(height: 10),
                _buildCollateralInfoCard(context, _selectedPropertyCollateral!),
              ],

              const SizedBox(height: 20),

              // 5. VALOR TOTAL A PAGAR (DISPLAY)
              _buildTotalValueDisplay(context),

              const SizedBox(height: 20),

              // 6. BOTÕES DE AÇÃO
              _buildActionButtons(context, gameProvider),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  // Dropdown de Garantia Principal
  Widget _buildLoanDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tipo do empréstimo", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LoanType>(
              isExpanded: true,
              value: _selectedLoanType,
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: LoanType.values.map((type) {
                return DropdownMenuItem<LoanType>(
                  value: type,
                  child: Text(type.description,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
                  ),
                );
              }).toList(),
              onChanged: (LoanType? newType) {
                setState(() {
                  _selectedLoanType = newType!;
                  _roundValueSelected = 3; // Reseta as parcelas para o padrão
                  _updateValue();
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown de Garantia Principal
  Widget _buildCollateralDropdown(BuildContext context, List<ShareHolder> portfolio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Escolha a Garantia:", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ShareHolder>(
              isExpanded: true,
              value: _selectedPropertyCollateral,
              hint: const Text("Selecione um ativo ou bônus", style: TextStyle(color: Colors.white54)),
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: portfolio.map((option) {
                return DropdownMenuItem<ShareHolder>(
                  value: option,
                  child: Text(option.propertyId,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
                  ),
                );
              }).toList(),
              onChanged: (ShareHolder? newValue) {
                setState(() {
                  _selectedPropertyCollateral = newValue!;
                  // Atualiza a propriedade selecionada para fácil acesso
                  _roundValueSelected = 3; // Reseta as parcelas para o padrão
                  _updateValue();
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // Novo: Exibe o valor do empréstimo calculado
  Widget _buildCalculatedAmountDisplay(BuildContext context) {
    final Color amountColor = _loanAmountAvailable > 0 ? Colors.greenAccent : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Valor Disponível (Empréstimo):", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 5),
        Container(
            height: 40.0,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: amountColor)),
            child: Text(
              StringUtils.currencyFormat(_loanAmountAvailable),
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: amountColor),
            )),
      ],
    );
  }

  // Dropdown de Turnos (Apenas para Ativos)
  Widget _buildTurnsDropdown(BuildContext context, GameProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text("Vencimento(Turnos):", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white)),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              dropdownColor: const Color(0xFF1E1E1E),
              value: _roundValueSelected,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (int? data) {
                setState(() {
                  _roundValueSelected = data ?? _roundValueSelected;
                  _updateValue();
                });
              },
              items: _turnValueList.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Informações de Taxa de Juros
  Widget _buildRateInfoCard(BuildContext context) {
    if (_selectedLoanType == null) {
      return Container();
    }

    final Color indicatorColor = _selectedLoanType == LoanType.bankLoan ? Colors.lightBlueAccent : Colors.yellow;
    final String rateText = _selectedLoanType == LoanType.bankLoan
        ? "15% total (Fixo em $BONUS_FIXED_TURNS roundos)"
        : "${(ASSET_INTEREST_PER_TURN * 100).toInt()}% por roundo";

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: indicatorColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Juros do Empréstimo: $rateText",
              style: TextStyle(color: indicatorColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Detalhes da Garantia de Ativo
  Widget _buildCollateralInfoCard(BuildContext context, ShareHolder item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Detalhes da Garantia:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 10),
          if(_selectedLoanType == LoanType.mortgage)...[
            _buildDetailRow("Valor do Ativo:", StringUtils.currencyFormat(_selectetShareHolderValue), Colors.white70)
          ],
          _buildDetailRow("Máximo liberado:", StringUtils.currencyFormat(_loanAmountAvailable), Colors.yellowAccent),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // Display do Valor Total a Pagar
  Widget _buildTotalValueDisplay(BuildContext context) {
    return Container(
      height: 45.0,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: const Color(0xFF003462), // Azul escuro
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.white24)),
      child: TextField(
          cursorColor: Colors.white,
          controller: _totalDueController,
          readOnly: true,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Colors.yellowAccent // Destaque para o total
          ),
          decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: Icon(Icons.money_off, color: Colors.redAccent), // Ícone de dívida
              hintText: "Valor Total a Pagar",
              hintStyle: TextStyle(color: Colors.white54, fontSize: 15)
          )),
    );
  }

  // Botões de Ação Final
  Widget _buildActionButtons(BuildContext context, GameProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text("CANCELAR", style: TextStyle(fontSize: 11.0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("CONCLUIR", style: TextStyle(fontSize: 11.0)),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: _loanAmountAvailable > 0 ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
          ),
          onPressed: _loanAmountAvailable > 0
              ? () => _confirmLoan(context, gameProvider)
              : null,
        ),
      ],
    );
  }

  // --- LÓGICA DE NEGÓCIO ---

  void _updateValue() {
    final double loanAmount = _loanAmountAvailable;
    double totalToPay = 0.0;

    if (loanAmount > 0) {
      if (_selectedLoanType == LoanType.bankLoan) {
        // BÔNUS: Taxa e roundos fixos
        final double totalInterest = loanAmount * BONUS_FIXED_INTEREST;
        totalToPay = loanAmount + totalInterest;
      } else if (_selectedPropertyCollateral != null) {
        // ATIVO: Taxa por roundo * número de roundos
        final double totalInterestRate = ASSET_INTEREST_PER_TURN * _roundValueSelected;
        final double interestValue = loanAmount * totalInterestRate;
        totalToPay = loanAmount + interestValue;
      }
    }

    setState(() {
      _totalDueController.text = StringUtils.currencyFormat(totalToPay);
    });
  }

  void _confirmLoan(BuildContext context, GameProvider gameProvider) {

    // Define os parâmetros finais com base na garantia
    final bool isBonusCollateral = _selectedLoanType == LoanType.bankLoan;
    final int rounds = isBonusCollateral ? BONUS_FIXED_TURNS : _roundValueSelected;
    final double interestRate = isBonusCollateral ? BONUS_FIXED_INTEREST : ASSET_INTEREST_PER_TURN * rounds;

    // 2. Confirmação Final
    showDialog(context: context, builder: (BuildContext context) {
      return ConfirmActionDialog(
          title: "Confirmação de Empréstimo",
          textContent:
          "Valor Emprestado: ${StringUtils.currencyFormat(_loanAmountAvailable)}\n"
              "prazo: $rounds rodadas\n"
              "Juros Totais: ${(interestRate * 100).toStringAsFixed(1)}%\n"
              "Total a Pagar: ${_totalDueController.text}\n"
              "Garantia: ${isBonusCollateral ? 'Bônus de Turno' : _selectedPropertyCollateral!.propertyId}\n\n"
              "Você confirma o empréstimo?",
          onConfirm: () {
            try{
              // 3. Executa a Ação de Empréstimo no GameProvider
              gameProvider.eventComposer(
                  type: EventType.loan,
                  price: _loanAmountAvailable,
                  loan: Loan(
                      id: StringUtils.generateUUID(size: 5),
                      type: _selectedLoanType,
                      totalDue: StringUtils.currencyAsDouble(_totalDueController.text),
                      principalBorrowed: _loanAmountAvailable,
                      roundsToPayOff: _roundValueSelected,
                      collateralId: _selectedLoanType == LoanType.mortgage ? _selectedPropertyCollateral.propertyId : null,
                      collateralAmountShares: _selectedLoanType == LoanType.mortgage ? _selectedPropertyCollateral.sharesOwned : null
                  )
              );

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Empréstimo contratado com sucesso!"), backgroundColor: Colors.green));
            } on DomainException catch(e){
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
            }
            Navigator.of(context).pop();
          });
    });
  }
}