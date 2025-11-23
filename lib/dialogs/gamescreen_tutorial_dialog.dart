import 'package:flutter/material.dart';

class GameScreenTutorialDialog extends StatelessWidget {
  const GameScreenTutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // A lista agora usa IconData ou String Path
    final List<Map<String, dynamic>> tutorialItems = [
      // Linha de Ações (AppBar)
      {
        'iconData': Icons.broadcast_on_personal_rounded,
        'title': 'Dados da Partida (Ícone no AppBar)',
        'description': 'Exibe o código da sessão para compartilhar com outros celulares para sincronizar seus aplicativos com o seu.',
      },
      {
        'iconData': Icons.exit_to_app,
        'title': 'Sair do Jogo (Ícone no AppBar)',
        'description': 'Abre um diálogo de confirmação para desconectar do jogo e retornar à tela inicial (Home Screen).',
      },

      // Botões Principais (Usando Paths de Imagem Customizada)
      {
        'iconPath': 'icons/buy.png',
        'title': 'Comprar',
        'description': 'Navega para a tela do Mercado (Market Screen) onde é possível comprar ações de empresas postas a venda, além de mostrar detalhes sobre todas as propriedades. Ações são pequenas frações das propriedades que podem ser compradas e estão sujeitas as variações de valorização de desvalorização de preço',
      },
      {
        'iconPath': 'icons/wallet.png',
        'title': 'Minha Carteira',
        'description': 'Navega para a tela do seu Portfólio, exibindo todas ações de propriedades compradas por você. Além do mais você terá opção de por seus ativos a venda e ver seu relatório financeiro.',
      },
      {
        'iconPath': 'icons/pay.png',
        'title': 'Transferir',
        'description': 'Abre a tela de Beneficiários para realizar transferências de crédito (dinheiro) para outros jogadores.',
      },
      {
        'iconPath': 'icons/rent.png',
        'title': 'Aluguel',
        'description': 'Use esta opção sempre que cair em uma propriedade do tabuleiro para pagar o aluguel referente a propriedade. Lembre-se, nesta versão de jogo, você paga aluguel mesmo nas propriedades das quais você tem ações.',
      },
      {
        'iconPath': 'icons/client.png',
        'title': 'Jogador',
        'description': 'Navega para a tela de Resumo do Jogador, mostrando o perfil, status, saldo e relatórios e financeiros',
      },
      {
        'iconPath': 'icons/loan.png',
        'title': 'Empréstimo',
        'description': 'Abre o diálogo de Empréstimo, permitindo solicitar um empréstimo usando ações como garantia (disponível apenas se empréstimos estiverem habilitado e você tiver ações).',
      },
      {
        'iconPath': 'icons/more.png',
        'title': 'Mais',
        'description': 'Abre o diálogo de Opções Adicionais ',
      },

      // Ações no Corpo da Tela (Usando Icons Nativos ou Paths Customizados)
      {
        'iconData': Icons.back_hand, // Floating Button
        'title': 'Pegar Carta Evento',
        'description': 'Caso você tenha habilitado eventos gerenciados pelo app, esta opção iniciará um evento (Chance Cards), aplicando seu efeito (benefício ou custo) ao seu saldo.',
      },
      {
        'iconData': Icons.show_chart, // Gráficos (Simulado)
        'title': 'Gráficos',
        'description': 'Navega para a tela de Balanço do Jogo, exibindo gráficos financeiros detalhados e relatórios de desempenho referentes ao jogador.',
      },
      {
        'iconData': Icons.tv, // Log de Eventos (Simulado)
        'title': 'Log de Eventos',
        'description': 'Área de rolagem que exibe o histórico de todas as transações, eventos e ações que ocorreram na partida, com destaque para as suas transações.',
      },

      //seção mais

      {
        'iconPath': 'icons/ir.png',
        'title': 'Imposto de renda',
        'description': 'Ao clicar neste botão seu imposto de renda será deduzido do seu capital. Tal como na vida real, o imposto de renda será uma taxa cobrada sobre todo o valor ganho por você, a contar da data da última cobrança.',
      },
      {
        'iconPath': 'icons/receive.png',
        'title': 'Receber do banco',
        'description': 'Esta opção serve para solicitar pagamentos ao banco provenientes de cartas evento(sorte ou revés).',
      },
      {
        'iconPath': 'icons/paybank.png',
        'title': 'Pagar ao banco',
        'description': 'Esta opção serve para enviar pagamentos ao banco provenientes de cartas evento(sorte ou revés).',
      },
      {
        'iconPath': 'icons/paybank.png',
        'title': 'Pagar ao banco',
        'description': 'Esta opção serve para enviar pagamentos ao banco provenientes de cartas evento(sorte ou revés).',
      },
      {
        'iconPath': 'icons/bonus.png',
        'title': 'Fechar rodada',
        'description': 'Use essa opção apenas quando passar pela casa "Início" no tabuleiro. Você receberá o bonus da rodada e qualquer dividendo retido pago as suas ações de propriedades',
      }
    ];

    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: primaryColor, width: 2.0),
      ),
      title: Center(
          child: Text('Manual de Utilização',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5))),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: tutorialItems.map((item) {
            return _buildTutorialItem(
                context,
                item['iconPath'],
                item['iconData'],
                item['title'] as String,
                item['description'] as String,
                primaryColor
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('FECHAR', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTutorialItem(
      BuildContext context,
      String? iconPath,
      IconData? iconData,
      String title,
      String description,
      Color primaryColor) {

    Widget iconWidget;

    if (iconPath != null) {
      // Usa Image.asset para ícones customizados (ex: 'icons/wallet.png')
      iconWidget = Image.asset(iconPath, height: 30, width: 30, fit: BoxFit.contain);
    } else if (iconData != null) {
      // Usa Icon para ícones nativos do Flutter
      iconWidget = Icon(iconData, color: primaryColor, size: 30);
    } else {
      // Fallback
      iconWidget = Icon(Icons.help_outline, color: primaryColor, size: 30);
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 1.5)
            ),
            child: iconWidget,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 4.0),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 13.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}