import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AlertService {
  final Toastification _toastification = Toastification();

  void showToast({
    required String title,
    required String description,
    Alignment alignment = Alignment.topCenter,
    TextDirection direction = TextDirection.ltr,
    ToastificationStyle style = ToastificationStyle.flatColored,
    ToastificationType type = ToastificationType.info,
  }) {
    _toastification.show(
      title: Text(title),
      autoCloseDuration: const Duration(seconds: 5),
      description: Text(description),
      alignment: alignment,
      showIcon: true,
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      direction: direction,
      style: style,
      type: type,
    );
  }

  void showCallConfirmationDialog({
    required BuildContext context,
    required VoidCallback onCallPressed,
    required VoidCallback onCancelPressed,
    required String callType,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? _buildCupertinoDialog(
                context, onCallPressed, onCancelPressed, callType)
            : _buildMaterialDialog(
                context,
                onCallPressed,
                onCancelPressed,
                callType,
              );
      },
    );
  }

  Widget _buildCupertinoDialog(
    BuildContext context,
    VoidCallback onCallPressed,
    VoidCallback onCancelPressed,
    String callType,
  ) {
    return CupertinoAlertDialog(
      title: const Text('Confirm Call'),
      content: Text('Are you ready to initiate the $callType call?'),
      actions: <Widget>[
        _buildCupertinoButton('Cancel', onCancelPressed, context),
        _buildCupertinoButton('Proceed', onCallPressed, context),
      ],
    );
  }

  Widget _buildMaterialDialog(
    BuildContext context,
    VoidCallback onCallPressed,
    VoidCallback onCancelPressed,
    String callType,
  ) {
    return AlertDialog(
      title: const Text('Confirm Call'),
      content: Text('Are you ready to initiate the $callType call?'),
      actions: <Widget>[
        _buildMaterialButton('Cancel', onCancelPressed, context),
        _buildMaterialButton('Proceed', onCallPressed, context),
      ],
    );
  }

  Widget _buildCupertinoButton(
    String label,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    return CupertinoDialogAction(
      child: Text(label),
      onPressed: () {
        Navigator.of(context).pop();
        onPressed();
      },
    );
  }

  Widget _buildMaterialButton(
    String label,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    return TextButton(
      child: Text(label),
      onPressed: () {
        Navigator.of(context).pop();
        onPressed();
      },
    );
  }
}
