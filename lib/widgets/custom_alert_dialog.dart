import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String description;
  final IconData icon;
  final String firstActionButtonText;
  final VoidCallback onFirstAction;
  final String? secondActionButtonText;
  final VoidCallback? onSecondAction;

  const CustomAlertDialog({
    super.key,
    required this.description,
    required this.icon,
    required this.firstActionButtonText,
    required this.onFirstAction,
    this.secondActionButtonText,
    this.onSecondAction,
  });

  /// Método estático utilitário para facilitar a chamada em qualquer ponto do código
  static void show(
    BuildContext context, {
    required String description,
    required IconData icon,
    required String firstActionButtonText,
    required VoidCallback onFirstAction,
    String? secondActionButtonText,
    VoidCallback? onSecondAction,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          description: description,
          icon: icon,
          firstActionButtonText: firstActionButtonText,
          onFirstAction: onFirstAction,
          secondActionButtonText: secondActionButtonText,
          onSecondAction: onSecondAction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onInverseSurface,
          width: 1.5,
        ),
      ),
      backgroundColor: Colors.black,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48.0, // Ícone de tamanho médio no topo
            color: Colors.amber,
          ),
          const SizedBox(height: 10.0),
          const Text(
            "ATENÇÃO",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      actions: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            // 1. Ação de Voltar / Cancelar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                "Voltar",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),

            // 2. Primeira ação customizada
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                firstActionButtonText,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onFirstAction();
              },
            ),

            // 3. Segunda ação customizada (opcional)
            if (secondActionButtonText != null && onSecondAction != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  secondActionButtonText!,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onSecondAction!();
                },
              ),
          ],
        ),
      ],
    );
  }
}