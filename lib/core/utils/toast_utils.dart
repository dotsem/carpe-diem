import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtils {
  static const alignment = Alignment.topLeft;
  static final borderRadius = BorderRadius.circular(12);
  static const showProgressBar = false;
  static const applyBlurEffect = true;
  static const dragToClose = true;
  static const autoCloseDuration = Duration(seconds: 3);
  static const style = ToastificationStyle.minimal;

  static void showSuccess(String message, {BuildContext? context}) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: autoCloseDuration,
      type: ToastificationType.success,
      style: style,
      alignment: alignment,
      primaryColor: AppColors.accent,
      borderRadius: borderRadius,
      showProgressBar: showProgressBar,
      applyBlurEffect: applyBlurEffect,
      dragToClose: dragToClose,
    );
  }

  static void showInfo(String message, {BuildContext? context}) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: autoCloseDuration,
      type: ToastificationType.info,
      style: style,
      alignment: alignment,
      primaryColor: AppColors.info,
      borderRadius: borderRadius,
      showProgressBar: showProgressBar,
      applyBlurEffect: applyBlurEffect,
      dragToClose: dragToClose,
    );
  }

  static void showWarning(String message, {BuildContext? context}) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: autoCloseDuration,
      type: ToastificationType.warning,
      style: style,
      alignment: alignment,
      primaryColor: AppColors.priorityMedium,
      borderRadius: borderRadius,
      showProgressBar: showProgressBar,
      applyBlurEffect: applyBlurEffect,
      dragToClose: dragToClose,
    );
  }
}
