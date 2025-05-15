import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'buttons.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;
  
  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: isLoading ? null : (onCancel ?? () => Navigator.of(context).pop()),
          child: Text(cancelText),
        ),
        PrimaryButton(
          text: confirmText,
          onPressed: onConfirm,
          isLoading: isLoading,
          width: 120,
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  
  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        PrimaryButton(
          text: buttonText,
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          width: 100,
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String message;
  
  const LoadingDialog({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}