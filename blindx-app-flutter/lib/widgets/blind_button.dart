import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlindButton extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;

  const BlindButton({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.onLongPress,
    this.isLoading = false,
    this.backgroundColor = Colors.yellowAccent,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "$label. $hint",
      // Adicionando dica de acessibilidade para o toque longo
      hint:
          "Toque duas vezes para falar, ou segure para ativar o modo radar automático.",
      enabled: !isLoading,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  if (!isLoading) HapticFeedback.heavyImpact();
                  onTap();
                },
          onLongPress: isLoading ? null : onLongPress,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                        fontSize: 32,
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
