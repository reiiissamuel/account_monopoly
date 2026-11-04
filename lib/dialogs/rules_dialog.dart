import 'package:flutter/material.dart';

class RulesDialog extends StatefulWidget {
  const RulesDialog({super.key});

  /// Método estático utilitário para facilitar a chamada em qualquer tela
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const RulesDialog(),
    );
  }

  @override
  State<RulesDialog> createState() => _RulesDialogState();
}

class _RulesDialogState extends State<RulesDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _proposalPages = [
    {
      "icon": Icons.wifi,
      "title": "1. Todos Conectados em LAN",
      "content": "Cada jogador usa o seu próprio smartphone. Um dos jogadores cria a mesa e partilha o "
          "código de acesso com os demais. Tudo roda via rede local.",
    },
    {
      "icon": Icons.account_balance_wallet,
      "title": "2. Saldo e Transferências Digitais",
      "content": "Adeus às maquinhas e notas de papel! Tenha acesso ao teu saldo em tempo real, "
          "Você poderá fazer transferências diretas para outros jogadores e solicitar pagamentos ou recebimentos "
          "do banco de forma totalmente automatizada.",
    },
    {
      "icon": Icons.pie_chart,
      "title": "3. O Conceito de Ações",
      "contentRich": const TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: "Você não precisa mais comprar uma propriedade inteira. Agora as propriedades são "
                "transformadas em empresas de capital aberto e divididas em ",
          ),
          TextSpan(
            text: "pequenas frações chamadas Ações",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ". Comprar uma ação significa que você se tornou sócio daquele negócio no tabuleiro!",
          ),
        ],
      ),
    },
    {
      "icon": Icons.shopping_cart,
      "title": "4. Comprando Ações no Tabuleiro",
      "content": "Sempre que um jogador cair em uma propriedade, abre-se uma oportunidade de compra: "
          "um após o outro, os jogadores decidem quantas ações querem adquirir (o jogador pode optar por não comprar).",
    },
    {
      "icon": Icons.storefront,
      "title": "5. Vendendo e Criando Ofertas (P2P)",
      "content": "Quer fazer dinheiro rápido? Você pode vender parte das tuas ações. "
          "Basta criar uma oferta e ela aparecerá automaticamente na tela de ",
      "contentRichExtra": const TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: "Mercado (P2P)",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " para outros jogadores comprarem."),
        ],
      ),
    },
    {
      "icon": Icons.house,
      "title": "6. Pagando Aluguel",
      "content": "Se o jogador cair em uma propriedade com ações já vendidas, mesmo que ele tenha ações da propriedade, "
          "o aluguel será cobrado normalmente. O jogador também poderá comprar novas ações da propriedade ativando assim uma nova rodada de compras daquele ativo!",
    },
    {
      "icon": Icons.payments,
      "title": "7. Recebendo Lucros (Dividendos)",
      "content": "Investimentos dão frutos! No final de cada volta no tabuleiro, "
          "o banco calcula quanto cada propriedade faturou em aluguéis e distribui os lucros (",
      "contentRichExtra": const TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: "dividendos",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ") proporcionalmente para quem tem ações."),
        ],
      ),
    },
    {
      "icon": Icons.trending_up,
      "title": "8. Valorização e Desvalorização",
      "content": "O mercado não para! A cada nova rodada, com base no lucro gerado, o valor da ação de cada propriedade "
          "é recalculado. As empresas podem valorizar ou desvalorizar, alterando o preço do ativo no mercado.",
    },
    {
      "icon": Icons.star,
      "title": "9. Acionista Majoritário",
      "content": "Quem manda na empresa? O jogador que acumular mais da metade das ações de uma propriedade "
          "torna-se o acionista majoritário, ganhando assim o privilégio de ajustar a porcentagem de distribuição de lucros da empresa e construir casas (exclusivo para terrenos).",
    },
    {
      "icon": Icons.tune,
      "title": "10. Definindo o Payout (Lucro Distribuído)",
      "content": "Como acionista majoritário, defina a percentagem do lucro (payout) que será distribuída aos acionistas. "
          "Atenção: ",
      "contentRichExtra": const TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: "Distribuir 100% nem sempre é bom!",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: " O banco calcula o imposto e o reinvestimento automático com base no lucro retido.",
          ),
        ],
      ),
    },
    {
      "icon": Icons.loop,
      "title": "11. Nova Volta ao Tabuleiro",
      "content": "Completou uma volta inteira? Você já pode solicitar o seu bônus de rodada diretamente pelo app, "
          "garantindo aquela injeção de capital para os teus próximos investimentos.",
    },
    {
      "icon": Icons.receipt_long,
      "title": "12. Imposto de Renda e Restituição",
      "content": "Esqueça taxas fixas! O imposto de renda é dinâmico, baseado em toda a renda acumulada. "
          "Você o pode pagar quando quiser, mas será obrigado a liquidar se o tabuleiro o exigir. "
          "Após pagar, vocÊ poderá solicitar a sua ",
      "contentRichExtra": const TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: "restituição",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " pelo app!"),
        ],
      ),
    },
    {
      "icon": Icons.warning_amber,
      "title": "13. Empréstimos e Blacklist",
      "content": "Apertado de dinheiro? Peça um empréstimo usando o bônus ou as ações deuma propriedade como garantia. "
          "Cuidado: ",
      "contentRichExtra": const TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: "Quem não pagar a prazo perde as ações para o banco",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: " e caso não tenha dado ações como garantia, vai para a blacklist, ficando proibido de comprar ações até quitar a dívida.",
          ),
        ],
      ),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onInverseSurface,
          width: 1.5,
        ),
      ),
      title: Column(
        children: [
          Center(
            child: SizedBox(
              height: 60.0,
              width: 60.0,
              child: Image.asset(
                "icons/apptheme.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Guia e Regras do Jogo",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Trazendo a bolsa de valores para o seu tabuleiro",
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 260, // Altura fixa ideal para acomodar o card do carrossel confortavelmente
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _proposalPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _proposalPages[index];
                  return _buildCarouselCard(
                    icon: page["icon"],
                    title: page["title"],
                    content: page["content"],
                    contentRich: page["contentRich"],
                    contentRichExtra: page["contentRichExtra"],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Indicadores de pontos (Dots Indicator)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _proposalPages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão Voltar / Anterior
            _currentPage > 0
                ? TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text("Anterior", style: TextStyle(color: Colors.white70)),
                  )
                : const SizedBox.shrink(),

            // Botão Próximo / Entendi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage == _proposalPages.length - 1 ? Colors.green : Colors.white,
                foregroundColor: _currentPage == _proposalPages.length - 1 ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                if (_currentPage < _proposalPages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                _currentPage == _proposalPages.length - 1 ? "Vamos Jogar!" : "Próximo",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarouselCard({
    required IconData icon,
    required String title,
    String? content,
    TextSpan? contentRich,
    TextSpan? contentRichExtra,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (content != null && contentRichExtra == null)
                    Text(
                      content,
                      style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.3),
                    ),
                  if (contentRich != null)
                    RichText(
                      text: contentRich,
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  if (content != null && contentRichExtra != null)
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.3),
                        children: [
                          TextSpan(text: content),
                          contentRichExtra,
                        ],
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}