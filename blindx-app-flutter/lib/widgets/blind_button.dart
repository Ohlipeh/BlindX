import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlindButton extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback onTap;
  final bool isLoading; // Novo: Para saber se a IA está processando
  final Color backgroundColor;
  final Color textColor;

  const BlindButton({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.isLoading = false,
    this.backgroundColor = Colors.yellowAccent,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "$label. $hint", // Lê tudo junto para o TalkBack
      enabled: !isLoading,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  // Feedback tátil padrão do botão
                  if (!isLoading) HapticFeedback.heavyImpact();
                  onTap();
                },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Se estiver carregando, fica cinza
              color: isLoading ? Colors.grey[800] : backgroundColor,
              borderRadius: BorderRadius.circular(25),
              border:
                  isLoading ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32, // Fonte gigante
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
