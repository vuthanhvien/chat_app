import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ButtonType {
  primary,
  secondary,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class Button extends StatelessWidget {
  final String text;
  final Function onTap;
  final ButtonType type;
  final ButtonSize size;

  final bool isLoading;
  final bool disabled;

  const Button({
    Key? key,
    required this.text,
    required this.onTap,
    this.size = ButtonSize.medium,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fontSize = 16.0;
    var color = Colors.blue;
    var textColor = Colors.white;
    var height = 50.0;
    var opacity = disabled || isLoading ? 0.5 : 1.0;

    switch (type) {
      case ButtonType.primary:
        color = Colors.blue;
        textColor = Colors.white;
        break;
      case ButtonType.secondary:
        color = Colors.grey;
        textColor = Colors.black;
        break;
      case ButtonType.danger:
        color = Colors.red;
        textColor = Colors.white;
        break;
      case ButtonType.success:
        color = Colors.green;
        textColor = Colors.white;
        break;
    }
    switch (size) {
      case ButtonSize.small:
        fontSize = 12.0;
        height = 40.0;
        break;
      case ButtonSize.medium:
        fontSize = 16.0;
        height = 50.0;
        break;
      case ButtonSize.large:
        fontSize = 20.0;
        height = 60.0;
        break;
    }
    return InkWell(
      onTap: isLoading || disabled
          ? null
          : () {
              onTap();
            },
      child: Opacity(
        opacity: opacity,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? SizedBox(
                  width: fontSize,
                  height: fontSize,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 4,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}
