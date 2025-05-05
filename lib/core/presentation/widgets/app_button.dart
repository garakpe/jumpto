import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 버튼 위젯
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = isPrimary 
        ? ElevatedButton.styleFrom() 
        : OutlinedButton.styleFrom();
        
    final Widget buttonChild = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : _buildButtonContent();
        
    final Widget button = isPrimary
        ? ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: buttonChild,
          )
        : OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: buttonChild,
          );
    
    return isFullWidth
        ? SizedBox(
            width: width ?? double.infinity,
            child: button,
          )
        : button;
  }
  
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}
