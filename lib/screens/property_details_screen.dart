import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/configs_constants.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/widgets/chart_property_report.dart';
import 'package:account_monopoly/widgets/game_icon_button_builder.dart';
import 'package:account_monopoly/widgets/percent_spinner.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class PropertyDetailsScreen extends StatefulWidget {
 final String propertyId;

 const PropertyDetailsScreen({super.key, required this.propertyId});

 @override
 State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {

int payout = 0;
bool _payoutInitialized = false;

double _markupUsage = 0;

 @override
 Widget build(BuildContext context) {
  return Consumer<GameProvider>(
   builder: (context, gameProvider, child) {
    final property = gameProvider.ledger.properties[widget.propertyId];
    final ledger = gameProvider.ledger;

    if (property == null) {
     return Scaffold(
      appBar: AppBar(title: const Text("Erro")),
      body: const Center(child: Text("Propriedade não encontrada.")),
     );
    }
        
    // CORREÇÃO: Inicializa 'payout' apenas uma vez usando o valor do ledger
    if (!_payoutInitialized) {
      payout = (property.payoutPercentage * 100).toInt();
      _payoutInitialized = true;
    }

    // --- CONTEÚDO DA TELA DE DETALHES ---
    return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
      backgroundColor: property.colorSignature,
      title: Text(property.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsPadding: const EdgeInsets.all(5),
      actions: (property.propertyType == PropertyType.stocks || property.majorOwnerId != gameProvider.currentPlayer.id)
       ? null : [
        property.buildings <= 4 
        ? GameIconButtonBuilder(
            imgPath: "icons/buildhome.png",
            height: 30,
            width: 30,
            onPressed: () => _processBuildingPurchase(context, property, gameProvider)
          )
        : GameIconButtonBuilder(
            imgPath: "icons/buildhotel.png",
            height: 30,
            width: 30,
            onPressed: () => _processBuildingPurchase(context, property, gameProvider)
          )
      ],
     ),
     body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
        _buildHeader(context, property),

        const SizedBox(height: 20),
        // 2. STATUS DO ATIVO
        _buildSectionTitle("📈 Status de Mercado", property.colorSignature),
        _buildStatusSection(context, property, ledger),
        
        const SizedBox(height: 20),
      
        // 3. MÉTICAS DE RENDA
        _buildSectionTitle("💰 Fluxo de Renda (Aluguel)", property.colorSignature),
        _buildIncomeSection(context, property),
        const SizedBox(height: 20),
        // 4. HISTÓRICO DE AÇÕES (Placeholder)

        _buildSectionTitle("📊 Histórico & Volatilidade", property.colorSignature),
        _buildHistoryPlaceholder(context, property),

        const SizedBox(height: 20),

        _buildPayoutChanger(context, gameProvider, property),
        const SizedBox(height: 20),
        
       ],
      ),
     ),
    );
   },
  );
 }

 // --- WIDGETS AUXILIARES ---
 Widget _buildSectionTitle(String title, Color color) {
  return Padding(
   padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
   child: Text(
    title,
    style: TextStyle(
     color: color, 
     fontSize: 18, 
     fontWeight: FontWeight.bold,
     letterSpacing: 1.2
    ),
   ),
  );
 }

 // Seção 1: Cabeçalho com Preço e Ícone
 Widget _buildHeader(BuildContext context, dynamic property) {
  return Container(
   padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
   decoration: BoxDecoration(
    color: property.colorSignature.withOpacity(0.15),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(color: property.colorSignature.withOpacity(0.5)),
   ),
   child: Row(
    children: [
     Icon(property.iconSignature.icon, size: 40, color: property.colorSignature),
     const SizedBox(width: 15),
     Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const Text("PREÇO ATUAL DA AÇÃO", style: TextStyle(color: Colors.white70, fontSize: 12)),
       Text(
        StringUtils.currencyFormat(property.sharePrice),
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
         color: Colors.white,
         fontWeight: FontWeight.w900,
         fontSize: 28
        ),
       ),
      ],
     ),
     const Spacer(),
     // Seção para variação do dia (Ex: +1.5%)
     // _buildPriceChangeIndicator(property),
    ],
   ),
  );
 }

 // Seção 2: Status do Ativo (Total de Ações, Valor Total, Edifícios)
 Widget _buildStatusSection(BuildContext context, Property property, Ledger ledger) {
  var currentPlayer = Provider.of<GameProvider>(context).currentPlayer;
  String? owner = (currentPlayer.id == property.majorOwnerId) ? currentPlayer.username : Provider.of<GameProvider>(context).otherPlayers[property.majorOwnerId]?.username;
  return Card(
   color: const Color(0xFF1E1E1E), // Fundo mais escuro
   elevation: 5,
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
   child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
     children: [
      _buildDetailRow("💰 Valor Total de Mercado (Market Cap)", StringUtils.currencyFormat(property.currentPrice), context, Colors.lightGreen),
      _buildDetailRow("🏠 Edifícios Construídos", property.buildings.toString(), context, Colors.white),
      _buildDetailRow("🏗️ Custo por construção", StringUtils.currencyFormat(property.currentBuildingCost), context, Colors.white),
      _buildDetailRow("💸 Despesas/Rodada", StringUtils.currencyFormat(property.currentPrice * ledger.propertyTaxRate), context, Colors.red),
      _buildDetailRow("🧾 Valor atual do aluguel", StringUtils.currencyFormat(property.currentRent), context, Colors.lightGreen),
      const Divider(color: Colors.white12),
      _buildDetailRow("🏷️ Ações Totais Emitidas", property.totalShares.toString(), context, Colors.white70),
      _buildDetailRow("🏦 Ações Disponíveis (Banco/Fundo)", property.availableShares.toString(), context, Colors.amber),
      _buildDetailRow("🧐 Acionista majoritario", owner ?? "", context, Colors.blue)
     ],
    ),
   ),
  );
 }

 // Seção 3: Métricas de Renda
 Widget _buildIncomeSection(BuildContext context, Property property) {
  
  final double currentProfitPerAction = (property.collectedRent / property.totalShares) * property.payoutPercentage;
  return Card(
   color: const Color(0xFF1E1E1E),
   elevation: 5,
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
   child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
     children: [
      _buildDetailRow("💵 Renda Base neste Turno", StringUtils.currencyFormat(property.collectedRent), context, Colors.lightGreenAccent),
      _buildDetailRow("📈 % Payout(Distribuição de Renda)", "${(property.payoutPercentage * 100).toStringAsFixed(0)}%", context, Colors.white),
      _buildDetailRow("🔄 Rendimento atual por Ação", StringUtils.currencyFormat(currentProfitPerAction), context, Colors.cyanAccent),
     ],
    ),
   ),
  );
 }

 // Seção 4: Placeholder de Histórico
Widget _buildHistoryPlaceholder(BuildContext context, Property property) {
  return Container(
      height: 400,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          const Icon(Icons.trending_up, size: 20, color: Colors.white30),
          const SizedBox(height: 5),
          const Text("Gráfico de Volatilidade e Histórico de Preços", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 4),
          Expanded(
            child: ChartPropertyReport(property: property),
          ),
        ],
      )
  );
}

 Widget _buildPayoutChanger(BuildContext context, GameProvider gameProvider, Property property) {
  var configEnabled = (property.majorOwnerId == gameProvider.currentPlayer.id);  
  return Container(
   padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
   decoration: BoxDecoration(
    color: property.colorSignature.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(color: property.colorSignature.withValues(alpha: .5)),
   ),
   child: Center(
    child: Column(
     mainAxisAlignment: MainAxisAlignment.center,
     children: [
      const Text(
       'Ajuste de Payout',
       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      const SizedBox(height: 30),
      configEnabled ? PercentSpinner(
       label: 'Payout',
       initialValue: payout, // Usa o valor atual do estado local
       step: 5,
       onChanged: (newValue) =>{
        setState(() { 
         payout = newValue;
        })
       },
      ) : const Text(
        "🔒 Somente o acionista com mais de 50% das ações desta propriedade pode alterar o payout.",
         style: TextStyle(color: Colors.white, fontSize: 16)
        ),
      const Divider(color: Colors.white12),
      ElevatedButton.icon(
        onPressed: !configEnabled ? null : (){
         gameProvider.eventComposer(
          type: EventType.propertyUpdatePayout,
          propertyId: property.id,
          price: (payout/100)
         );
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Payout atualizado")));
         Navigator.of(context).pop();
        },
        icon: const Icon(Icons.save, size: 30, color: Colors.white),
        label: const Text(
         'Salvar',
         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
         foregroundColor: Colors.white, 
         backgroundColor: property.colorSignature,
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
         shadowColor: Colors.black,
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
         ),
         elevation: 20,
        ),
       )
     ],
    ),
   ),
  );
 }

 // Helper para Linhas de Detalhe
 Widget _buildDetailRow(String label, String value, BuildContext context, Color valueColor) {
  return Padding(
   padding: const EdgeInsets.symmetric(vertical: 8.0),
   child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
     Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15))),
     Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
    ],
   ),
  );
 }

 void _processBuildingPurchase(BuildContext context, Property property, GameProvider gameProvider) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController newRentController = TextEditingController();
    double _dialogMarkup = _markupUsage;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Construir em ${property.name}",
           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
           textAlign: TextAlign.center,),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState){
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Espaço disponível: ${ConfigsConstants.maxBuildings - property.buildings} construções"),
                  const SizedBox(height: 15),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Quantidade de construções",
                      hintText: "Max. 2 por compra",
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
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ]
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: newRentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Novo valor do aluguel",
                      hintText: "Indicado no cartão da propriedade",
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
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ]
                  ),
                  const SizedBox(height: 15),
                  const Center(
                    child: Text("Qual % do markup da propriedade deseja usar",
                    textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 5),
                  Slider(
                    activeColor: Colors.black,
                    value: _markupUsage,
                    min: 0,
                    max: 30,
                    divisions: (30 / 5).toInt(), // 6 divisões (100/5)
                    label: "${_markupUsage.toStringAsFixed(0)} %",
                    onChanged: (double newValue) {
                      dialogSetState(() {
                          _dialogMarkup = newValue; // Atualiza a variável local para o rebuild
                        });
                        // 4. Atualiza a variável da classe State principal (_markupUsage) para persistência
                        _markupUsage = newValue;
                    },
                  ),
                  const SizedBox(height: 5),
                  const Center(child: TipIconButton(title: "Construções", tip: TipsResourse.BUILDINGS, width: 25.0, height: 25.0, iconSize: 19.0))
                ],
              );
            }
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Construir", style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                try{
                  final int? quantity = int.tryParse(quantityController.text);
                  final double? newRent = double.tryParse(newRentController.text);
                  
                  if(quantity == null || newRent == null) throw MissValueException("Você não preencheu os campos.");

                  gameProvider.eventComposer(
                    type: EventType.build,
                    propertyId: property.id,
                    newBuildings: quantity,
                    price: newRent,
                    markupUsage: _markupUsage.toInt()
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Construção iniciada"), backgroundColor: Colors.green));
                } on DomainException catch(e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}